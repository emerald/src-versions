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

#include "vm.h"
#define UFETCH1(where,ptr,inc) { \
  where = *((unsigned char*)(ptr)); \
  if (inc) (ptr) = (int)(ptr) + 1; \
}
#define UFETCH2(where,ptr,inc) { \
  ptr = (((int)ptr + 1) & ~0x1); \
  where = (*((unsigned short*)ptr)); \
  if (inc) (ptr) = (int)(ptr) + 2; \
  where = ntohs(where); \
}

#define UFETCH4(where,ptr,inc) { \
  ptr = (((int)ptr + 3) & ~0x3); \
  where = (*((unsigned int*)ptr)); \
  if (inc) (ptr) = (int)(ptr) + 4; \
  where = ntohl(where); \
}



#define IFETCH1(where) UFETCH1(where, pc, 1)
#define IFETCH2(where) UFETCH2(where, pc, 1)
#define IFETCH4(where) UFETCH4(where, pc, 1)

#define PUSH(type,value) { \
  *(type *)sp = (value); \
  sp += sizeof(type); \
}
#define  POP(type,value) { \
  sp -= sizeof(type); \
  value = *(type *)sp; \
}
#define  TOP(type,value) { \
  value = *(type *)(sp - sizeof(type)); \
}
#define SETTOP(type,value) { \
  *(type *)(sp - sizeof(type)) = value; \
}
#define FETCH(type,base,offset) \
  (*(type*)((int)(base) + (int)(offset)))
#define STORE(type,base,offset,value) \
  (*(type*)((int)(base) + (int)(offset)) = (value))

typedef int s32;
typedef unsigned int u32;
typedef unsigned short u16;
typedef short s16;
typedef unsigned char u8;
typedef char s8;
typedef float f32;


/* This file should probably be read in -*- c -*- mode. */
/*
 * Jekyll Virtual Machine description file, for use with VMC
 */

#define _EMERALD_VM_I_H
#define E_NEEDS_MATH
#define E_NEEDS_NTOH
#define E_NEEDS_STRING
#include "system.h"
#ifndef max
#define max(x,y) (((x)<(y))?(y):(x))
#endif
#ifndef min
#define min(x,y) (((x)<(y))?(x):(y))
#endif
#define ARGOFF (-24)

#include "trace.h"
#include "assert.h"
#include "rinvoke.h"
#include "globals.h"
#include "iisc.h"
#include "misc.h"
#include "jsys.h"
#include "creation.h"
#include "oidtoobj.h"
#include "squeue.h"
#include "concurr.h"
#include "iset.h"
#include "call.h"
#include "gc.h"

extern ISet allProcesses;
extern SQueue ready;
extern int runningProcesses;
#if defined(SINGLESTEP)
extern int instructionsToExecute, gotsigint;
#if !defined(COUNTBYTECODES)
#define COUNTBYTECODES
#endif
#endif

extern int debug(struct State *state, char *m);
extern int doNCCall(struct State *state);
extern void stoCheck (Object intoObj, Object storedObj);
extern void obsolete(char *name, struct State *state);
extern void setBits(Vector v, int off, int len, u32 val);
extern void ntohBits(Vector v, int off, int len);
extern int invoke(Object obj, ConcreteType ct, int opindex, struct State *state);
extern struct State *newStackChunk(struct State *);
extern void doret(int fp, int sb, int pc, ConcreteType ct);
extern void thaw(Object obj, Reason why);
extern void freeze(Object obj, Reason why);
extern void processMovedOut(struct State *state);
extern void CheckpointToFile(Object o, ConcreteType ct, String file);
extern void gcollect(void);
extern void gcollect_old(void);
extern void docall(int op, int sp, int fp, ConcreteType ct, Object oop, int sb);
extern void docallct(OpVectorElement ove, int sp, int fp, ConcreteType ct, Object oop, int sb);
extern int conforms(AbstractType a, AbstractType b);

extern void createGaggle(OID g);
extern void add_gmember(OID gid, OID newMember);
extern void sendGaggleUpdate(OID moid, OID ooid, OID ctoid, int dead);
extern void loadNGo(String s);
extern void fixObjectReferenceFromSeq(unsigned seq, Object within, int offset);
extern void fixCTLiterals(ConcreteType ct);
extern void stringTok(String s, String brk, int *startp, int *endp);
extern void disassemble(unsigned int ptr, int len, FILE *f);
#ifdef hp700
extern int random(void);
extern int srandom(unsigned int);
#endif
extern int interpret(struct State *);

/* 
 * Compute the offset of a field within a structure.
 */
#define OffsetOf(within, addr) ((char *)(addr) - (char *)(within))

/*
 * macros for load/store operations
 */
#define PF(x,y) PUSH(u32,FETCH(u32,x,y))
#define PS(x,y) POP(u32,v); STORE(u32,x,y,v)
#define LD(x)   u32 t;   IFETCH4(t); PUSH(u32, x)
#define EST(x,y) u32 t,v; IFETCH4(t); PS(x,y)
/* although the immediates we fetch are 16-bits, push a 32 bit result */
#define LDS(x)   s16 t;   IFETCH2(t); PUSH(u32, (u32)(x))
#define STS(x,y) s16 t; u32 v; IFETCH2(t); PS(x,y)
/* although the immediates we fetch are 8-bits, push a 32 bit result */
#define LDB(x)   s8 t;   IFETCH1(t); PUSH(u32, (u32)(x))
#define STB(x,y) s8 t; u32 v; IFETCH1(t); PS(x,y)
/*
 * macros for arithmetic and logic operations
 */
#define UNARY(type,c_op) type a; TOP(type, a); SETTOP(type, c_op a);
#define UNARYZ(type,c_op) type a; TOP(type, a); SETTOP(type, a c_op 0);
#define BINARY(type,c_op) \
  type a, b; POP(type,a); TOP(type,b); SETTOP(type, b c_op a);
/*
 * Miscellany
 */

#define ASSTR(type,fmt) { type a; String s; \
  POP(type, a); sprintf(buf,fmt,a); \
  F_SYNCH(); s = CreateString(buf); F_UNSYNCH(); \
  PUSH(String, s); }

#if defined(TIMESLICE)
#   define CONTEXTSWITCHINVOKES (random() % 200)
#   define CONTEXTSWITCHBRANCHS (random() % 500)
#   define CONTEXTSWITCH					\
	TRACE(process, 3, ("Preempting process %x", state));	\
	SYNCH();						\
	makeReady(state);					\
	return 1;

#   define CHECKSWITCH(count, limit)				\
       if (runningProcesses && (--count < 0)) {			\
	count = limit;						\
	CONTEXTSWITCH						\
      }

#   define TIMESLICELOCALS \
      static int totalinvocs = 50; \
      static int branches = 10;
#else
#   define CHECKSWITCH(a, b)
#   define TIMESLICELOCALS 
#endif /* TIMESLICE */

#define BRANCHCHECKSWITCH CHECKSWITCH(branches, CONTEXTSWITCHBRANCHS)
#define INVOKECHECKSWITCH CHECKSWITCH(totalinvocs, CONTEXTSWITCHINVOKES)

#ifdef SINGLESTEP
#   define DEBUG(m) { \
	       SYNCH(); \
	       if (debug(state, m)) { \
		 return 1; \
	       } else { \
	         UNSYNCH(); \
	       } \
      }
#else
#   define DEBUG(m) { \
	       SYNCH(); \
	       if (debug(state, m)) { \
		 return 1; \
	       } else { \
		 UNSYNCH(); \
	       } \
      }
#endif

#define CHECKNILV(v,m) CHECKNIL(Vector, v, m)
#define CHECKNILS(s,m) CHECKNIL(String, s, m)
#define CHECKNILO(o,m) CHECKNIL(Object, o, m)
#define CHECKNILU(u,m) CHECKNIL(u32, u, m)

#if defined(NEMCHECK)
#   define BOUNDSCHECK(v, i)
#   define CHECKNIL(t, v, m)
#else
#   define BOUNDSCHECK(v, i)					\
      if (i < 0 || i >= (v)->d.items) {				\
	sprintf(buf, "Subscript %d out of range [0:%d] on access to %.*s", \
		i, (v)->d.items - 1,				\
		CODEPTR(v->flags)->d.name->d.items,		\
		(char *)CODEPTR(v->flags)->d.name->d.data);	\
	DEBUG(buf);						\
	continue;						\
      }
#   define CHECKNIL(t, v, m) if (ISNIL(v)) DEBUG(m);
#endif

#if defined(PROFILEINVOKES)
#   define TOPOFTHEINTERPRETLOOPA if (doInvokeProfiling) ++*currentOPECount;
#   define PROFILEBUMP(pc,ove,a) if (doInvokeProfiling) profileBump(pc,ove,a)
#   define PROFILERET() profileRet()
#else
#   define TOPOFTHEINTERPRETLOOPA
#   define PROFILEBUMP(pc,ove,a) 
#   define PROFILERET()
#endif

#define TOPOFTHEINTERPRETLOOPB 
#if defined(SINGLESTEP)
#   define TOPOFTHEINTERPRETLOOPC \
	if (instructionsToExecute > 0 && addtototalbytecodes >= instructionsToExecute) { DEBUG(gotsigint ? "Interrupt" : "Single step"); }
#else
#   define TOPOFTHEINTERPRETLOOPC
#endif

#define TOPOFTHEINTERPRETLOOP \
  TOPOFTHEINTERPRETLOOPA \
  TOPOFTHEINTERPRETLOOPB \
  TOPOFTHEINTERPRETLOOPC

#ifdef SINGLESTEP
#   define INTERPRETERLOCALS \
      u32 opoid; \
      char buf[80]; \
      TIMESLICELOCALS
#else
#   define INTERPRETERLOCALS \
      u32 opoid; \
      char buf[80]; \
      TIMESLICELOCALS
#endif /* SINGLESTEP */


#define NINSTRUCTIONS 185
typedef struct State {
  u32 firstThing;
  u32 pc;
  u32 sp;		/* Stack pointer */
  u32 fp;		/* Frame pointer */
  u32 sb;		/* Stack base */
  Object op;		/* Object pointer */
  ConcreteType cp;		/* Concrete type */
  Object ep;		/* Environment pointer */
  ConcreteType et;		/* Environment type */
  OID nsoid;		/* Next SS OID */
  OID nstoid;		/* Next target OID */
  OID psoid;		/* Prev SS OID */
  u32 psnres;		/* Results to return */
} State;
#define F_SYNCH() (\
  state->sp = sp,\
  state->fp = fp,\
  state->op = op,\
  state->cp = cp,\
  state->pc = pc)
#define F_UNSYNCH() (\
  sp = state->sp,\
  fp = state->fp,\
  op = state->op,\
  cp = state->cp,\
  pc = state->pc )
#ifdef COUNTBYTECODES
#define SYNCH() (\
  F_SYNCH(),\
  totalbytecodes += addtototalbytecodes, \
  addtototalbytecodes = 0 )
#define UNSYNCH() (\
  F_UNSYNCH(),\
  addtototalbytecodes = 0 )
#else /* COUNTBYTECODES */
#define SYNCH() (\
  state->sp = sp,\
  state->fp = fp,\
  state->op = op,\
  state->cp = cp,\
  state->pc = pc)
#define UNSYNCH() (\
  sp = state->sp,\
  fp = state->fp,\
  op = state->op,\
  cp = state->cp,\
  pc = state->pc )
#endif
