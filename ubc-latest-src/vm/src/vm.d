{/* This file should probably be read in -*- c -*- mode. */
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

#define prevOP(xx) ((Object)((u32 *)xx)[-3])
}


@ Design decisions:
@   When variables are pushed on the stack, they are pushed data then AbCon
@   Object creations push a code pointer, and return an object pointer
@   An activation record looks like:
@
@	return value 1	(variable)	8
@	...
@	return value n	(variable)	8
@	argument     1	(variable)	8
@	...
@	argument     n	(variable)	8     <-- fp - ARGOFF 
@       saved cp                        4
@	saved op			4
@	saved fp			4
@	saved pc			4
@	local 1		(whatever)	?     <--- new fp
@	...
@	local n		(whatever)	?
@
@

State:
@	implicit registers include:
@	pc	"Program counter"	"u32"
@	my explicit registers:
	sp	"Stack pointer"		"u32"
	fp	"Frame pointer"		"u32"
	_sb     "Stack base"            "u32"
	op	"Object pointer"	"Object"
	cp	"Concrete type"		"ConcreteType"
	_opp	"Operation pointer"	"OpVectorElement"
	_ep	"Environment pointer"	"Object"
	_et	"Environment type"	"ConcreteType"
	_nsoid	"Next SS OID"		"OID"
	_nstoid	"Next target OID"	"OID"
	_psoid	"Prev SS OID"		"OID"
	_psnres	"Results to return"	"u32"

Interrupts:
	IO	{ microcode ... }
	INT	{ microcode ... }

Instructions:
@ Most load instructions use an implicit temporary t, which is the
@ argument to the load instruction.
    LDI "u32"	{ LD(t); }
@ Load a relative address.
    LDIR "u32"	{ LD(FETCH(u32,pc,t)); }
@ Load a local variable.
    LDL "u32"	{ LD(FETCH(u32,fp,t)); }
    LDO "u32"	{ LD(FETCH(u32,op,t)); }
@ Load an argument.
    LDA "u32"	{ LD(FETCH(u32,fp,-(int)t+ARGOFF)); }
@ general purpose escape to the system
    NCCALL "u8u8"  {
		  int res;
		  SYNCH();
		  res = doNCCall(state);
		  if (res) return 1;
		  UNSYNCH();
		}
    STL "u32"	{ EST(fp,t); }
    STO "u32"	{ EST(op,t); stoCheck(op, (Object)v); }
    STA "u32"	{ EST(fp,-(int)t+ARGOFF); }

    LDVL "u32"	{ LD(FETCH(u32,fp,t)); PF(fp,t+4); }
    LDVO "u32"	{ LD(FETCH(u32,op,t)); PF(op,t+4); }
    LDVA "u32"	{ LD(FETCH(u32,fp,-(int)t+ARGOFF)); PF(fp,-(int)t+ARGOFF+4); }
    STVL "u32"	{ EST(fp,t+4); PS(fp,t); }
    STVO "u32"	{ EST(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
    STVA "u32"	{ EST(fp,-(int)t+ARGOFF+4); PS(fp,-(int)t+ARGOFF); }

@ 16-bit versions of the loads and stores; branches are already 16-bit ops
@ These use a 16-bit immediate offset but otherwise deal in 32-bit entities
    LDIS "s16"	{ LDS(t); }
    FPOW ""	{ f32 a, b; POP(f32,a); TOP(f32, b); SETTOP(f32, (float)pow((double)b, (double)a)); }
    LDLS "s16"	{ LDS(FETCH(u32,fp,t)); }
    LDOS "s16"	{ LDS(FETCH(u32,op,t)); }
    LDAS "s16"	{ LDS(FETCH(u32,fp,-t+ARGOFF)); }

    STLS "s16"	{ STS(fp,t); }
    STOS "s16"	{ STS(op,t); stoCheck(op, (Object)v); }
    STAS "s16"	{ STS(fp,-t+ARGOFF); }

    LDVLS "s16"	{ LDS(FETCH(u32,fp,t)); PF(fp,t+4); }
    LDVOS "s16"	{ LDS(FETCH(u32,op,t)); PF(op,t+4); }
    LDVAS "s16"	{ LDS(FETCH(u32,fp,-t+ARGOFF)); PF(fp,-t+ARGOFF+4); }
    STVLS "s16"	{ STS(fp,t+4); PS(fp,t); }
    STVOS "s16"	{ STS(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
    STVAS "s16"	{ STS(fp,-t+ARGOFF+4); PS(fp,-t+ARGOFF); }

@ 8-bit versions of the loads and stores; branches are already 8-bit ops
@ These use a 8-bit immediate offset but otherwise deal in 32-bit entities
    LDIB "s8"	{ LDB(t); }
    ISTRX ""    { ASSTR(s32,"%08x"); }
    LDLB "s8"	{ LDB(FETCH(u32,fp,t)); }
    LDOB "s8"	{ LDB(FETCH(u32,op,t)); }
    LDAB "s8"	{ LDB(FETCH(u32,fp,-t+ARGOFF)); }

    STLB "s8"	{ STB(fp,t); }
    STOB "s8"	{ STB(op,t); stoCheck(op, (Object)v); }
    STAB "s8"	{ STB(fp,-t+ARGOFF); }

    LDVLB "s8"	{ LDB(FETCH(u32,fp,t)); PF(fp,t+4); }
    LDVOB "s8"	{ LDB(FETCH(u32,op,t));
		  PF(op,t+4); }
    LDVAB "s8"	{ LDB(FETCH(u32,fp,-t+ARGOFF)); PF(fp,-t+ARGOFF+4); }
    STVLB "s8"	{ STB(fp,t+4); PS(fp,t); }
    STVOB "s8"	{ STB(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
    STVAB "s8"	{ STB(fp,-t+ARGOFF+4); PS(fp,-t+ARGOFF); }

@ Miscellaneous stack machine operations
    DUP   ""    { u32 a;   POP(u32,a); PUSH(u32,a); PUSH(u32,a); }
    ENSURESPACE  ""    {
      int size;
      POP(unsigned, size);
      F_SYNCH();
      ensureSpace(size + 32);
      F_UNSYNCH();
    }
    SWAP  ""    { SYNCH(); obsolete("SWAP", state); }

@ Arithmetic operations find operands on the stack, and push the result
@ Floating point versions are preceded by F
@ String versions are preceded by S
    ADD ""	{ BINARY(s32,+) }
    SUB ""	{ BINARY(s32,-) }
    MUL ""	{ BINARY(s32,*) }
    DIV ""	{ BINARY(s32,/) }
    MOD ""	{ BINARY(s32,%) }
    NEG ""      {  UNARY(s32,-) }
    FADD ""	{ BINARY(f32,+) }
    FSUB ""	{ BINARY(f32,-) }
    FMUL ""	{ BINARY(f32,*) }
    FDIV ""	{ BINARY(f32,/) }
    FNEG ""     {  UNARY(f32,-) }
@ Comparison operations
    EQ  ""      { UNARYZ(s32,==) }
    NE  ""      { UNARYZ(s32,!=) }
    GT  ""      { UNARYZ(s32,> ) }
    GE  ""      { UNARYZ(s32,>=) }
    LT  ""      { UNARYZ(s32,< ) }
    LE  ""      { UNARYZ(s32,<=) }
@   ICMP is now called SUB!
    FCMP ""     {
                  f32 a, b;
		  POP(f32,b); POP(f32,a);
		  a = a-b;
		  PUSH(s32,((a>0)?1:((a<0)?(-1):0)));
		}
    SCMP ""     {
                  String a, b;
		  int i;
		  POP(String,b);
		  POP(String,a);
		  CHECKNILS(b, "SCMP on a string which is nil");
		  CHECKNILS(a, "SCMP on a string which is nil");
		  i = memcmp((char *)a->d.data, (char *)b->d.data,min(a->d.items,b->d.items));
		  if (!i) i = a->d.items - b->d.items;
		  PUSH(s32,i);
                }
@ Logical operations
    AND ""      { BINARY(s32,&&) }
    OR  ""      { BINARY(s32,||) }
    NOT ""      {  UNARY(s32, !) }
    ASSERT ""   { s32 a; POP(s32,a);
                  if(!a) DEBUG("Assertion failed");
                }
@ Conversions
    CSTR ""     { s32 a;
                  String s;

                  POP(s32,a);
		  F_SYNCH();
		  s = (String)CreateVector(BuiltinInstCT(STRINGI),1);
		  F_UNSYNCH();
                  s->d.items = 1;
		  s->d.data[0] = (char)a;
		  PUSH(String,s);
                }
    FINT ""     { f32 a; POP(f32,a); PUSH(s32,(s32)a); }
    IFLO ""     { s32 a; POP(s32,a); PUSH(f32,(f32)a); }
    ISTR ""     { ASSTR(s32,"%d"); }
    FSTR ""     { ASSTR(f32,"%g"); }
    EBSTR ""     { s32 a;
		  POP(s32,a);
		  PUSH(String, (a?TrueString:FalseString));
                }
@ Bitchunk operations
@
@ At the moment, these are only defined for lengths <= 32.
     BGETS ""      {
                     u32 off, len;
		     s32 temp;
		     Vector v;

                     POP(u32,len);
                     POP(u32,off);
                     POP(Vector,v);
		     CHECKNILV(v, "BGETS on nil");
		     temp = ((int *)v->d.data)[off >> 5];
		     temp = temp << (off & 31);
		     temp = temp >> (32 - len);
		     PUSH(u32,temp);
                   }
     BGETU ""      {
                     u32 off, len;
		     u32 temp;
		     Vector v;

                     POP(u32,len);
                     POP(u32,off);
                     POP(Vector,v);
		     CHECKNILV(v, "BGETU on nil");
		     temp = ((int *)v->d.data)[off >> 5];
		     temp = temp << (off & 31);
		     temp = temp >> (32 - len);
		     PUSH(u32,temp);
                   }
     BSET  ""      {
                     u32 off, len;
		     u32 setval;
		     Vector v;

		     POP(u32, setval);
                     POP(u32,len);
                     POP(u32,off);
                     POP(Vector,v);
		     CHECKNILV(v, "BSET on nil");
		     setBits(v, off, len, setval);
                   }
     NTOH  ""      {
                     u32 off, len;
		     Vector v;

                     POP(u32,len);
                     POP(u32,off);
                     POP(Vector,v);
		     CHECKNILV(v, "NTOH on nil");
		     ntohBits(v, off, len);
                   }
@ Vector operations
     GETB   ""     {
                     Vector v;
                     s32 i;

                     POP(s32,i);
                     POP(Vector,v);
		     CHECKNILV(v, "GETB on a vector which is nil");
		     BOUNDSCHECK(v, i);
		     PUSH(s32,(s32)(v->d.data[i]));
                   }
     GET    ""     {
                     Vector o1;
		     s32 i, v;
		     ConcreteType ct;

		     POP(s32,i);
		     POP(Vector,o1);
		     CHECKNILV(o1, "GET on a vector which is nil");
		     ct = CODEPTR(o1->flags);
		     BOUNDSCHECK(o1, i);
		     if (ct->d.instanceSize == -1 || ct->d.instanceSize == 1) {
		       v = o1->d.data[i];
		     } else {
		       v = *(((s32 *)(o1->d.data)) + i);
		     }
		     PUSH(s32, v);
                   }
     GETV   ""     {
                     Vector o1;
		     s32 i, *p;
		     POP(s32,i);
		     POP(Vector,o1);

		     CHECKNILV(o1, "GETV on a vector which is nil");
		     BOUNDSCHECK(o1, i);
                     p = (((s32 *)(o1->d.data)) + (i<<1));
		     PUSH(s32,*p++);
		     PUSH(s32,*p);
                   }
     SET    ""     {
                     Vector o1;
		     s32 i, o;
		     ConcreteType ct, valct;
		     POP(s32,o);
		     POP(s32,i);
		     POP(Vector,o1);
		     CHECKNILV(o1, "SET on a vector which is nil");
		     ct = CODEPTR(o1->flags);
		     BOUNDSCHECK(o1, i);
		     stoCheck((Object)o1, (Object)o);
		     if (ct->d.instanceSize == -1 || ct->d.instanceSize == 1) {
		       o1->d.data[i] = o;
		     } else if (ct->d.instanceSize == -4 || ct->d.instanceSize == 4) {
		       *(s32 *)(&(o1->d.data[i<<2])) = o;
		     } else {
		       assert(ct->d.instanceSize == -8 || ct->d.instanceSize == 8);
		       /* We have to be in the SET in IVec.Literal */
		       if (ISNIL(o)) {
			 valct = (ConcreteType)JNIL;
		       } else {
			 valct = CODEPTR(((Object)o)->flags);
		       }
		       stoCheck((Object)o1, (Object)valct);
		       ((u32 *)o1->d.data)[i * 2] = o;
		       ((ConcreteType *)o1->d.data)[i * 2 + 1] = valct;
		     }
                   }
     SETV    ""    {
                     Vector o1;
		     u32 ct, o;
		     s32 i;
		     POP(u32, ct);
		     POP(u32, o);
		     POP(s32, i);
		     POP(Vector, o1);
		     CHECKNILV(o1, "SETV on a vector which is nil");
		     BOUNDSCHECK(o1, i);
		     stoCheck((Object)o1, (Object)o);
		     stoCheck((Object)o1, (Object)ct);
		     ((u32 *)o1->d.data)[i * 2] = o;
		     ((u32 *)o1->d.data)[i * 2 + 1] = ct;
                   }

@ As defined here, slice ops are object : startindex : numbertoslice
     GSLICE ""     {
                     Vector o1, o2;
		     s32 index, number;
		     ConcreteType t1;
                     POP(s32, number);
                     POP(s32, index);
		     POP(Vector,o1);
		     CHECKNILV(o1, "GSLICE on a vector which is nil");
		     if (number > 0) {
		       BOUNDSCHECK(o1, index);
		       BOUNDSCHECK(o1, index + number - 1);
		     }
		     t1 = CODEPTR(o1->flags);
		     regRoot(o1);
		     regRoot(t1);
		     F_SYNCH();
		     o2 = CreateVector(t1, number);
		     F_UNSYNCH();
		     unregRoot();
		     unregRoot();
#define abs(x) (((x)<0)?-(x):(x))
		     index *= abs(t1->d.instanceSize);
		     number *= abs(t1->d.instanceSize);
#undef abs
		     memmove(o2->d.data, &(o1->d.data[index]), number);
		     PUSH(Vector,o2);
                   }
     SETLOCSRV ""   {
		      Object newlocsrv;
		      POP(Object, newlocsrv);
		      if (ISNIL(locsrv)) {
			locsrv = newlocsrv;
		      }
                    }
     CAT    ""     {
                     Vector o1, o2, o3;
		     int size;
		     ConcreteType t1; /* assumed identical for o1, o2 */
		     POP(Vector,o2);
		     POP(Vector,o1);
		     CHECKNILV(o1, "CAT on a vector which is nil");
		     CHECKNILV(o2, "CAT with an argument vector which is nil");
		     CHECKNILV(o1->flags, "CAT with an argument vector which is scrambled");
		     CHECKNILV(o2->flags, "CAT with an argument vector which is scrambled");
		     t1 = CODEPTR(o1->flags);
		     if (HASINITIALLY(t1)) DEBUG("Cat on a funny CT");
		     regRoot(o1);
		     regRoot(o2);
		     regRoot(t1);
		     F_SYNCH();
		     o3 = (Vector)CreateVector(t1, o1->d.items + o2->d.items);
		     F_UNSYNCH();
		     unregRoot();
		     unregRoot();
		     unregRoot();
#define abs(x) (((x)<0)?-(x):(x))
		     size = abs(t1->d.instanceSize);
#undef abs
		     memmove(o3->d.data, o1->d.data, o1->d.items * size);
		     memmove(o3->d.data+(o1->d.items * size), o2->d.data,
			   o2->d.items * size);
		     PUSH(Vector,o3);
                   }
     LEN   ""     {
                    Vector o1;
		    POP(Vector,o1);
		    CHECKNILV(o1,"LEN on a vector which is nil");
		    PUSH(s32,o1->d.items);
                  }

@ Call finds the target object on the stack, and the operation number as an
@ immediate operand.  Call is only used under USEABCONS
    SETDEBUGGER ""  {
		      Object newdebugger;
		      POP(Object, newdebugger);
		      if (ISNIL(debugger)) {
			debugger = newdebugger;
		      }
                    }
@ Calloid finds the target object on the stack, and the operation oid as an
@ immediate operand (4 bytes)
    CALLOID "u32" {
      int opindex;
      ConcreteType a;
      Object o;
      IFETCH4(opoid);
restofcalloid: ;

      POP(ConcreteType, a);
      POP(Object, o);

      if (ISNIL(a)) { 
	(opindex) = 0; 
      } else { 
	OpVector ov = (a)->d.opVector;
	OpVectorElement ope;
	int i;
	(opindex) = 0;
	for (i = 3; i < ov->d.items; i++) {
	  ope = ov->d.data[i];
	  if (ope->d.id == (opoid)) {
	    (opindex) = i; 
	    break;
	  }
	}
	if ((opindex) == 0){
	  TRACE(interpret, 0, ("FindCode: op %s id %d undefined for ct %.*s (0x%08x)",
		  OperationName(opoid),(opoid),
		  (a)->d.name->d.items,
		  (a)->d.name->d.data,
		  (u32)(a)));
	  DEBUG("");
	}
      }
      SYNCH();
      if (invoke(o, a, opindex, state)) {
	return 1;
      } else {
	UNSYNCH();
	INVOKECHECKSWITCH;
      }
    }
    LINK "u16"	{
		  /* allocate space for locals */
		  u16 space;
		  IFETCH2(space);
		  space /= 4;
		  if (sp + space * 4 + 200 > sb + stackSize) {
		    SYNCH();
		    state = newStackChunk(state);
		    UNSYNCH();
		  }
		  for (; space; space--) {
		    *(int *)sp = JNIL;
		    sp += 4;
		  }
    		}
    LINKB "u8"	{
		  /* allocate space for locals, in words! */
		  u32 space;
		  IFETCH1(space);
		  if (sp + space * 4 + 200 > sb + stackSize) {
		    SYNCH();
		    state = newStackChunk(state);
		    UNSYNCH();
		  }
		  for (; space; space--) {
		    *(int *)sp = JNIL;
		    sp += 4;
		  }
    		}
    RET "u8"	{
		  u8 nargs;
		  ConcreteType xcp;

		  IFETCH1(nargs);
		  PROFILERET();

		  xcp = cp;
		  sp = fp;
		  POP(u32, pc);
		  POP(u32, fp);
		  POP(Object, op);
		  POP(ConcreteType, cp);
		  opp = (OpVectorElement)JNIL;
		  IFTRACE(call, 1) {
		    doret(fp, sb, pc, xcp);
		  }
		  sp -= (nargs * 2 * sizeof(u32));
#ifdef DISTRIBUTED
		  if (BROKEN(op->flags)) {
		    SYNCH();
		    if (!RESDNT(op->flags)) {
		      /* It left */
		      returnToForeignObject(state, JNIL);
		      return 1;
		    } else if (isBroken(op) && returnToBrokenObject(state)) {
		      return 1;
		    } else {
		      UNSYNCH();
		    }
		  }
#endif
		}
    QUIT "u8"	{ 
                  u8 nargs;
		  Object xop;
		  ConcreteType xcp;
		  IFETCH1(nargs);

		  PROFILERET();
		  thaw(op, RInitially);

		  xcp = cp; xop = op; sp = fp;
		  POP(u32, pc);
		  POP(u32, fp);
		  POP(Object, op);
		  POP(ConcreteType, cp);
		  IFTRACE(call, 1) {
		    doret(fp, sb, -1, xcp);
		  }
		  sp -= (nargs * 2 * sizeof(u32));

		  TRACE( initiallies, 1,
			( "QUIT at sb=%#x, sp=%#x in object %#x (%.*s)",
			 sb, sp, xop, xcp->d.name->d.items, xcp->d.name->d.data ) );

		  if (HASPROCESS(xcp)) {
		    TRACE(process, 1,
			  ("QUIT forking process in object %#x (%.*s)",
			   xop, xcp->d.name->d.items, xcp->d.name->d.data ) );
		    run(xop, OVE_PROCESS, 1);
		  } 
		}
    GETLOCSRV "" { 
  		  Object o;
		  o = locsrv;
		  PUSH(Object, o);
		  if (ISNIL(o)) {
		    PUSH(ConcreteType, (ConcreteType)JNIL);
		  } else {
		    PUSH(ConcreteType, CODEPTR(o->flags));
		  }
		 }
    CREATE ""	{
                  ConcreteType p;
		  Object o;
		  OpVectorElement ove;

		  POP(ConcreteType, p);
		  F_SYNCH();
		  regRoot(p);
                  o = (Object) gc_malloc(sizeofObject + p->d.instanceSize);
		  unregRoot();
                  SETRESDNT(o->flags);
                  SETCODEPTR(o->flags, p);
		  if (inDistGC()) SETDISTGC(o->flags);

		  ove = p->d.opVector->d.data[OVE_INITIALLY];
		  if (ISNIL(ove)) {
		    STORE(Object, sp, -4, o);
		    if (HASPROCESS(p)) {
		      TRACE( process, 1,
			    ( "CREATE invoking process in object %#x (%.*s)",
			     o, p->d.name->d.items, p->d.name->d.data ) );
		      run(o, OVE_PROCESS, 1);
		    }
		  } else {
		    STORE(Object, sp, -(4 + ove->d.nargs * 8), o);
		    freeze(o, RInitially);
		    TRACE( initiallies, 1,
			  ( "CREATE invoking initially in object %#x (%.*s)",
			   o, p->d.name->d.items, p->d.name->d.data ) );
		    IFTRACE(call, 1) { docall(-1, sp, fp, p, o, sb); }
		    pushAR(state, o, p, OVE_INITIALLY);
		  }
		  F_UNSYNCH();
	        }
    CREATEVEC ""  {
                  ConcreteType p;
		  Vector o;
		  unsigned n;
                  int is;

		  POP(unsigned, n);
		  POP(ConcreteType, p);
                  is = (p->d.instanceSize < 0 ?
                	-p->d.instanceSize : p->d.instanceSize);
		  regRoot(p);
		  F_SYNCH();
                  o = (Vector) gc_malloc(sizeofObject + n * is + sizeof(int));
		  F_UNSYNCH();
		  unregRoot();
                  SETRESDNT(o->flags);
                  SETCODEPTR(o->flags, p);
		  if (inDistGC()) SETDISTGC(o->flags);
                  if (HASINITIALLY(p)) DEBUG("Create vec on a funny CT");
                  o->d.items = n;
		  SETTOP(Vector, o);
		}
@ Terminate a process
    QUITP ""    { 
      extern State *processDone(State *, int);
      if (TRACING(call, 1)) doret(fp, sb, -2, cp);
      SYNCH(); 
      TRACE( process, 2,
	    ( "End of process in object %#x (%.*s)", state->op,
	     state->cp->d.name->d.items, state->cp->d.name->d.data ) );
      if ((state = processDone(state, 0))) {
	makeReady(state);
      }
      return 0;
    }		   
@ branching instructions
    BR "s16"	{ s16 o; IFETCH2(o); pc += o; if (o < 0) BRANCHCHECKSWITCH;}
    BRT "s16"	{ s16 o; u32 t; IFETCH2(o); POP(u32, t);
		  if (t) pc += o; }
    BRF "s16"	{ s16 o; u32 f; IFETCH2(o); POP(u32, f);
		  if (!f) pc += o; }
    CASE "case32"	{ s16 low, high, off; s32 v;
    		  IFETCH2(low); 
		  IFETCH2(high);
		  POP(s32, v);
		  v -= low; high -= low;
		  if (v < 0 || v > high) v = high + 1;
		  pc += v * 2;
		  IFETCH2(off);
		  pc += off;
		  BRANCHCHECKSWITCH;
		}
    TRAPF ""	{ u32 t; POP(u32, t); if (!t) DEBUG("Assertion failure"); }
    RETFAIL "u8"{ DEBUG("Return and fail"); }
    LDSELF ""	{ PUSH(Object, op); }
    LDSELFV ""	{ 
		  PUSH(Object, op);
#ifdef USEABCONS
		  if (ISNIL(cp->d.type)) {
		    PUSH(AbCon, findConCon(cp));
		  } else {
		    PUSH(AbCon, findAbCon(OIDOf(cp->d.type), OIDOf(cp)));
		  }
#else
		  PUSH(ConcreteType, cp); 
#endif
		}
    PUSHNIL ""  { PUSH(u32, 0x80000000); }
    PUSHNILV ""  { PUSH(u32, 0x80000000); PUSH(u32, 0x80000000); }
@ Throw away top of stack.
    POOP      "" { u32 t; POP(u32, t); }
@ general purpose escape to the system
    SYS "u8u8"   {
                  s32 rv, sysindex, ac;
                  /* Fetch the operation and number of args from the
		     instruction stream. */
		  IFETCH1(sysindex);
		  IFETCH1(ac);
		  if (sysindex < 0 || sysindex >= JSYS_OPS) {
		    sprintf(buf, "Illegal sys index %d (ac = %d)", 
			    sysindex, ac);
		    DEBUG(buf);
		    continue;
		  }
		  /* Change the stack so the arguments are above the
		     stack pointer. */
		  sp -= (ac<<2);
		  SYNCH();
		  /* Call the actual code for the operation. */
  		  rv = sysfuncs[sysindex](state);
		  switch (rv) {
		  case 0:
		    UNSYNCH();
		    break;
		  case 1:
		    return 1;
		    break;
		  case 0x1000:
		    sprintf( buf, "exception in JSYS %d", sysindex );
		    DEBUG( buf );
		    break;
		  default:
		    assert(0);
		    break;
		  }
		}
@ Environment manipulation
    GETENV ""	{
		  PUSH(Object, ep);
		  PUSH(ConcreteType, et);
		}
    SETENV ""	{
		  POP(ConcreteType, et);
		  POP(Object, ep);
		}
    STRI ""	{
		  String s;
		  s32 x;
		  POP(String, s);
		  CHECKNILS(s, "Nil in STRI");
		  memmove(buf, s->d.data, s->d.items);
		  buf[s->d.items] = '\0';
		  x = mstrtol(buf, 0, 0);
		  PUSH(s32, x);
    		}
    CREATEVECLIT "" {
                      ConcreteType p;
		      Vector o;
		      unsigned n, e, est;
		      int i;

		      POP(unsigned, n);
		      POP(ConcreteType, p);
		      regRoot(p);
		      F_SYNCH();
		      o = CreateVector(p,n);
		      F_UNSYNCH();
		      unregRoot();
		      for (i = n-1; i >= 0; i--) {
			switch (p->d.instanceSize) {
			case 1:
			case -1:
			  POP(u32, e);
			  o->d.data[i] = e;
			  break;
			case -4:
			case 4:
			  POP(u32, e);
			  *(s32 *)(&(o->d.data[i<<2])) = e;
			  break;
			case -8:
			case 8:
			  POP(u32, est);
			  POP(u32, e);
			  *(s32 *)(&(o->d.data[i<<3])) = e;
			  *(s32 *)(&(o->d.data[(i<<3) + 4])) = est;
			  break;
			default:
			  DEBUG("Bogus size of vector elements");
			  goto nextInstruction;
			  break;
			}
		      }
		      PUSH(Vector, o);
nextInstruction: ;
		    }
    STRHASH ""	{
		  String s;
		  u32 h = 0, g, i, l;
		  POP(String, s);
		  CHECKNILS(s, "Nil in STRHASH");
		  l = s->d.items;
		  for (i = 0; i < l; i++) {
		    h = (h << 4) + s->d.data[i];
		    if ((g = h & 0xf0000000)) {
		      h = h ^ (g >> 24);
		      h = h ^ g;
		    }
		  }
		  h = h & 0x7fffffff;
		  PUSH(u32, h);
    		}
@
@ "Boring stuff" above this point.  "Research" starts here.
@
    BREAKME ""  {
		  Object o;
		  extern void breakObject(Object o);
		  POP(Object, o);
		  breakObject(o);
		  if (o == op) DEBUG("Breakme executed");
		}
@ Acptblck is blocking selective method acceptance

  ACPTBLCK "" {
		AbstractType acceptable;
		State *otherstate;
		monitor *m = (monitor *)((Object) op)->d;

		POP(AbstractType, acceptable);
		otherstate = findAcceptable(m->waiting, acceptable);
		if (!otherstate) {
		  m->busy = 2;
		  PUSH(AbstractType, acceptable);
		  pc --;
		  SYNCH();
		  if (!m->waiting) m->waiting = SQueueCreate();
		  SQueueInsertFront(m->waiting, state);
		  TRACE(process, 3, ("Blocking synchronizing process %#x", state));
		  return 1;
		} else {
		  m->busy = 3;
		  SYNCH();
		  assert(m->waiting);
		  SQueueInsertFront(m->waiting, state);
		  TRACE(process, 3, ("Synchronizing process accepted state %#x", otherstate));
		  state = otherstate;
		  UNSYNCH();
		}
	      }
 
    BREAKPT "" {
		 DEBUG("Breakpoint");
    	       }
    UPB   ""     {
                    Vector o1;
		    POP(Vector,o1);
		    CHECKNILV(o1, "Nil in UPB");
		    PUSH(s32,o1->d.items-1);
                  }
    STRLIT ""  {
                 Vector v;
		 String o;
		 u32 off, length;
		 POP(u32, length);
		 POP(u32, off);
		 POP(Vector, v);
		 CHECKNILV(v, "Nil in STRLIT");
		 regRoot(v);
		 F_SYNCH();
		 o = (String)CreateVector(BuiltinInstCT(STRINGI),length);
		 F_UNSYNCH();
		 unregRoot();
		 memmove(&o->d.data[0], &v->d.data[off], length);
		 PUSH(String, o);
	       }
    LDINDS "u16" {
                   Object o;

		   POP(Object, o);
		   CHECKNILO(o, "Nil invoked (LDINDS)");
		   {
		     LDS(FETCH(u32, (int) o, t));
		   }
		 }
    LDVINDS "u16" {
		   u32 v;
		   POP(u32, v);
		   CHECKNILU(v, "Nil invoked (LDVINDS)");
		   {
		     LDS(FETCH(u32,v,t));
		     PF(v, t+4);
		   }
		 }
    PUSHCT ""	{
		  Object o;
		  ConcreteType xct;
		  TOP(Object, o);
		  if (ISNIL(o)) {
		    PUSH(ConcreteType, (ConcreteType)JNIL);
		  } else {
 		    xct = CODEPTR(o->flags);
		    assert(xct);
#ifdef USEABCONS
		    if (ISNIL(xct->d.type)) {
		      PUSH(AbCon, findConCon(xct));
		    } else {
		      PUSH(AbCon, findAbCon(OIDOf(xct->d.type), OIDOf(xct)));
		    }
#else
		    PUSH(ConcreteType, xct);
#endif
		  }
		}
    STRF ""	{
		  String s;
		  float x;
		  POP(String, s);
		  CHECKNILS(s, "Nil in STRF");
		  memmove(buf, s->d.data, s->d.items);
		  buf[s->d.items] = '\0';
		  x = (float)atof(buf);
		  PUSH(float, x);
    		}
    XCREATE ""	{
                  ConcreteType p;
		  Vector v;
		  Object o;
		  int i;
		  OpVectorElement ove;

		  POP(Vector, v);
		  POP(ConcreteType, p);
		  regRoot(v);
		  regRoot(p);
		  F_SYNCH();
                  o = (Object) gc_malloc(sizeofObject + p->d.instanceSize);
		  F_UNSYNCH();
		  unregRoot();
		  unregRoot();
                  SETRESDNT(o->flags);
                  SETCODEPTR(o->flags, p);
		  if (inDistGC()) SETDISTGC(o->flags);
		  PUSH(Object, o);
		  ove = p->d.opVector->d.data[OVE_INITIALLY];
		  /* I really should push the concrete type too, but this */
		  /* would break where we use XCREATE for now */
		  /* This currently leaves the stack unaligned (4 not 8) */
		  /* PUSH(ConcreteType, p); */
		  if (!ISNIL(ove)) {
		    if (ove->d.nargs > 0 && 
			(ISNIL(v) || ove->d.nargs < v->d.items)) {
		      DEBUG("Not enough arguments to XCREATE");
		      continue;
		    }
		    TRACE(initiallies, 1, ("Invoking initially of a %.*s",
					   p->d.name->d.items,
					   p->d.name->d.data));
		    for (i = 0; i < ove->d.nargs; i++) {
		      PUSH(u32, ((u32 *)v->d.data)[2 * i]);
		      PUSH(u32, ((u32 *)v->d.data)[2 * i + 1]);
		    }
		    F_SYNCH();
		    pushAR(state, o, p, OVE_INITIALLY);
		    F_UNSYNCH();
		  }
	        }
@ X Window escape
    XSYS "u8u8"   {
		    SYNCH(); obsolete("XSYS", state);
		  }
@ Concurrency stuff
    MONINIT ""	{
		  monitor *m = (monitor *)((Object) op)->d;
		  m->busy = 0;
		  m->waiting = 0;
		}
    MONENTER "" {
		  monitor *m = (monitor *)((Object) op)->d;
		  if (m->busy) {
		    SYNCH();
		    if (!m->waiting) m->waiting = SQueueCreate();
		    SQueueInsert(m->waiting, state);
		    TRACE(process, 3, ("Blocking process %x - monitor entry",
				       state));
		    return 1;
		  } else {
		    TRACE(process, 3, ("Monitor entry, no delay"));
		    m->busy = 1;
		  }
		}
    MONEXIT "" {
		  monitor *m = (monitor *)((Object) op)->d;
		  void *new;
		  if ((new = (void*) SQueueRemove(m->waiting)) == NULL) {
		    TRACE(process, 3, ("Monitor exit, no waiters"));
		    m->busy = 0;
		  } else {
		    makeReady((State*) new);
		    TRACE(process, 3, ("Unblocking process %x - monitor exit",
			   new));
		  }
		}
    CONDINIT ""	{
		  /* containingop holds the object for this CV */
		  int *fpintp = (int *)fp;
		  Object o;
		  condition *c;

		  /* first fetch the saved fp from acondition.initially */
		  fpintp = (int *)fpintp[-2];
		  /* Now get the saved op from that frame */
		  o = (Object) fpintp[-3];
		  c = (condition *) ((Object) op)->d;
		  c->o = o;
		  c->waiting = 0;
		}
    CONDWAIT ""	{
		  Object o;
		  condition *c;
		  monitor *m;
		  void *s;

		  POP(Object, o);
		  CHECKNILO(o, "Nil in condition wait");
		  c = (condition *)((Object) o)->d;
		  if (c->o != op) {
		    DEBUG("condition wait on foreign condition");
		    continue;
		  }
		  SYNCH();
		  if (!c->waiting) c->waiting = SQueueCreate();
		  SQueueInsert(c->waiting, state);
		  TRACE(process, 3, ("Blocking process %x - condition wait",
				     state));
		  m = (monitor *)c->o->d;
		  if ((s = (void*) SQueueRemove(m->waiting)) != NULL) {
		    state = (State*) s;
		    TRACE(process, 3, ("Resuming process %x - monitor queue",
				       state));
		    UNSYNCH();
		  } else {
		    m->busy = 0;
		    return 1;
		  }
		}
    CONDSIGNAL "" {
		  Object o;
		  condition *c;
		  monitor *m;
		  void *s;
		  POP(Object, o);
		  CHECKNILO(o, "Nil in condition signal");
		  c = (condition *)((Object) o)->d;
		  if (c->o != op) {
		    DEBUG("condition signal on foreign condition");
		    continue;
		  }
		  m = (monitor *)c->o->d;
		  if ((s = SQueueRemove(c->waiting)) != NULL) {
		    SYNCH();
		    TRACE(process, 3,
			   ("Blocking process %x - condition signal", state));
		    if (m->waiting == 0) m->waiting = SQueueCreate();
		    SQueueInsertFront(m->waiting, state);
		    state = (State*) s;
		    TRACE(process, 3,
			  ("Resuming process %x - condition signal", state));
		    if (SQueueSize(c->waiting) == 0) {
		      SQueueDestroy(c->waiting);
		      c->waiting = 0;
		    }
		    UNSYNCH();
		  } else {
		    TRACE(process, 3, ("Signal, but no waiters"));
		  }
		}
    CONDAWAITING "" {
		  Object o;
		  u32 nwaiters;
		  condition *c;
		  POP(Object, o);
		  CHECKNILO(o, "Nil in condition awaiting");
		  c = (condition *)((Object) o)->d;
		  if (c->o != op) {
		    DEBUG("condition awaiting on foreign condition");
		    continue;
		  }
		  nwaiters = SQueueSize(c->waiting);
		  PUSH(u32, nwaiters);
		}
    DOLITERALS "" {
		    Code c;
		    POP(Code, c);
		    SYNCH(); obsolete("DOLITERALS", state);
		  }
    INSTALLINOID "" {
		    Object o;
		    u32 seq;
		    POP(Object, o);
		    POP(u32, seq);
		    OIDInsertFromSeq(seq, o);
		  }
    GETROOTDIR "" {
		    char *buf;
		    String s;
		    buf = getenv("EMERALDROOT");
		    if (buf == NULL) buf = EMERALDROOT;
		    F_SYNCH();
		    s = CreateString(buf);
		    F_UNSYNCH();
		    PUSH(String, s);
		  }
    CHECKPOINT "" {
		    Object o;
		    ConcreteType ct;
		    String filename;

		    POP(ConcreteType, ct);	  /* String's CT - ignore */
		    POP(String, filename);
#ifdef USEABCONS
		    {
		      AbCon abcon;
		      POP(AbCon, abcon);
		      ct = abcon->d.con;
		    }
#else
		    POP(ConcreteType, ct);
#endif
		    POP(Object, o);
		    CHECKNILO(o, "Nil in checkpoint");
		    CheckpointToFile(o, ct, filename);
		  }
@ X Window escape --- could block the caller
    BXSYS "u8u8"   {
		     SYNCH(); obsolete("BXSYS", state);
		   }
    GCOLLECT "" {
		  {
		    SYNCH();
		    gcollect();
		    UNSYNCH();
		  }
		}
    LAND ""     { BINARY(s32,&) }
    LOR  ""     { BINARY(s32,|) }
    LSETBIT ""  { 
		  u32 a, b, v;
		  POP(u32, v);
		  POP(u32, b);
		  TOP(u32, a);
		  if (v) {
		    a = a | (1 << (32 - b - 1));
		  } else {
		    a = a & ~(1 << (32 - b - 1));
		  }
		  SETTOP(u32, a);
		}
    LGETBIT ""  {
		  u32 a, b;
		  POP(u32, b);
		  TOP(u32, a);
		  SETTOP(u32, (a & (1 << (32 - b - 1))) ? 1 : 0);
		}
    CALCSIZE "" {
		  SYNCH(); obsolete("CALCSIZE", state);
	        }
    IABS ""     { s32 a;
		  TOP(s32, a);
		  SETTOP(s32, ISNIL(a) ? 0 : a < 0 ? -a : a);
		}
@ Calloids finds the target object on the stack, and the operation oid as an
@ immediate operand (2 bytes)
    CALLOIDS "u16"	{
		  IFETCH2(opoid);
		  goto restofcalloid;
		}
    CALLSTAR "" {
		  SYNCH(); obsolete("CALLSTAR", state);
		}
    CALLSTARCLEAN "" {
		       SYNCH(); obsolete("CALLSTARCLEAN", state);
		     }
    CONFORMS "" {
		  AbstractType a, b;
		  POP(AbstractType, b);
		  POP(AbstractType, a);
		  CHECKNIL(AbstractType, a, "Nil a in conforms");
		  CHECKNIL(AbstractType, b, "Nil b in conforms");
		  PUSH(u32, conforms(a, b));
		}

    DSTR ""     { 
		  u32 secs;
		  String s, timeToDate(int);
		  POP(u32, secs);
		  F_SYNCH();
		  s = timeToDate(secs);
		  F_UNSYNCH();
		  PUSH(String, s);
		}
    DLOAD ""	{
		  String s;
		  POP(String, s);
		  CHECKNILS(s, "Nil in DLOAD");
		  loadNGo(s);
		}
    RELOCATEVECTOR ""	{
		  u32 id, i;
		  ATTypeVector v;
		  POP(u32, id);
		  POP(u32, i);
		  POP(ATTypeVector, v);
		  fixObjectReferenceFromSeq(id, (Object)v, OffsetOf(v, &v->d.data[i]));
		}
    RELOCATETYPE ""	{
		  u32 id;
		  ConcreteType xct;
		  POP(u32, id);
		  POP(ConcreteType, xct);
		  fixObjectReferenceFromSeq(id, (Object)xct, OffsetOf(xct, &xct->d.type));
		}
@ Initialize a lock for an object which is synchronized using accept
   SYNCHINIT "" {
		   monitor *m = (monitor *)((Object) op)->d;
		   /*
		    * Busy encodes two things:
		    *	Low order bit:  open (== 0) or locked (== 1)
		    *	Next bit:       process alive (== 2) or dead (== 0)
		    *
		    * The initial value is 3, locked and the process is alive
		    * (or at least, hasn't died yet).
		    */
		   m->busy = 3;
		   m->waiting = 0;
		 }
@ Enter a routine which is synchronized using accept
   SYNCHENTER "" {
		   monitor *m = (monitor *)((Object) op)->d;
		   State *otherstate;
		   if (prevOP(fp) == op) {
		     TRACE(process, 3, ("SYNCHENTER on self invoke, passed"));
		   } else {
		     switch (m->busy) {
		     case 0:
		       /*
			* Process dead, object unlocked.
			*/
		       m->busy = 1;
		       break;
		     case 1:
		     case 3:
		       /*
			* Process dead or alive, object locked.
			*/
		       SYNCH();
		       if (!m->waiting) m->waiting = SQueueCreate();
		       SQueueInsert(m->waiting, state);
		       TRACE(process, 3, ("Blocking process %x - synchronized object entry",
					  state));
		       return 1;
		       break;
		     case 2:
		       /*
			* Process alive, object unlocked.  The process will be
			* at the head of the waiting queue, so block yourself and
			* run it.  It will decide whether to allow entry.
			*/
		       assert(m->waiting);
		       SYNCH();
		       otherstate = SQueueRemove(m->waiting);
		       SQueueInsert(m->waiting, state);
		       state = otherstate;
		       UNSYNCH();
		       break;
		     default:
		       assert(0);
		       break;
		     }
		   }
                 }
@GETOID returns three integers: the ipaddress, the incarnation (port and epoch), and the seq
@ of the OID of the argument object.  If the 
@ argument object doesn't yet have an OID it is assigned one.
   GETOID     "" {
                    OID theOID;
		    Object obj; ConcreteType ct;

		    POP(ConcreteType, ct);
		    POP(Object, obj);
		    if (HASODP(ct->d.instanceFlags)) {
		      if (!HASOID(obj->flags)) {
			NewOID(&theOID);
			UpdateOIDTables(theOID, obj);
		      } else {
			theOID = OIDOf(obj);
		      }
		    } else {
		      theOID.ipaddress = 0xffffffff;
		      theOID.port = 0xffff;
		      theOID.epoch = 0xffff;
		      theOID.Seq = (Bits32)obj;
		    }
		    PUSH(u32, theOID.ipaddress);
		    PUSH(ConcreteType, intct);
		    PUSH(u32, (theOID.port << 16 | theOID.epoch));
		    PUSH(ConcreteType, intct);
		    PUSH(u32, theOID.Seq);
		    PUSH(ConcreteType, intct);
		  }
@ Exit a routine which is synchronized using accept
    SYNCHEXIT "" {
		   monitor *m = (monitor *)((Object) op)->d;
		   State *otherstate;
		   if (prevOP(fp) == op) {
		     TRACE(process, 3, ("SYNCHEXIT of self invoke - passed"));
		   } else {
		     if ((otherstate = SQueueRemove(m->waiting)) != NULL) {
		       /*
			* Either the process is still alive or some other
			* operation wants in, in either case, schedule it.
			*/
		       makeReady(otherstate);
		       TRACE(process, 3, ("Unblocking process %x - synchronized object exit",
					  otherstate));
		     } else {
		       /*
			* There is no other process waiting, the process
			* better be dead and we want to unlock the object.
			*/
		       assert(m->busy == 1);
		       m->busy = 0;
		       TRACE(process, 3, ("No waiters - synchronized object exit"));
		     }
		   }
		 }
    GETIDSEQ ""	{
		  OID oid;
		  Object o;
		  POP(Object, o);
		  CHECKNILO(o, "Nil in GETIDSEQ");
		  oid = OIDOf(o);
		  if (isNoOID(oid)) {
		    /* Merge: This is wrong - look at GETOID. */
		    NewOID(&oid);
		    OIDInsert(oid, o);
		  }
		  PUSH(u32, oid.Seq);
		}
@ announce the death of the synchronizing process
    SYNCHDIE "" {
		   monitor *m = (monitor *)((Object) op)->d;
		   State *otherstate;
		   assert(m->busy == 3);

		   if ((otherstate = SQueueRemove(m->waiting)) != NULL) {
		     /*
		      * Some other operation wants in, schedule it.
		      */
		     makeReady(otherstate);
		     TRACE(process, 3, ("Unblocking process %x - synchronizing process exit",
					otherstate));
		     m->busy = 1;
		   } else {
		     /*
		      * There is no other process waiting, we want to unlock the object.
		      */
		     m->busy = 0;
		     TRACE(process, 3, ("No waiters - synchronizing process exit"));
		   }
		 }
    LDLITB "u8"	{ 
      		  u8 t;
		  IFETCH1(t);
		  PUSH(Object, cp->d.literals->d.data[t].ptr);
		}

    SWAPV  ""    { u32 ad, at, bd, bt; 
		   POP(u32, at); 
		   POP(u32, ad); 
		   POP(u32, bt);
		   POP(u32, bd);
		   PUSH(u32, ad);
		   PUSH(u32, at);
		   PUSH(u32, bd);
		   PUSH(u32, bt);
		 }
    DOCTLITERALS "" {
		    ConcreteType c;
		    POP(ConcreteType, c);
		    /* fix the literals in c */
		    TRACE(trans, 1, ("Fixing literals in %#x (OID %#x) a %.*s",
				     c, OIDSeqOf((Object)c), 
				     c->d.name->d.items, c->d.name->d.data));
		    fixCTLiterals(c);
		  }
    CVX "u8" {
      u32 n, i;
      u32 *tsp;
      IFETCH1(n);
      tsp = (u32 *) sp - 2 * n;
      for (i = 1; i < n; i++) {
	tsp[i] = tsp[2 * i];
      }
      sp -= 4 * n;
    }

    GCOLLECTOLD "" {
		     SYNCH();
		     gcollect();
		     gcollect_old();
		     UNSYNCH();
    }
  
    CODEOF "" {
#ifdef USEABCONS
      AbCon abcon;
      Object o;
      POP(AbCon, abcon);
      POP(Object, o);
      if (ISNIL(o)) {
	PUSH(ConcreteType, BuiltinInstCT(NILI));
      } else {
	PUSH(ConcreteType, abcon->d.con);
      }
#else
      ConcreteType ct;
      Object o;
      POP(ConcreteType, ct);
      POP(Object, o);
      if (ISNIL(o)) {
	PUSH(ConcreteType, BuiltinInstCT(NILI));
      } else {
	PUSH(ConcreteType, ct);
      }
#endif
    }

    BUILDABCON "" {
#ifdef USEABCONS
      ConcreteType con;
      AbstractType ab;
      AbCon abcon;
      POP(ConcreteType, con);
      POP(AbstractType, ab);
      abcon = findAbCon(OIDOf(ab), OIDOf(con));
      PUSH(AbCon, abcon);
#else
      assert(0);
#endif
    }

    CHECKARGABCONB "u8" {
#ifdef USEABCONS
      AbstractType ab;
      AbCon *abcon;
      u8 t;
      IFETCH1(t);
      abcon = (AbCon *)(fp - (8 * t) + ARGOFF + 4);
      POP(AbstractType, ab);
      verifyAbCon(abcon, ab);
#else
      SYNCH(); obsolete("CHECKARGABCONB", state);
#endif
    }

@ Calls finds the target object on the stack, and the operation number as an
@ immediate operand.  Calls is used only with abcons.
    CALLS "u16"	{
#ifndef USEABCONS
      assert(0);
#else
      assert(0);
#endif /* USEABCONS */
    }

@ Callct finds the target object on the stack, and the operation index as an
@ immediate operand.  This assumes we know the CT of the target.
    CALLCTB "u8" {
      int opindex;
      ConcreteType a;
      Object o;

      IFETCH1(opindex);
      POP(ConcreteType, a);
      POP(Object, o);
      SYNCH();
      if (invoke(o, a, opindex, state)) {
	return 1;
      } else {
	UNSYNCH();
	INVOKECHECKSWITCH;
      }
    }	        

    CONDSIGNALANDEXIT "u8" {
		  Object o;
		  u8 nargs;
		  condition *c;
		  void *new;
		  ConcreteType xcp;

		  IFETCH1(nargs);
		  POP(Object, o);
		  CHECKNILO(o, "Nil in condition signal");
		  c = (condition *)((Object) o)->d;
		  if (c->o != op) {
		    DEBUG("condition signal on foreign condition");
		    continue;
		  }
		  if ((new = SQueueRemove(c->waiting)) != NULL) {
		    makeReady((State*)new);
		    TRACE(process, 3,
			  ("Unblocking process %x - condition signalandexit",
			   new));
		    if (SQueueSize(c->waiting) == 0) {
		      SQueueDestroy(c->waiting);
		      c->waiting = 0;
		    }
		    xcp = cp;
		    sp = fp;
		    POP(u32, pc);
		    POP(u32, fp);
		    POP(Object, op);
		    POP(ConcreteType, cp);
		    IFTRACE(call, 1) {
		      doret(fp, sb, pc, xcp);
		    }
		    sp -= (nargs * 2 * sizeof(u32));
		    PROFILERET();
		  } else {
		    TRACE(process, 3, ("Condition signal and exit, no waiters"));
		  }
		}
    LSETBITS ""  { 
		  u32 a, o, l, v, m = -1L;
		  POP(u32, v);
		  POP(u32, l);
		  POP(u32, o);
		  TOP(u32, a);
		  m = m << (32 - l);
		  m = m >> (o);
		  a = (a & ~m) | (m & (v << (32 - o - l)));
		  SETTOP(u32, a);
		}
    LGETBITS ""  {
		  u32 a, o, l;
		  POP(u32, l);
		  POP(u32, o);
		  TOP(u32, a);
		  SETTOP(u32, ((a << o) >> (32 - l)));
		}
    VIEW "" {
      AbstractType desired;
      ConcreteType ct;
      Object o;
#ifdef USEABCONS
      AbCon abcon;
#endif
      POP(AbstractType, desired);
#ifdef USEABCONS
      POP(AbCon, abcon);
      TOP(Object, o);
      if (!ISNIL(o)) {
	ct = abcon->d.con;
      }
#else
      POP(ConcreteType, ct);
      TOP(Object, o);
#endif
      if (ISNIL(o) || conforms(ct->d.type, desired)) {
	/* Everything is fine. */
      } else {
	DEBUG("View failure");
      }
#ifdef USEABCONS
      PUSH(AbCon, ISNIL(o) ? (AbCon)JNIL : findAbCon(OIDOf(desired), OIDOf(ct)));
#else
      PUSH(ConcreteType, ct);
#endif
    }
@ doesn't handle abcons -brian[0]
    CALLER "" {
      int *fpintp = (int*) fp;
      Object o = (Object) fpintp[-3];
      ConcreteType ct = (ConcreteType) fpintp[-4];
      PUSH( Object, o );
      PUSH( ConcreteType, ct );
    }
    INDIR "" {
      u32 v;
      POP(u32, v);
      PF(v, 0);
    }
    INDIRV "" {
      u32 v;
      POP(u32, v); /* The first one is the concrete type, which we ignore */
      POP(u32, v);
      PF(v, 0);
      PF(v, 4);
    }
    GETISTATE "" {
      ConcreteType p = BuiltinInstCT(INTERPRETERSTATEI);
      InterpreterState o;
      F_SYNCH();
      regRoot(p);
      o = (InterpreterState) gc_malloc(sizeofObject + p->d.instanceSize);
      F_UNSYNCH();
      unregRoot();
      *o = *state;
      o->firstThing = RESDNTBIT;
      SETCODEPTR(o->firstThing, p);
      if (inDistGC()) SETDISTGC(o->firstThing);
      PUSH( InterpreterState, o );
    }
    STRTOK "" {
      String s, me;
      int start, end;
      POP(String, s);
      POP(String, me);
      CHECKNILS(s, "Nil string in String.token");
      CHECKNILS(me, "Nil invoked in String.token");
      stringTok(me, s, &start, &end);
      if (start >= me->d.items) {
	PUSH(String, (String)JNIL);
	PUSH(String, (String)JNIL);
      } else {
	regRoot(me);
	F_SYNCH();
	s = (String)CreateVector(BuiltinInstCT(STRINGI), end - start);
	F_UNSYNCH();
	memmove(&s->d.data[0], &me->d.data[start], end - start);
	PUSH(String, s);
	if (me->d.items <= end) {
	  s = (String)JNIL;
	} else {
	  F_SYNCH();
	  s = (String)CreateVector(BuiltinInstCT(STRINGI), me->d.items - end);
	  F_UNSYNCH();
	  memmove(&s->d.data[0], &me->d.data[end], me->d.items - end);
	}
	PUSH(String, s);
	unregRoot();
      }
    }
    ADJSP "u16" {
      u16 space;
      IFETCH2(space);
      sp = fp + space;
    }
    LSECS "u32" {
      struct tm tm;
      s32 res;
      POP(u32, tm.tm_sec);
      POP(u32, tm.tm_min);
      POP(u32, tm.tm_hour);
      POP(u32, tm.tm_mday);
      POP(u32, tm.tm_mon);
      POP(u32, tm.tm_year);
      tm.tm_isdst = -1;
      tm.tm_year -= 1900;
      res = mktime(&tm);
      if (res < 0) DEBUG("Invalid time");
      PUSH(u32, res);
    }
      
    CREATEGAGGLE "" {
      Object manager;
      ConcreteType xxx;

      POP(ConcreteType, xxx);
      POP(Object, manager);
#ifdef DISTRIBUTED
      {
	OID oid = OIDOf(manager);
	if (isNoOID(oid)) {
	  NewOID(&oid);
	  UpdateOIDTables(oid, manager);
	}
	createGaggle(oid);
      }
#endif
    }
    ADDTOGAGGLE "" {
      Object manager, newobject;
      ConcreteType xxx, oct;
        
      POP(ConcreteType, oct);
      POP(Object, newobject);
      POP(ConcreteType, xxx);
      POP(Object, manager);
      
#ifdef DISTRIBUTED
      {
	OID moid, ooid;

	moid = OIDOf(manager);
	assert(!isNoOID(moid));
	ooid = OIDOf(newobject);
	if (isNoOID(ooid)) {
	  NewOID(&ooid);
	  UpdateOIDTables(ooid, newobject);
	}
	add_gmember(moid, ooid);
	sendGaggleUpdate(moid, ooid, OIDOf(oct), 0);
      }
#endif
    }
    
    GETGAGGLEMEMBER "" {
      Object manager;
      ConcreteType xxx;

      POP(ConcreteType, xxx);
      POP(Object, manager);
#ifdef DISTRIBUTED
      {
	Object member;
	OID moid, ooid, get_gmember(OID);

	moid = OIDOf(manager);
	assert(!isNoOID(moid));
	ooid = get_gmember(moid);
	if (isNoOID(ooid)){
	  PUSH(Object, (Object)JNIL);
	  PUSH(ConcreteType, (ConcreteType)JNIL);
	} else{
	  member = OIDFetch(ooid);
	  PUSH(Object, member);
	  PUSH(ConcreteType, CODEPTR(member->flags));
	}
      }
#else
      PUSH(Object, (Object)JNIL);
      PUSH(ConcreteType, (ConcreteType)JNIL);
#endif
    }
    GETGAGGLEELEMENT "" {
      Object manager;
      u32 index;
      ConcreteType xxx;

      POP(ConcreteType, xxx);
      POP(u32, index);
      POP(ConcreteType, xxx);
      POP(Object, manager);
#ifdef DISTRIBUTED
      {
	OID moid, ooid, get_gelement(OID, int);
	Object member;
	moid = OIDOf(manager);
	assert(!isNoOID(moid));
	ooid = get_gelement(moid, index);
	if (isNoOID(ooid)){
	  PUSH(Object, (Object)JNIL);
	  PUSH(ConcreteType, (ConcreteType)JNIL);
	}
	else{
	  member = OIDFetch(ooid);
	  PUSH(Object, member);
	  PUSH(ConcreteType, CODEPTR(member->flags));
	}
      }
#else
      PUSH(Object, (Object)JNIL);
      PUSH(ConcreteType, (ConcreteType)JNIL);
#endif
    }
    GETGAGGLESIZE "" {
      Object manager;
      ConcreteType xxx;

      POP(ConcreteType, xxx);
      POP(Object, manager);
#ifdef DISTRIBUTED
      {
	OID moid;
	u32 size, get_gsize(OID);

	moid = OIDOf(manager);
	if (isNoOID(moid)) {
	  size = 0;
	} else {
	  size = get_gsize(moid);
	}
	PUSH(u32, size);
	PUSH(ConcreteType, intct);
      }
#else
      PUSH(u32, 0);
      PUSH(ConcreteType, intct);
#endif
    }
@ EOF
