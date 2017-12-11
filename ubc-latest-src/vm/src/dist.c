/*
 * Copyright (C)
 * Norman C. Hutchinson and the University of British Columbia, 1998
 */
#define E_NEEDS_STRING
#define E_NEEDS_SOCKET
#define E_NEEDS_SIGNAL
#define E_NEEDS_IOV
#define E_NEEDS_TCP
#define E_NEEDS_NETDB
#define E_NEEDS_ERRNO
#include "system.h"

#include "assert.h"
#include "types.h"
#include "mqueue.h"
#include "storage.h"
#include "misc.h"

Node myid;

MQueue incoming;

#ifdef DISTRIBUTED
#include "dist.h"
#include "remote.h"
#include "io.h"

#ifdef WIN32
extern int gettimeofday(struct timeval *, void *);
#endif /* not WIN32 */

#ifndef SELECTSIZE_T
#define SELECTSIZE_T size_t
#endif
#ifndef SELECTFD_T
#define SELECTFD_T fd_set
#endif
#ifndef SELECTCONST
#define SELECTCONST const
#endif

#define MAXOTHERS 128
static int nothers;
struct other {
  Node id;
  int s;
} others[MAXOTHERS], cache;

/*
 * Forward declarations.
 */
static void setupReader(struct other *ri);

extern int checkSameUser;

static void pipeHandler(int signalnumber)
{
  TRACE(dist, 1, ("Got SIGPIPE"));
}

ssize_t Dwrite2(int fd, void *buf1, size_t n1, void *buf2, size_t n2)
{
  int res;
  struct iovec v[2];
  int howmany = 2;
  v[0].iov_base = buf1;
  v[0].iov_len = n1;
  v[1].iov_base = buf2;
  v[1].iov_len = n2;
  TRACE(dist, 4, ("write2 on %d for %d+%d bytes", fd, n1, n2));
  if (fd < 0) return -1;
  while (1) {
#ifdef WIN32
    res = send(fd, v[0].iov_base, v[0].iov_len, 0);
#else
    res = writev(fd, v, howmany);
#endif /* WIN32 */
    TRACE(dist, 4, ("write2 wrote %d", res));
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
    } else if (res <= 0 && errno == EINTR) {
      /*
       * Go around the loop.
       */
    } else {
      TRACE(dist, 1, ("write2 on %d for %d+%d bytes returned %d, errno = %d",
		      fd, n1, n2, res, errno));
      break;
    }
  }
  TRACE(dist, 4, ("write2 returning %d", res));
  return res;
}

struct header {
  int length;
};

static int mysocket;

struct nbo {
  unsigned int ipaddress;
  unsigned short port, epoch;
  int userid;
};

static NotifyFunction notifyFunction;

void DRegisterNotify(NotifyFunction f)
{
  assert(notifyFunction == 0);
  notifyFunction = f;
}

static void nukeother(struct other o)
{
  int from, to;
  TRACE(dist, 8, ("Nuking %x.%x (%d)", ntohl(o.id.ipaddress), o.id.port, o.s));
  for (from = 0, to = 0; from < nothers; from++) {
    if (others[from].s == o.s) {
      TRACE(dist, 8, ("  Nuking %x.%x (%d)", ntohl(others[from].id.ipaddress), others[from].id.port, others[from].s));
      /* don't do this one */
    } else {
      if (from != to) {
	others[to++] = others[from];
      } else {
	to++;
      }
    }
  }
  TRACE(dist, 7, ("Nothers went from %d to %d", nothers, to));
  nothers = to;
  cache.id.ipaddress = cache.id.port = cache.s = 0;
}

static void maximizeSocketBuffers(int s)
{
#if defined(SO_SNDBUF) && defined(SO_RCVBUF)
	int size = 0, mid, low, high, len;
	int which = SO_SNDBUF;
	do {
		len = sizeof(low);
		if (getsockopt(s, SOL_SOCKET, which, (char *)&low, &len) >= 0) {
			low = low / 1024;
			high = 128;
			while (low < high) {
				mid = size = ((low + high) / 2) * 1024;
				if (size == low * 1024 || size == high * 1024) break;
				TRACE(dist, 14, ("Range [%d-%d], trying size %d", low * 1024, high * 1024, size));
				if (setsockopt(s, SOL_SOCKET, which, (char *)&size, sizeof(size)) < 0) {
					TRACE(dist, 13, ("Resetting high to %d", mid / 1024));
					high = mid / 1024;
				} else {
					TRACE(dist, 13, ("Resetting low to %d", mid / 1024));

					low = mid / 1024;
				}
			}
		}
		TRACE(dist, 3, ("Set socket buffer size to %d", size));
		which = (which == SO_SNDBUF ? SO_RCVBUF : -1);
	} while (which != -1);
#endif
}

static char *formatIPAddress(Bits32 addr, char *buffer)
{
	sprintf(buffer, "%d.%d.%d.%d",
			(addr & 0xff000000) >> 24, (addr & 0x00ff0000) >> 16,
			(addr & 0x0000ff00) >> 8, (addr & 0x000000ff));
	return buffer;
}

static int isLocalAddress(Bits32 addr)
{
	return ((addr & 0xff000000) == 0x7f000000);
}

static void checkForStrangeness()
{
	int i, prev = -1;
	TRACE(dist, 7, ("  Looking for strangeness"));
	for (i = 0; i < nothers; i++) {
		TRACE(dist, 8, ("  Looking at %#x.%4x %d %s", ntohl(others[i].id.ipaddress), others[i].id.port, others[i].s, isLocalAddress(ntohl(others[i].id.ipaddress)) ? "Local" : "Not local"));
		if (!isLocalAddress(ntohl(others[i].id.ipaddress))) {
			if (prev != -1 && others[prev].s == others[i].s && others[prev].id.ipaddress != others[i].id.ipaddress) {
				char b1[32], b2[32];
				/* Strangeness */
				TRACE(dist, 9, ("Strange, others[%d] = %#x %d", prev, ntohl(others[prev].id.ipaddress), others[prev].s));
				TRACE(dist, 9, ("Strange, others[%d] = %#x %d", i, ntohl(others[i].id.ipaddress), others[i].s));
				printf("Found two different addresses for a node (%s and %s)\n",
					   formatIPAddress(ntohl(others[prev].id.ipaddress), b1),
					   formatIPAddress(ntohl(others[i].id.ipaddress), b2));
				printf("This node probably has a non-working but enabled network interface\n");
				printf("Emerald doesn't deal well with this\n");
			}
			prev = i;
		}
	}
}

int findsocket(Node *t, int create)
{
  int i, addrlen, s, pos;
  struct sockaddr_in addr;
  struct other *o, localcopy;
  struct nbo nbo;

  TRACE(dist, 7, ("in find socket for %#x.%4x", ntohl(t->ipaddress), t->port));
  if (cache.id.ipaddress == t->ipaddress && cache.id.port == t->port && cache.s) {
    TRACE(dist, 8, ("find socket returning %d from cache", cache.s));
    return cache.s;
  }
  for (i = 0; i < nothers; i++) {
    TRACE(dist, 9, ("  Looking at %#x.%4x", ntohl(others[i].id.ipaddress), others[i].id.port));
    if (others[i].id.ipaddress == t->ipaddress && others[i].id.port == t->port) {
      cache = others[i];
      TRACE(dist, 8, ("find socket returning %d", cache.s));
      return cache.s;
    }
  }
  if (!create) return -1;
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
    closesocket(s);
    return -1;
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(t->port);
  addr.sin_addr.s_addr = t->ipaddress;
  addrlen = sizeof(addr);
  TRACE(dist, 1, ("Trying to connect to %08lx.%04x", ntohl(addr.sin_addr.s_addr), ntohs(addr.sin_port)));
  if (connect(s, (struct sockaddr *)&addr, addrlen) < 0) {
    TRACE(dist, 3, ("Connect failed with errno %d %s", errno, strerror(errno)));
    closesocket(s);
    return -1;
  }
  {
    int on = 1;
    if (setsockopt(s, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof (on)) < 0) {
      closesocket(s);
      perror("setsockopt");
      return -1;
    }
  }
  maximizeSocketBuffers(s);

  localcopy.id = *t;
  localcopy.s = s;
  TRACE(dist, 9, ("Inserting %#x.%d -> %d in others[%d]", ntohl(t->ipaddress), t->port, localcopy.s, nothers));
  pos = nothers;
  others[nothers++] = localcopy;
  {
    nbo.ipaddress = myid.ipaddress;
    nbo.port = htons(myid.port);
    nbo.epoch = htons(myid.epoch);
    nbo.userid = htonl(getuid());
    if (writeToSocketN(localcopy.s, &nbo, sizeof(nbo)) != sizeof(nbo) ||
	readFromSocketN(localcopy.s, &nbo, sizeof(nbo)) != sizeof(nbo)) {
      TRACE(dist, 0, ("Couldn't exchange epoch info"));
      closesocket(localcopy.s);
      nothers--;
      return -1;
    } else if(checkSameUser && getuid() != (int)ntohl(nbo.userid)) {
      printf("Permission denied - user mismatch local %d != remote %d\n", (int)getuid(), (int)ntohl(nbo.userid));
      closesocket(localcopy.s);
      nothers--;
      return -1;
    }
    localcopy.id.ipaddress = nbo.ipaddress;
    localcopy.id.epoch = ntohs(nbo.epoch);
    assert(localcopy.id.port == ntohs(nbo.port));
    *t = localcopy.id;
  }
  o = (struct other *)vmMalloc(sizeof *o);
  *o = localcopy;
  setupReader(o);
  TRACE(dist, 2, ("find socket returning new %d", localcopy.s));
  cache = localcopy;
  if (!SameNode(others[pos].id, cache.id)) {
    TRACE(dist, 9, ("Inserting %#x.%d -> %d in others[%d]", ntohl(cache.id.ipaddress), cache.id.port, cache.s, nothers));
    others[nothers++] = cache;
  }
  checkForStrangeness();
  return cache.s;
}

static void callNotifyFunction(Node id, int comingup)
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
  extern int nMessagesReceived, nBytesReceived;
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
    closesocket(sock);
    if (notifyFunction) notifyFunction(rs->ri->id, 0);
    nukeother(*rs->ri);
    vmFree(rs->ri);
    vmFree(rs);
  } else if (rs->readingLength) {
    nBytesReceived += sizeof(rs->length);
    rs->length = ntohl(rs->length);
    rs->readingLength = 0;
    if (rs->length > 0) {
      buffer = vmMalloc(rs->length);
      setupReadBuffer(&rs->rb, buffer, rs->length, 0, readFromSocket);
    } else {
      TRACE(dist, 0, ("Negative length %d", rs->length));
    }
  } else {
    nBytesReceived += rs->length;
    nMessagesReceived ++;
    assert(ntohl(*(int *)rs->rb.buffer) == 0xdeafdeaf);
    MQueueInsert(incoming, rs->ri->id, rs->length, rs->rb.buffer);
    setupReadBuffer(&rs->rb, &rs->length, sizeof(rs->length), 0, readFromSocket);
    rs->readingLength = 1;
  }
}

static void setupReader(struct other *ri)
{
  ReaderState *rs = (ReaderState *)vmMalloc(sizeof(*rs));
  rs->ri = ri;
  rs->readingLength = 1;
  setupReadBuffer(&rs->rb, &rs->length, sizeof(rs->length), 0, readFromSocket);
  setHandler(rs->ri->s, ReaderCB, EIO_Read, rs);
  setHandler(rs->ri->s, ReaderCB, EIO_Except, rs);
}

typedef struct {
  struct other *ri;
  struct nbo nbo;
  readBuffer rb;
} ListenerState;
  
static int checkUserOK(int local, int remote)
{
  if (checkSameUser && local != remote) {
      printf("Permission denied - user mismatch local %d != remote %d\n",
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
    closesocket(ls->ri->s);
    vmFree(ls->ri);
  } else {
    ls->ri->id.port = ntohs(ls->nbo.port);
    ls->ri->id.ipaddress = ls->nbo.ipaddress;
    ls->ri->id.epoch = ntohs(ls->nbo.epoch);
    TRACE(dist, 8, ("Inserting %#x.%4x.%4x -> %d in others[%d]", ntohl(ls->ri->id.ipaddress), ls->ri->id.port, ls->ri->id.epoch, ls->ri->s, nothers));
    others[nothers++] = *ls->ri;
    setupReader(ls->ri);
    if (notifyFunction) callNotifyFunction(ls->ri->id, 1);
  }
  checkForStrangeness();
  vmFree((char *)ls);
}

static void ListenerCB(int sock, EDirection d, void *s)
{
  int newsocket;
  struct sockaddr_in addr;
  int addrlen = sizeof(addr), on = 1;
  ListenerState *ls = (ListenerState *)vmMalloc(sizeof(*ls));

  TRACE(dist, 1, ("ListenerCB on %d", sock));
  newsocket = accept(sock, (struct sockaddr *)&addr, &addrlen);
  if (newsocket < 0) return;
  if (setsockopt(newsocket, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof (on)) < 0) {
    closesocket(newsocket);
    perror("setsockopt");
    return;
  }
  maximizeSocketBuffers(newsocket);
  ls->ri = (struct other *)vmMalloc(sizeof *ls->ri);
  ls->ri->s = newsocket;
  ls->ri->id.ipaddress = addr.sin_addr.s_addr;
  ls->ri->id.port = ntohs(addr.sin_port);

  TRACE(dist, 1, ("Accepted new connection %d from %#x.%x",
		  ls->ri->s, ntohl(ls->ri->id.ipaddress), ls->ri->id.port));
  TRACE(dist, 8, ("Inserting %#x.%x -> %d in others[%d]", ntohl(ls->ri->id.ipaddress), ls->ri->id.port, ls->ri->s, nothers));
  others[nothers++] = *ls->ri;
  ls->nbo.ipaddress = myid.ipaddress;
  ls->nbo.port = htons(myid.port);
  ls->nbo.epoch = htons(myid.epoch);
  ls->nbo.userid = htonl(getuid());
  checkForStrangeness();
  if (send(ls->ri->s, (char *)&ls->nbo, sizeof(ls->nbo), 0) != sizeof(ls->nbo)) {
    nukeother(*ls->ri);
    closesocket(ls->ri->s);
    vmFree(ls->ri);
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

int DNetStart(unsigned int ipaddress, unsigned short port, unsigned short epoch)
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

  assert(myid.ipaddress == 0 && myid.port == 0 && myid.epoch == 0);
  if ((mysocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    return -1;
  }
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = ipaddress;
  if (bind(mysocket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    closesocket(mysocket);
    return -1;
  }
  addrlen = sizeof(addr);
  if (getsockname(mysocket, (struct sockaddr *)&addr, &addrlen) < 0) {
    closesocket(mysocket);
    return -1;
  }
  TRACE(dist, 3, ("NetStart on %#lx.%d", addr.sin_addr.s_addr, ntohs(addr.sin_port)));
  if (listen(mysocket, 5) < 0) {
    closesocket(mysocket);
    return -1;
  }
  if (setsockopt(mysocket, SOL_SOCKET, SO_REUSEADDR, (char *)&on, sizeof (on)) < 0) {
	  /* This is not a big deal, ignore it */
	  TRACE(dist, 1, ("Failed to set SO_REUSEADDR socket option"));
  }
  /*
   * Originally we did this all the time on not windows
   */
  if (addr.sin_addr.s_addr == 0 || addr.sin_addr.s_addr == htonl(0x7f000001)) {
    if (gethostname(hostname, sizeof hostname) < 0) {
      printf("Can't get my own host name.\n");
      printf("Emerald won't work well between machines.\n");
    } else if ((h = gethostbyname(hostname)) == 0) {
      printf("Can't look up my own host name.\n");
      printf("Emerald won't work well between machines.\n");
    } else {
      memcpy(&addr.sin_addr.s_addr, h->h_addr, sizeof(unsigned int));
    }
  }
  myid.ipaddress = addr.sin_addr.s_addr;
  myid.port = ntohs(addr.sin_port);
  myid.epoch = epoch;
  TRACE(dist, 2, ("Net start on %04x.%04x.%04x", ntohl(myid.ipaddress), myid.port, myid.epoch));
  setupListener(mysocket);
  return 0;
}

int DProd(Node *receiver)
{
  int s = findsocket(receiver, 1);
  return s;
}

int DSend(Node receiver, void *sbuf, int slen)
{
  unsigned int length;
  int s = -1, res = 1;
  extern char *NodeString(Node);
  extern int nMessagesSent, nBytesSent;
  noderecord *nr;


  if (SameNode(receiver, myid)) {
    res = -1;
  } else if (isNoNode(receiver)) {
    res = -1;
  } else {
    nr = getNodeRecordFromSrv(receiver);
    if (nr && !nr->up) {
      /*
       * We have an entry for this node, and it is down.
       */
      res = -1;
    } else {
      s = findsocket(&receiver, 1);
      nMessagesSent++;
      nBytesSent += slen;

      TRACE(dist, 3, ("Send"));

      length = htonl(slen);
      res = Dwrite2(s, &length, sizeof(length), sbuf, slen);
      if (res != sizeof(length) + slen) {
	TRACE(dist, 1, ("DSend to %s, socket %d, for %d bytes returned %d\n",
			NodeString(receiver), s, slen + sizeof(length), res));
	res = -1;
      }
    }
  }
  TRACE(dist, ((res < 0) ? 1 : 5), ("DSend %d to %s on %d returning %d", slen,
				    NodeString(receiver), s, res));
  return res;
}

void processMessages(void)
{
  if (MQueueSize(incoming) == 0) checkForIO(1);
  if (MQueueSize(incoming) > 0) serveRequest();
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

void establishHandler(int sig, void (*handler)(int))
{
#if defined(__svr4__) || defined(__SYSTYPE_SVR4__) || defined(CYGWIN)
  struct sigaction action;

  memset(&action, 0, sizeof(action));
  action.sa_handler = handler;
  sigaction(sig, &action, NULL);
#else
#if defined(WIN32) || defined(DOS)
  signal(sig, handler);
#else
  struct sigvec vec;
  memset(&vec, 0, sizeof(vec));

  vec.sv_handler = handler;
  SIGVEC(sig, &vec, NULL);
#endif
#endif
}

void DInit(void)
{
  extern void sigdie(int);
  establishHandler(SIGINT, sigdie);
#if defined(SIGPIPE) && defined(DISTRIBUTED)
  establishHandler(SIGPIPE, pipeHandler);
#endif
  incoming = MQueueCreate();
}

#ifdef WIN32
void perror(const char *msg)
{
  printf("%s: %d\n", msg, errno);
  fflush(stdout);
}
#endif /* WIN32 */

char *NodeString(Node srv)
{
  static char buf[5][60];
  static int i = 0;
  char *rval;

  rval = buf[i]; i = (i+1) % 5;
  sprintf(rval, "%08lx.%04x.%04x", ntohl(srv.ipaddress), srv.port, srv.epoch);
  return rval;
}

int getplane()
{
  int port = 0;
  extern int offsetbyuserid;
  char *plane = getenv("EMPLANE");
  if (plane) {
    port += mstrtol(plane, 0, 10);
  } else if (offsetbyuserid) {
    port += getuid() % EMERALDPORTSKIP;
  }
  return port;
}


int InitDist()
{
  extern Node MyNode;
  extern OID MyBaseOID;
  int port;
  extern char *getenv(const char *);

  InitStorage();

  MyNode.epoch = random() & 0xffff;
  /* start up the network subsystem */
  port = EMERALDFIRSTPORT + getplane();
  
#ifdef DISTRIBUTED
  while (DNetStart(0,  port, MyNode.epoch) != 0) {
    port = EMERALDPORTPROBE(port);
    if (port > 0x10000) return -1;
  }
#else
  myid.ipaddress = 0xdeadbeef;
  myid.port = port;
  myid.epoch = MyNode.epoch;
#endif
  MyNode.ipaddress = myid.ipaddress;
  MyNode.port = myid.port;
  MyNode.epoch = myid.epoch;
  MyBaseOID.ipaddress = ntohl(MyNode.ipaddress);
  MyBaseOID.port = MyNode.port;
  MyBaseOID.epoch = MyNode.epoch;

  return 0;
}

