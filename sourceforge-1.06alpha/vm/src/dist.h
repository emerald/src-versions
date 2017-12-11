/*
 * The Emerald Distributed Programming Language
 * 
 * Copyright (C) 2004 Emerald Authors & Contributors
 * 
 * This file is part of the Emerald Distributed Programming Language.
 *
 * The Emerald Distributed Programming Language is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 *  The Emerald Distributed Programming Language is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the Emerald Distributed Programming Language; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

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
#define EMERALDPORTSKIP 0x100
#define EMERALDPORTPROBE(n) ((n) + EMERALDPORTSKIP)

char *NodeString(Node);
extern Node myid;

#define SameNodeHost(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port)
#define SameNode(a,b) ((a).ipaddress == (b).ipaddress && (a).port == (b).port && (a).epoch == (b).epoch)

extern void DInit(void);
void DStart(void);

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
