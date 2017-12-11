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

#ifndef _EMERALD_GC_H
#define _EMERALD_GC_H

/*
 * This defines the interface to the garbage collector, a generational
 * copying collector with a stable copying oldspace cleaner.  Stable means
 * that the space held by live objects will not be overwritten during the
 * garbage collection.
 */

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#define WORDS_TO_BYTES(x)   (((int)(x))<<2)
#define BYTES_TO_WORDS(x)   (((int)(x))>>2)

typedef unsigned int word;

#define INITIAL_MOVE_STACK_SIZE 1000

Object *move_stack;
extern int move_stack_size;

extern int heapsize;		/* Heap size in bytes */

/****************************
 *
 *   Objects                
 *
 ****************************/

/*
 * The garbage collector allocates an additional word at the front of each
 * object to store its age.  This field is also used for indicating (by an
 * illegal age of -2) that an object has been moved and the next word is a
 * forwarding pointer.
 */

#define OLD 34
#define NEW 128

extern Object *rem_set;
extern int remNum;

#define REM_INCR  (10240)
#define PTR 0
#define VEC 1

extern int stack_top, stack_bottom;

extern int bytesInThisGeneration;
extern int bytesPerGeneration;
extern int currentAge;
extern int copyCount;

extern int old_size;
extern Object createStub(ConcreteType ct, void *stub, OID oid);

extern int inhibit_gc;
extern void anticipateGC(int howmanybytes);
extern void new_rem_set(Object);
extern void recordSize(Object, int);
extern int wasGCMalloced(void *addr);
extern void doToNewGeneration(void (*f)(Object), void (*cleanup)(void));
extern void doToOldGeneration(void (*f)(Object), word *limit);
extern void doToExternalRoots(void (*pointers_f)(int, Object *), 
		       void (*variable_f)(Object *, ConcreteType *),
		       void (*variables_f)(int, Bits32 *),
		       int destructive,
		       int doFromObjectTable);
extern void push_ms (Object p);
extern int varContainsPointer(ConcreteType ct);

extern unsigned distGCBitToSend(Object o);
extern unsigned distGCSeq, lastCompletedDistGCSeq;
extern int inDistGC(void);
extern void startDistGC(void);
extern void restartDistGC(int);
extern void newGrey(Object);
extern int isGrey(Object);
extern void unavailableObject(Object);
extern void incomingRef(Object, int);
extern void incomingObject(Object);
extern void distGCFreeState(struct State *);
#endif
