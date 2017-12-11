#ifndef _EMERALD_MTHREADS_H
#define _EMERALD_MTHREADS_H
#pragma warning(disable: 4068)
#pragma pointer_size save
#pragma pointer_size long
#include <sys/types.h>

#ifndef WIN32
#include <sys/time.h>
#include <stdarg.h>
#include <sys/socket.h>
#include <netinet/in.h>
#endif
#pragma pointer_size restore

#ifdef WIN32
#ifdef MSVC40
#include <winsock.h>
#else
#include <winsock2.h>
#endif
#endif

typedef struct NodeAddr {
  unsigned int ipaddress;
  unsigned short port;
  unsigned short incarnation;
} NodeAddr;

extern void MTInit(void);
void MTStart(void);

void MTRegisterExitRoutine(void (*)(void));

int MTNetStart(unsigned int, unsigned short, unsigned short);
int MTSend(NodeAddr receiver, void *sbuf, int slen);
int MTProd(NodeAddr *receiver);
typedef void (*NotifyFunction)(NodeAddr id, int isup);
void MTRegisterNotify(NotifyFunction);
#endif /* _EMERALD_MTHREADS_H */
