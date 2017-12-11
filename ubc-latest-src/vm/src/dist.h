/*
 * dist.h
 */

#ifndef _EMERALD_DIST_H
#define _EMERALD_DIST_H

#ifndef _EMERALD_STORAGE_H
#include "storage.h"
#endif

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#define EMERALDFIRSTPORT 0x3ee3
#define EMERALDPORTSKIP 0x400
#define EMERALDPORTPROBE(n) ((n) + EMERALDPORTSKIP)

char *NodeString(Node);
extern Node myid;

#define SameNodeHost(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port)
#define SameNode(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port && (a).epoch == (b).epoch)

extern void DInit(void);
void DStart(void);

extern int getplane(void);
int DNetStart(unsigned int, unsigned short, unsigned short);
int DSend(Node receiver, void *sbuf, int slen);
int DProd(Node *receiver);
typedef void (*NotifyFunction)(Node id, int isup);
void DRegisterNotify(NotifyFunction);

int InitDist(void);

#ifndef WIN32
#define closesocket(x) close(x)
#endif /* not WIN32 */

#endif /* _EMERALD_DIST_H */
