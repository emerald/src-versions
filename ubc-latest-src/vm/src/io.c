#define E_NEEDS_STRING
#define E_NEEDS_SOCKET
#define E_NEEDS_SELECT
#define E_NEEDS_FILE
#define E_NEEDS_ERRNO
#include "system.h"

#include "io.h"
#include "iisc.h"
#include "assert.h"
#include "timer.h"
#include "trace.h"

#if !defined(NTRACE)
static char *EIONames[] = {
  "EIO_Read",
  "EIO_Write",
  "EIO_Except"
};
#endif

static fd_set io_sets[3];
static fd_set data_available;
static IISc io_scs[3];
static int nfds = 0;
static struct timeval zerot;

#ifdef FAKE_SELECT
#define N_SELECT_FDS 10

static struct select_info {
  fd_set *reads, *writes, *excepts;
  struct {
    int fd;
    EDirection dir;
  } select_fds[N_SELECT_FDS];
  int n_select_fds;
  struct timeval pause;
} *si;
#endif
struct timeval sipause;

/*
 * Mark data available.  Called back when all we want is to know when to do
 * the real read.
 */
static void markDataAvailable(int fd, EDirection d, void *state)
{
  assert(d == EIO_Read || d == EIO_Except);
  FD_SET((unsigned)fd, &data_available);
}
  
ssize_t readFromSocket(int d, void *buf, size_t nbytes)
{
  return recv(d, buf, nbytes, 0);
}

ssize_t writeToSocket(int d, void *buf, size_t nbytes)
{
  return send(d, buf, nbytes, 0);
}

ssize_t readFromSocketN(int d, void *buf, size_t nbytes)
{
  ssize_t res, nread = 0;
  do {
    res = recv(d, (char *)buf + nread, nbytes - nread, 0);
    if (res < 0) return res;
    if (res == 0) break;
    nread += res;
  } while (nread < nbytes);
  return nread;
}

ssize_t writeToSocketN(int d, void *buf, size_t nbytes)
{
  ssize_t res, nwrit = 0;
  do {
    res = send(d, (char *)buf + nwrit, nbytes - nwrit, 0);
    if (res < 0) return res;
    nwrit += res;
  } while (nwrit < nbytes);
  return nwrit;
}

void IOInit(void)
{
  EDirection i;
  for (i = EIO_Read; i <= EIO_Except; i++) {
    io_scs[i] = IIScCreate();
  }
}

typedef struct ioinfo {
  IoHandler h;
  void *state;
  struct ioinfo *prev;
} ioinfo;

void setHandler(int fd, IoHandler h, EDirection direction, void *state)
{
  ioinfo *ioi = (ioinfo *)vmMalloc(sizeof (*ioi));
  FD_SET((unsigned)fd, &io_sets[direction]);
  ioi->h = h;
  ioi->state = state;
  ioi->prev = (struct ioinfo *)IIScLookup(io_scs[direction], fd);
  if (IIScIsNIL(ioi->prev)) {
    ioi->prev = NULL;
  }
  IIScInsert(io_scs[direction], fd, (int)ioi);
  if (fd >= nfds) nfds = fd + 1;
}

void resetHandler(int fd, EDirection direction)
{
  ioinfo *ioi = (ioinfo *)IIScLookup(io_scs[direction], fd);
  if (IIScIsNIL(ioi)) return;
  if (ioi->prev) {
    IIScInsert(io_scs[direction], fd, (int)ioi->prev);
  } else {
    FD_CLR((unsigned)fd, &io_sets[direction]);
    IIScDelete(io_scs[direction], fd);
  }
  vmFree(ioi);
}

void checkForIO(int wait)
{
  EDirection d;
  fd_set local[3];
  int i, res;
  struct timeval *selectpause;
  struct timeval pause, then;

  local[EIO_Read] = io_sets[EIO_Read];
  local[EIO_Write] = io_sets[EIO_Write];
  local[EIO_Except] = io_sets[EIO_Except];
  if (!wait) {
    selectpause = &zerot;
  } else {
    /*
     * Under win32, we don't get a signal when the time expires, so we have
     * to make sure not to sleep too long.  Under Unix we use SIGALRM, so
     * the select will be interrupted.
     */
    pause = nextWakeup();
    if (!pause.tv_sec && !pause.tv_usec && !sipause.tv_sec && !sipause.tv_usec) {
      selectpause = 0;
    } else {
      TRACE(dist, 8, ("Next wake at %d.%06d", pause.tv_sec, pause.tv_usec));
      gettimeofday(&then, 0);
      TRACE(dist, 8, ("Then %d.%06d", then.tv_sec, then.tv_usec));
      pause = TimeMinus(pause, then);
      TRACE(dist, 8, ("Difference = %d.%06d", pause.tv_sec, pause.tv_usec));
      if ((sipause.tv_sec || sipause.tv_usec) &&
	  ((!pause.tv_sec && !pause.tv_usec) ||
	   sipause.tv_sec < pause.tv_sec ||
	   (sipause.tv_sec == pause.tv_sec &&
	    sipause.tv_usec < pause.tv_usec))) {
	pause = sipause;
      }
      selectpause = &pause;
    }
  }
  TRACE(dist, 4, ("Select delaying for %d.%06d",
		  selectpause ? selectpause->tv_sec : -1,
		  selectpause ? selectpause->tv_usec : 0));
  res = real_select(nfds, S_A(local[EIO_Read]), S_A(local[EIO_Write]),
	       S_A(local[EIO_Except]), selectpause);
  TRACE(dist, 4, ("Select returned %d", res));

  if (res < 0 && errno != EINTR) {
    perror("checkForIO[select]");
  } else if (res > 0) {
    /*
     * This is slow, but works.  Consider making it faster.
     */
    for (i = 0; res > 0 && i < nfds; i++) {
      for (d = EIO_Read; d <= EIO_Except; d++) {
	if (FD_ISSET(i, &local[d])) {
	  ioinfo *ioi = (ioinfo *)IIScLookup(io_scs[d], i);
	  assert(!IIScIsNIL(ioi));
	  TRACE(dist, 13, ("Calling back %s on %d",
			   EIONames[d], i));
	  ioi->h(i, d, ioi->state);
	  res--;
	}
      }
    }
  }
}

void setupReadBuffer(readBuffer *rb, void *buf, int goal, int acceptless,
		     ssize_t (*reader)(int, void *, size_t))
{
  rb->buffer = buf;
  rb->nread = 0;
  rb->goal = goal;
  rb->acceptless = acceptless;
  rb->reader = reader;
}

int tryReading(readBuffer *rb, int s)
{
  int res;
  TRACE(dist, 9, ("tryReading on %d goal %d", s, rb->goal));
  res = rb->reader(s, rb->buffer + rb->nread, rb->goal - rb->nread);
  if (res > 0) {
    rb->nread += res;
    if (rb->nread == rb->goal || (rb->acceptless && rb->nread > 0)) {
      res = rb->nread;
    } else {
      res = 0;
    }
  } else if ((res < 0 && errno == EINTR) || (res <= 0 && errno == ETIMEDOUT)) {
    res = 0;
  } else {
    TRACE(dist, 1, ("tryReading on %d got %d, errno = %d", s, res, errno));
    res = -1;
  }
  TRACE(dist, 10, ("tryReading on %d returning %d", s, res));
  return res;
}

/*
 * Do a read, but wait until it can be accomplished without blocking.  If it
 * tries to block, then just call processEverything until it is available to
 * read.
 */
ssize_t io_read(int d, void *buf, size_t nbytes)
{
  extern void processEverythingOnce(void);
  ssize_t res;
  setHandler(d, markDataAvailable, EIO_Read, 0);
  setHandler(d, markDataAvailable, EIO_Except, 0);
  do {
    processEverythingOnce();
  } while (!FD_ISSET(d, &data_available));
  resetHandler(d, EIO_Read);
  resetHandler(d, EIO_Except);
  FD_CLR(d, &data_available);
  res = read(d, buf, nbytes);
  return res;
}

#ifdef FAKE_SELECT
static int selectDone;

static void terminateSelect(int fd, EDirection d, void *state)
{
  selectDone++;
  FD_SET(fd, d == EIO_Read ? si->reads : d == EIO_Write ? si->writes : si->excepts);
}
  
static void resetHandlers(struct select_info *si)
{
  int i;
  for (i = 0; i < si->n_select_fds; i++) {
    resetHandler(si->select_fds[i].fd, si->select_fds[i].dir);
  }
  sipause = si->pause;
}

static void setHandlers(struct select_info *si)
{
  int i;
  for (i = 0; i < si->n_select_fds; i++) {
    setHandler(si->select_fds[i].fd, terminateSelect, si->select_fds[i].dir, 0);
  }
}

/*
 * Do a select, but wait until it can be accomplished without blocking.  If it
 * tries to block, then just call processEverything until it is available to
 * read.
 */
#if defined(__alpha__) || defined(alpha)
#  define ssize_t int
#endif
ssize_t io_select(int nfds, fd_set *reads, fd_set *writes, fd_set *excepts, struct timeval *pause)
{
  extern void processEverythingOnce(void);
  struct timeval ioselectwake, now;
  struct select_info my_si, *o_si;
  int i;

  TRACE(sys, 3, ("Doing select, nfds = %d, pause = %d.%06d", nfds, pause ? pause->tv_sec : -1, pause ? pause->tv_usec : 0));
  my_si.reads = reads;
  my_si.writes = writes;
  my_si.excepts = excepts;
  /*
   * This is slow, but works.  Consider making it faster.
   */
  selectDone = 0;
  my_si.n_select_fds = 0;
  for (i = 0; i < nfds; i++) {
    if (reads && FD_ISSET(i, reads)) {
      FD_CLR(i, reads);
      setHandler(i, terminateSelect, EIO_Read, 0);
      my_si.select_fds[my_si.n_select_fds].fd = i;
      my_si.select_fds[my_si.n_select_fds++].dir = EIO_Read;
    }
    if (writes && FD_ISSET(i, writes)) {
      FD_CLR(i, writes);
      setHandler(i, terminateSelect, EIO_Write, 0);
      my_si.select_fds[my_si.n_select_fds].fd = i;
      my_si.select_fds[my_si.n_select_fds++].dir = EIO_Write;
    }
    if (excepts && FD_ISSET(i, excepts)) {
      FD_CLR(i, excepts);
      setHandler(i, terminateSelect, EIO_Except, 0);
      my_si.select_fds[my_si.n_select_fds].fd = i;
      my_si.select_fds[my_si.n_select_fds++].dir = EIO_Except;
    }
  }
  if (pause) {
    my_si.pause = *pause;
    gettimeofday(&ioselectwake, 0);
    ioselectwake = TimePlus(ioselectwake, *pause);
  } else {
    my_si.pause.tv_sec = my_si.pause.tv_usec = 0;
  }
  sipause = my_si.pause;
  if (si) resetHandlers(si);
  o_si = si;
  si = &my_si;

  do {
    processEverythingOnce();
    if (!selectDone && pause) {
      gettimeofday(&now, 0);
      if (TimeLess(ioselectwake, now)) selectDone = 1;
    }
  } while (!selectDone);

  resetHandlers(si);
  si = o_si;
  if (si) setHandlers(si);

  return selectDone;
}
#if defined(__alpha__) || defined(alpha)
#  undef ssize_t
#endif
#endif
