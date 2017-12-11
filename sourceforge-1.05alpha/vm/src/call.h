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
#ifndef _EMERALD_CALL_H
#define _EMERALD_CALL_H

#ifndef _EMERALD_IISC_H
#include "iisc.h"
#endif

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

typedef enum { RFine = 0,
	       RInitially = 1,
	       RRemote = 2,
	       RDead = 4 }
    Reason;

extern IISc allfrozen;

extern int isReason(int why, Reason r);
extern int reasonToIndex(int why);

OpVectorElement findOpVectorElement(ConcreteType cp, unsigned int pc);
int findOpVectorIndex(ConcreteType cp, unsigned int pc);
void CallInit(void);
void returnToForeignObject(struct State *state, int answer);
int returnToBrokenObject(struct State *state);
void pushAR(struct State *state, Object obj, ConcreteType ct, int opindex);
void pushBottomAR(struct State *state);
void dependsOn(struct State *, struct State *, int);
struct State *stateFetch(OID oid, Node loc);
extern int isBroken(Object obj);
extern int duringInitialization(Object obj);
extern int findHandler(struct State *state, int name, Object o);
#endif /* _EMERALD_CALL_H */
