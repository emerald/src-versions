/*
 * threads.h
 */

#ifndef _EMERALD_THREADS_H
#define _EMERALD_THREADS_H

#ifndef _EMERALD_STORAGE_H
#include "storage.h"
#endif
extern int useThreads;

#define EMERALDFIRSTPORT 0x3ee3
#define EMERALDPORTSKIP 0x400
#define EMERALDPORTPROBE(n) ((n) + EMERALDPORTSKIP)
#ifdef MTHREADS

#include "mthreads.h"
#ifdef WIN32
#include <io.h>
#endif /* not WIN32 */
#define filesizeofNodeAddr (sizeof(unsigned int) + 2 * sizeof(unsigned short))
int vmInitThreads(void);
char *NodeAddrString(NodeAddr);
extern NodeAddr myid;

#define SameNodeAddrHost(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port)
#define SameNodeAddr(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port && (a).incarnation == (b).incarnation)

#define vmOpen(a,b,c) open(a,b,c)
#ifdef WIN32
#define reax(fd, buf, nbytes) _read(fd, buf, nbytes)
extern size_t vmRead(int fd, void *buf, size_t nbytes);
#define writx(fd, buf, nbytes) _write(fd, buf, nbytes)
extern size_t vmWrite(int fd, void *buf, size_t nbytes);
#define selecx(fd, r, w, x, t) select(fd, r, w, x, t)
#else /* not WIN32 */

#define vmRead(fd, buf, nbytes) read(fd, buf, nbytes)
#define vmWrite(fd, buf, nbytes) write(fd, buf, nbytes)
#ifndef FAKESELECT
#define selecx(fd, r, w, x, t) select(fd, r, w, x, t)
#endif
#endif /* not WIN32 */
#define vmClose(a) close(a)
#define vmSocket(a,b,c) socket(a,b,c)
#define vmAccept(a,b,c) accept(a,b,c)

#else

typedef int NodeAddr;
#define filesizeofNodeAddr sizeof(unsigned)
typedef int semaphore;
#define vmInitThreads() (-1)
#define vmCreateThread(b,c) (-1)
#define vmThreadSleep(a) sleep(a)
#define vmThreadMSleep(a, b) sleep(a)
#define SameNodeAddrHost(a,b) (0)

#define vmMain(a,b) main(a,b)
#define vmOpen(a,b,c) open(a,b,c)
#define vmRead(a,b,c) read(a,b,c)
#define vmWrite(a,b,c) write(a,b,c)
#define vmClose(a) close(a)
#ifdef WIN32
#define vmSocket(a,b,c) xxxxsocket(a,b,c)
#else /* not WIN32 */
#define vmSocket(a,b,c) socket(a,b,c)
#endif /* not WIN32 */
#define vmAccept(a,b,c) accept(a,b,c)

#define WriteNodeAddr(a, b) abort()
#define ReadNodeAddr(a, b) abort()
#define NodeAddrString(x) "a thread"
#endif /* MTHREADS */

#endif /* _EMERALD_THREADS_H */

/* EOF */
