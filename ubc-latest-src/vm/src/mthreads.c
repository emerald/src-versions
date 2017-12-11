/*
 * Copyright (C) Norman C. Hutchinson and the University of British Columbia
 */
#pragma warning(disable: 4068)
#pragma pointer_size long
#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#ifdef WIN32
#  ifdef MSVC40
#    include <winsock.h>
#  else
#    include <winsock2.h>
#  endif
#  include <io.h>
#  include <errno.h>
#  include <assert.h>
#  include <errno.h>
#else /* not WIN32 */
#  include <unistd.h>
#  include <sys/socket.h>
#  if !defined(linux) && !defined(hpux) && !defined(sun4) && !defined(__NeXT__)
#    include <sys/select.h>
#  endif
#  include <sys/uio.h>
#  include <sys/errno.h>
   extern int errno;
#  include <signal.h>
#  include <netinet/in.h>
#  include <netinet/tcp.h>
#  include <netdb.h>
#endif /* not WIN32 */

#pragma pointer_size short
#include "assert.h"

#include "mthreads.h"
#include "io.h"
#include "mqueue.h"

#ifdef WIN32
extern int gettimeofday(struct timeval *, void *);
#else /* not WIN32 */
#ifndef SELECTSIZE_T
#define SELECTSIZE_T size_t
#endif
#ifndef SELECTFD_T
#define SELECTFD_T fd_set
#endif
#ifndef SELECTCONST
#define SELECTCONST const
#endif

#ifndef FAKEREAD
#define reax(fd, buf, nbytes) read(fd, buf, nbytes)
#else
extern int reax(int fd, void *buf, int nbytes);
#endif
#ifndef FAKEWRITE
#define writx(fd, buf, nbytes) write(fd, buf, nbytes)
#else
extern int writx(int fd, const void *buf, int nbytes);
#endif
#ifndef FAKESELECT
#define selecx(fd, r, w, x, t) select(fd, r, w, x, t)
#else
extern int selecx(SELECTSIZE_T fd, SELECTFD_T *r, SELECTFD_T *w, SELECTFD_T *x, SELECTCONST struct timeval *t);
#endif


#define MAXOTHERS 128
static int nothers;
struct other {
  NodeAddr id;
  int s;
} others[MAXOTHERS], cache;

MQueue incoming, deferred;

/*
 * Forward declarations.
 */
static void setupReader(struct other *ri);

#ifdef MTDEBUG
#define TRACE(level, stuff) if (level <= MTdebuglevel) printf stuff
int MTdebuglevel = 99;
#else
#define TRACE(level, stuff)
#endif

extern int checkSameUser;

void MTPoll(void);

static void (*mter)(void);

void MTRegisterExitRoutine(void (*r)(void))
{
  assert(!mter);
  mter = r;
}

static void callExitRoutines(void)
{
  if (mter) mter();
}

static void pipeHandler(int signalnumber)
{
}

static void intrHandler(int signalnumber)
{
  callExitRoutines();
  exit(1);
}

#endif /* WIN32 */

ssize_t MTwrite2(int fd, void *buf1, size_t n1, void *buf2, size_t n2)
{
  int res;
  struct iovec v[2];
  int howmany = 2;
  v[0].iov_base = buf1;
  v[0].iov_len = n1;
  v[1].iov_base = buf2;
  v[1].iov_len = n2;
  TRACE(4, ("write2 on %d for %d+%d bytes\n", fd, n1, n2));
  if (fd < 0) return -1;
  while (1) {
#ifdef WIN32
    res = send(fd, v[0].iov_base, v[0].iov_len, 0);
#else
    res = writev(fd, v, howmany);
#endif /* WIN32 */
    TRACE(4, ("write2 wrote %d\n", res));
    if ((unsigned)res == v[0].iov_len + v[1].iov_len) {
      res = n1 + n2;
      break;
    } else if (res > 0) {
      /* Only wrote a part, fix up things */
      if ((unsigned)res < v[0].iov_len) {
	v[0].iov_len -= res;
	v[0].iov_base += res;
      } else {
	res -= v[0].iov_len;
	v[0].iov_len = v[1].iov_len - res;
	v[0].iov_base = v[1].iov_base + res;
	v[1].iov_base = 0;
	v[1].iov_len = 0;
	howmany = 1;
      }
    } else {
      printf("write2 error %d\n", res);
      perror("write2");
      break;
    }
  }
  TRACE(4, ("write2 returning %d\n", res));
  return res;
}

#if 0
static int doem(fd_set *fds, MTWhy why)
{
  int index, offset, found = 0, which;
  for (offset = 0, index = 0; offset <= realnfds; offset += 32, index++) {
    while ((which = ffs(fds->fds_bits[index])) > 0) {
      found ++;
      assert(FD_ISSET(offset + which - 1, fds));
      FD_CLR(offset + which - 1, fds);
      TRACE(7, ("Found %d ready for %d\n", offset + which - 1, why));
      if (fdsems[offset + which - 1][why].count < 0) {
	MTSemV(&fdsems[offset + which - 1][why]);
      } else {
	/* This had better be the multi waiter from select */
	MTSemV(&waitonmulti);
      }
    }
  }
  return found;
}
#endif

#ifdef __linux
# define sigvec		sigaction
# define sv_mask	sa_mask
# define sv_flags	sa_flags
# define sv_handler	sa_handler
# define sv_onstack	sa_mask /* ouch, this one really hurts */
#endif /* __linux */

#ifdef hp700
#define SIGVEC sigvector
#else
#define SIGVEC sigvec
#endif /* hp700 */

struct header {
  int length;
};

NodeAddr myid;
static int mysocket;

struct nbo {
  unsigned int ipaddress;
  unsigned short port, incarnation;
  int userid;
};

static NotifyFunction notifyFunction;

void MTRegisterNotify(NotifyFunction f)
{
  assert(notifyFunction == 0);
  notifyFunction = f;
}

static void nukeother(struct other o)
{
  int from, to;
  TRACE(8, ("Nuking %x.%x (%d)\n", o.id.ipaddress, o.id.port, o.s));
  for (from = 0, to = 0; from < nothers; from++) {
    if (others[from].s == o.s) {
      TRACE(8, ("  Nuking %x.%x (%d)\n", others[from].id.ipaddress, others[from].id.port, others[from].s));
      /* don't do this one */
    } else {
      if (from != to) {
	others[to++] = others[from];
      } else {
	to++;
      }
    }
  }
  TRACE(7, ("Nothers went from %d to %d\n", nothers, to));
  nothers = to;
  cache.id.ipaddress = cache.id.port = cache.s = 0;
}

int findsocket(NodeAddr *t)
{
  int i, addrlen, s;
  struct sockaddr_in addr;
  struct other *o, localcopy;
  struct nbo nbo;

  TRACE(7, ("in find socket for %#x.%4x\n", t->ipaddress, t->port));
  if (cache.id.ipaddress == t->ipaddress && cache.id.port == t->port && cache.s) {
    TRACE(8, ("find socket returning %d from cache\n", cache.s));
    return cache.s;
  }
  for (i = 0; i < nothers; i++) {
    TRACE(9, ("  Looking at %#x.%4x\n", others[i].id.ipaddress, others[i].id.port));
    if (others[i].id.ipaddress == t->ipaddress && others[i].id.port == t->port) {
      cache = others[i];
      TRACE(8, ("find socket returning %d\n", cache.s));
      return cache.s;
    }
  }
#if defined(WIN32) && defined(SO_SYNCHRONOUS_NONALERT)
  {
    int optionValue = SO_SYNCHRONOUS_NONALERT;
    int err;
    err = setsockopt(INVALID_SOCKET,
		     SOL_SOCKET,
		     SO_OPENTYPE,
		     (char *)&optionValue,
		     sizeof(optionValue));
    if (err != NO_ERROR) {
      printf("setsockopt: OPENTYPE failed with %d\n", err);
      abort();
    }
  }
#endif
  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) return -1;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(0);
  addr.sin_addr.s_addr = 0;
  if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    perror("findsocket.bind");
    close(s);
    return -1;
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(t->port);
  addr.sin_addr.s_addr = t->ipaddress;
  addrlen = sizeof(addr);
  TRACE(3, ("Trying to connect to %08lx.%04x\n", addr.sin_addr.s_addr, ntohs(addr.sin_port)));
  if (connect(s, (struct sockaddr *)&addr, addrlen) < 0) {
#ifdef MTDEBUG
    if (MTdebuglevel >= 3) perror("findsocket.connect");
#endif
    close(s);
    return -1;
  }
  {
    int on = 1;
    if (setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof (on)) < 0) {
      close(s);
      perror("setsockopt");
      return -1;
    }
  }

  localcopy.id = *t;
  localcopy.s = s;
  TRACE(9, ("Inserting %#x.%d -> %d in others\n", t->ipaddress, t->port, localcopy.s));
  others[nothers++] = localcopy;
  {
    nbo.ipaddress = myid.ipaddress;
    nbo.port = htons(myid.port);
    nbo.incarnation = htons(myid.incarnation);
    nbo.userid = htonl(getuid());
    if (writeToSocketN(localcopy.s, &nbo, sizeof(nbo)) != sizeof(nbo) ||
	readFromSocketN(localcopy.s, &nbo, sizeof(nbo)) != sizeof(nbo)) {
      TRACE(0, ("Couldn't exchange incarnation info\n"));
      close(localcopy.s);
      nothers--;
      return -1;
    } else if(checkSameUser && getuid() != ntohl(nbo.userid)) {
      fprintf(stderr, "Permission denied - user mismatch local %d != remote %d\n", (int)getuid(), ntohl(nbo.userid));
      close(localcopy.s);
      nothers--;
      return -1;
    }
    localcopy.id.ipaddress = nbo.ipaddress;
    localcopy.id.incarnation = ntohs(nbo.incarnation);
    assert(localcopy.id.port == ntohs(nbo.port));
    *t = localcopy.id;
  }
  o = (struct other *)malloc(sizeof *o);
  *o = localcopy;
  setupReader(o);
  TRACE(8, ("find socket returning new %d\n", localcopy.s));
  cache = localcopy;
  return cache.s;
}

static void callNotifyFunction(NodeAddr id, int comingup)
{
  notifyFunction(id, comingup);
}

typedef struct ReaderState {
  struct other *ri;
  readBuffer rb;
  int readingLength, length;
} ReaderState;

static void ReaderCB(int sock, EDirection d, void *state)
{
  ReaderState *rs = state;
  int res;
  void *buffer = 0;

  if (!(res = tryReading(&rs->rb, sock))) return;
  if (res < 0 || res != rs->rb.goal) {
    /*
     * Give up on this socket.
     */
    resetHandler(sock, EIO_Read);
    resetHandler(sock, EIO_Except);
    close(sock);
    if (notifyFunction) notifyFunction(rs->ri->id, 0);
    nukeother(*rs->ri);
    free(rs->ri);
    free(rs);
  } else if (rs->readingLength) {
    rs->length = ntohl(rs->length);
    rs->readingLength = 0;
    if (rs->length > 0) {
      buffer = malloc(rs->length);
      setupReadBuffer(&rs->rb, buffer, rs->length, 0, readFromSocket);
    } else {
      TRACE(0, ("Negative length %d\n", rs->length));
    }
  } else {
    assert(ntohl(*(int *)rs->rb.buffer) == 0xdeafdeaf);
    MQueueInsert(incoming, rs->ri->id, rs->length, rs->rb.buffer);
    setupReadBuffer(&rs->rb, &rs->length, sizeof(rs->length), 0, readFromSocket);
    rs->readingLength = 1;
  }
}

static void setupReader(struct other *ri)
{
  ReaderState *rs = (ReaderState *)malloc(sizeof(*rs));
  rs->ri = ri;
  rs->readingLength = 1;
  setupReadBuffer(&rs->rb, &rs->length, sizeof(rs->length), 0, readFromSocket);
  setHandler(rs->ri->s, ReaderCB, EIO_Read, rs);
  setHandler(rs->ri->s, ReaderCB, EIO_Except, rs);
}

void showIncoming(void)
{
  MQueuePrint(incoming);
}

typedef struct {
  struct other *ri;
  struct nbo nbo;
  readBuffer rb;
} ListenerState;
  
static int checkUserOK(int local, int remote)
{
  if (checkSameUser && local != remote) {
      fprintf(stderr, "Permission denied - user mismatch local %d != remote %d\n",
	      local, remote);
      return 0;
  } else {
    return 1;
  }
}

static void ListenerStage2(int sock, EDirection d, void *arg)
{
  int res;
  ListenerState *ls = arg;
  if (!(res = tryReading(&ls->rb, ls->ri->s))) return;
  resetHandler(sock, EIO_Read);
  resetHandler(sock, EIO_Except);
  if (res != sizeof(ls->nbo) || !checkUserOK(getuid(), ntohl(ls->nbo.userid))) {
    nukeother(*ls->ri);
    close(ls->ri->s);
    free(ls->ri);
  } else {
    ls->ri->id.port = ntohs(ls->nbo.port);
    ls->ri->id.ipaddress = ls->nbo.ipaddress;
    ls->ri->id.incarnation = ntohs(ls->nbo.incarnation);
    TRACE(8, ("Inserting %#x.%4x.%4x -> %d in others\n", ls->ri->id.ipaddress, ls->ri->id.port, ls->ri->id.incarnation, ls->ri->s));
    others[nothers++] = *ls->ri;
    setupReader(ls->ri);
    if (notifyFunction) callNotifyFunction(ls->ri->id, 1);
  }
  vmFree((char *)ls);
}

static void ListenerCB(int sock, EDirection d, void *s)
{
  int newsocket;
  struct sockaddr_in addr;
  int addrlen = sizeof(addr), on = 1;
  ListenerState *ls = (ListenerState *)malloc(sizeof(*ls));

  newsocket = accept(sock, (struct sockaddr *)&addr, &addrlen);
  if (newsocket < 0) return;
  if (setsockopt(newsocket, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof (on)) < 0) {
    close(newsocket);
    perror("setsockopt");
    return;
  }
  ls->ri = (struct other *)malloc(sizeof *ls->ri);
  ls->ri->s = newsocket;
  ls->ri->id.ipaddress = addr.sin_addr.s_addr;
  ls->ri->id.port = ntohs(addr.sin_port);

  TRACE(8, ("Inserting %#x.%x -> %d in others\n", ls->ri->id.ipaddress, ls->ri->id.port, ls->ri->s));
  others[nothers++] = *ls->ri;
  ls->nbo.ipaddress = myid.ipaddress;
  ls->nbo.port = htons(myid.port);
  ls->nbo.incarnation = htons(myid.incarnation);
  ls->nbo.userid = htonl(getuid());
  if (send(ls->ri->s, (char *)&ls->nbo, sizeof(ls->nbo), 0) != sizeof(ls->nbo)) {
    nukeother(*ls->ri);
    close(ls->ri->s);
    free(ls->ri);
    return;
  }
  setupReadBuffer(&ls->rb, &ls->nbo, sizeof(ls->nbo), 0, readFromSocket);
  setHandler(ls->ri->s, ListenerStage2, EIO_Read, ls);
  setHandler(ls->ri->s, ListenerStage2, EIO_Except, ls);
}

static void setupListener(int sock)
{
  setHandler(sock, ListenerCB, EIO_Read, NULL);
}

int MTNetStart(unsigned int ipaddress, unsigned short port, unsigned short incarnation)
{
  struct sockaddr_in addr;
  int addrlen, on = 1;
  char hostname[128];
#ifdef alpha
#pragma pointer_size long
#endif
  struct hostent *h;
#ifdef alpha
#pragma pointer_size short
#endif

  assert(myid.ipaddress == 0 && myid.port == 0 && myid.incarnation == 0);
  if ((mysocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    return -1;
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = ipaddress;
  if (bind(mysocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    close(mysocket);
    return -1;
  }
  addrlen = sizeof(addr);
  if (getsockname(mysocket, (struct sockaddr *)&addr, &addrlen) < 0) {
    close(mysocket);
    return -1;
  }
  TRACE(3, ("NetStart on %#lx.%d\n", addr.sin_addr.s_addr, ntohs(addr.sin_port)));
  if (listen(mysocket, 5) < 0) {
    close(mysocket);
    return -1;
  }
  if (setsockopt(mysocket, SOL_SOCKET, SO_REUSEADDR, (char *)&on, sizeof (on)) < 0) {
    close(mysocket);
    perror("setsockopt");
    return -1;
  }
  /*
   * Originally we did this all the time on not windows
   */
  if (addr.sin_addr.s_addr == 0) {
    if (gethostname(hostname, sizeof hostname) < 0) {
      TRACE(1, ("Can't get my own host name\n"));
      close(mysocket);
      return -1;
    }
    /* A Hack */
    if ((h = gethostbyname(hostname)) == 0) {
      printf("Can't look up my own host name\n");
      strcpy(hostname, "hutchinson2.home.cs.ubc.ca");
      if ((h = gethostbyname(hostname)) == 0) {
		printf("Still can't look up my own host name\n");
	
	close(mysocket);
	return -1;
      }
    }
    memcpy(&addr.sin_addr.s_addr, h->h_addr, sizeof(unsigned int));
  }
  myid.ipaddress = addr.sin_addr.s_addr;
  myid.port = ntohs(addr.sin_port);
  myid.incarnation = incarnation;
  TRACE(2, ("Net start on %04x.%04x.%04x\n", myid.ipaddress, myid.port, myid.incarnation));
  setupListener(mysocket);
  return 0;
}

int MTReceive(NodeAddr *senderid, void **rbuf, int *rlen)
{
  TRACE(1, ("MTReceive called\n"));
  MQueueRemove(incoming, senderid, rlen, rbuf);
  TRACE(2, ("MTReceive returning %d\n", *rlen));
  return 1;
}

int MTProd(NodeAddr *receiver)
{
  int s = findsocket(receiver);
  return s;
}

int MTSend(NodeAddr receiver, void *sbuf, int slen)
{
  unsigned int length;
  int s = findsocket(&receiver), res;
  extern char *NodeAddrString(NodeAddr);
  extern int nMessagesSent, nBytesSent;

  nMessagesSent++;
  nBytesSent += slen;

  TRACE(3, ("Send\n"));

  length = htonl(slen);
  res = MTwrite2(s, &length, sizeof(length), sbuf, slen);
  if (res != sizeof(length) + slen) {
    perror("  mtsend");
    printf("MTSend to %s, socket %d, for %d bytes returned %d\n",
	   NodeAddrString(receiver), s, slen + sizeof(length), res);
    return -1;
  }
  TRACE(3, ("Send returning\n"));
  return 1;
}

void MTSetDebugLevel(int x)
{
#if defined(MTDEBUG)
  MTdebuglevel = x;
#endif
}
void MTInit()
{
#if defined(__svr4__) || defined(__SYSTYPE_SVR4__)
  struct sigaction action;

  memset(&action, 0, sizeof(action));
  action.sa_handler = intrHandler;
  sigaction(SIGINT, &action, NULL);
  action.sa_handler = pipeHandler;
  sigaction(SIGPIPE, &action, NULL);
#else
  struct sigvec vec;
  memset(&vec, 0, sizeof(vec));

  vec.sv_handler = intrHandler;
  SIGVEC(SIGINT, &vec, NULL);
  vec.sv_handler = pipeHandler;
  SIGVEC(SIGPIPE, &vec, NULL);
#endif
  incoming = MQueueCreate();
  deferred = MQueueCreate();
}

#ifdef WIN32
void perror(const char *msg)
{
  printf("%s: %d\n", msg, errno);
  fflush(stdout);
}
#endif /* WIN32 */

void processBoringMessages(void)
{
  while (MQueueSize(incoming) == 0) {
    checkForIO(1);
  }
  serveRequest();
}

