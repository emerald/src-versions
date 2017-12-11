#include "vm_i.h"
#include <stdlib.h>
#ifndef FILE
#include <stdio.h>
#endif
void disassemble(unsigned int ptr, int len, FILE *f);
long long totalbytecodes;
#ifdef PROFILEINTERPRET
int bc_freq[NINSTRUCTIONS];
#endif
int traceinterpret = 0;

int interpret(State *state)
{
  u32 pc;
  u32 sp;		/* Stack pointer */
  u32 fp;		/* Frame pointer */
#define sb state->sb 		/* Stack base */
  Object op;		/* Object pointer */
  ConcreteType cp;		/* Concrete type */
#define opp state->opp 		/* Operation pointer */
#define ep state->ep 		/* Environment pointer */
#define et state->et 		/* Environment type */
#define nsoid state->nsoid 		/* Next SS OID */
#define nstoid state->nstoid 		/* Next target OID */
#define psoid state->psoid 		/* Prev SS OID */
#define psnres state->psnres 		/* Results to return */
  long long addtototalbytecodes = 0;
  unsigned char opcode;
#if defined(INTERPRETERLOCALS)
  INTERPRETERLOCALS
#endif
  UNSYNCH();
  while (1) {
    TOPOFTHEINTERPRETLOOP
#if defined(COUNTBYTECODES) || defined(PROFILEINTERPRET)
    addtototalbytecodes++;
#endif
    IFETCH1(opcode);
#ifdef PROFILEINTERPRET
    bc_freq[opcode]++;
#endif
#ifndef NTRACE
    if (traceinterpret >= 1) {
      printf("Executing opcode ");
      disassemble(pc-1, 1, stdout);
    }
#endif

    switch(opcode) {
      case LDI: { LD(t); }
        break;
      case LDIR: { LD(FETCH(u32,pc,t)); }
        break;
      case LDL: { LD(FETCH(u32,fp,t)); }
        break;
      case LDO: { LD(FETCH(u32,op,t)); }
        break;
      case LDA: { LD(FETCH(u32,fp,-(int)t+ARGOFF)); }
        break;
      case NCCALL: {
		  int res;
		  SYNCH();
		  res = doNCCall(state);
		  if (res) return 1;
		  UNSYNCH();
		}
        break;
      case STL: { EST(fp,t); }
        break;
      case STO: { EST(op,t); stoCheck(op, (Object)v); }
        break;
      case STA: { EST(fp,-(int)t+ARGOFF); }
        break;
      case LDVL: { LD(FETCH(u32,fp,t)); PF(fp,t+4); }
        break;
      case LDVO: { LD(FETCH(u32,op,t)); PF(op,t+4); }
        break;
      case LDVA: { LD(FETCH(u32,fp,-(int)t+ARGOFF)); PF(fp,-(int)t+ARGOFF+4); }
        break;
      case STVL: { EST(fp,t+4); PS(fp,t); }
        break;
      case STVO: { EST(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
        break;
      case STVA: { EST(fp,-(int)t+ARGOFF+4); PS(fp,-(int)t+ARGOFF); }
        break;
      case LDIS: { LDS(t); }
        break;
      case FPOW: { f32 a, b; POP(f32,a); TOP(f32, b); SETTOP(f32, (float)pow((double)b, (double)a)); }
        break;
      case LDLS: { LDS(FETCH(u32,fp,t)); }
        break;
      case LDOS: { LDS(FETCH(u32,op,t)); }
        break;
      case LDAS: { LDS(FETCH(u32,fp,-t+ARGOFF)); }
        break;
      case STLS: { STS(fp,t); }
        break;
      case STOS: { STS(op,t); stoCheck(op, (Object)v); }
        break;
      case STAS: { STS(fp,-t+ARGOFF); }
        break;
      case LDVLS: { LDS(FETCH(u32,fp,t)); PF(fp,t+4); }
        break;
      case LDVOS: { LDS(FETCH(u32,op,t)); PF(op,t+4); }
        break;
      case LDVAS: { LDS(FETCH(u32,fp,-t+ARGOFF)); PF(fp,-t+ARGOFF+4); }
        break;
      case STVLS: { STS(fp,t+4); PS(fp,t); }
        break;
      case STVOS: { STS(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
        break;
      case STVAS: { STS(fp,-t+ARGOFF+4); PS(fp,-t+ARGOFF); }
        break;
      case LDIB: { LDB(t); }
        break;
      case ISTRX: { ASSTR(s32,"%08x"); }
        break;
      case LDLB: { LDB(FETCH(u32,fp,t)); }
        break;
      case LDOB: { LDB(FETCH(u32,op,t)); }
        break;
      case LDAB: { LDB(FETCH(u32,fp,-t+ARGOFF)); }
        break;
      case STLB: { STB(fp,t); }
        break;
      case STOB: { STB(op,t); stoCheck(op, (Object)v); }
        break;
      case STAB: { STB(fp,-t+ARGOFF); }
        break;
      case LDVLB: { LDB(FETCH(u32,fp,t)); PF(fp,t+4); }
        break;
      case LDVOB: { LDB(FETCH(u32,op,t));
		  PF(op,t+4); }
        break;
      case LDVAB: { LDB(FETCH(u32,fp,-t+ARGOFF)); PF(fp,-t+ARGOFF+4); }
        break;
      case STVLB: { STB(fp,t+4); PS(fp,t); }
        break;
      case STVOB: { STB(op,t+4); stoCheck(op, (Object)v); PS(op,t); stoCheck(op, (Object)v); }
        break;
      case STVAB: { STB(fp,-t+ARGOFF+4); PS(fp,-t+ARGOFF); }
        break;
      case DUP: { u32 a;   POP(u32,a); PUSH(u32,a); PUSH(u32,a); }
        break;
      case ENSURESPACE: {
      int size;
      POP(unsigned, size);
      F_SYNCH();
      ensureSpace(size + 32);
      F_UNSYNCH();
    }
        break;
      case SWAP: { SYNCH(); obsolete("SWAP", state); }
        break;
      case ADD: { BINARY(s32,+) }
        break;
      case SUB: { BINARY(s32,-) }
        break;
      case MUL: { BINARY(s32,*) }
        break;
      case DIV: { BINARY(s32,/) }
        break;
      case MOD: { BINARY(s32,%) }
        break;
      case NEG: {  UNARY(s32,-) }
        break;
      case FADD: { BINARY(f32,+) }
        break;
      case FSUB: { BINARY(f32,-) }
        break;
      case FMUL: { BINARY(f32,*) }
        break;
      case FDIV: { BINARY(f32,/) }
        break;
      case FNEG: {  UNARY(f32,-) }
        break;
      case EQ: { UNARYZ(s32,==) }
        break;
      case NE: { UNARYZ(s32,!=) }
        break;
      case GT: { UNARYZ(s32,> ) }
        break;
      case GE: { UNARYZ(s32,>=) }
        break;
      case LT: { UNARYZ(s32,< ) }
        break;
      case LE: { UNARYZ(s32,<=) }
        break;
      case FCMP: {
                  f32 a, b;
		  POP(f32,b); POP(f32,a);
		  a = a-b;
		  PUSH(s32,((a>0)?1:((a<0)?(-1):0)));
		}
        break;
      case SCMP: {
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
        break;
      case AND: { BINARY(s32,&&) }
        break;
      case OR: { BINARY(s32,||) }
        break;
      case NOT: {  UNARY(s32, !) }
        break;
      case ASSERT: { s32 a; POP(s32,a);
                  if(!a) DEBUG("Assertion failed");
                }
        break;
      case CSTR: { s32 a;
                  String s;

                  POP(s32,a);
		  F_SYNCH();
		  s = (String)CreateVector(BuiltinInstCT(STRINGI),1);
		  F_UNSYNCH();
                  s->d.items = 1;
		  s->d.data[0] = (char)a;
		  PUSH(String,s);
                }
        break;
      case FINT: { f32 a; POP(f32,a); PUSH(s32,(s32)a); }
        break;
      case IFLO: { s32 a; POP(s32,a); PUSH(f32,(f32)a); }
        break;
      case ISTR: { ASSTR(s32,"%d"); }
        break;
      case FSTR: { ASSTR(f32,"%g"); }
        break;
      case EBSTR: { s32 a;
		  POP(s32,a);
		  PUSH(String, (a?TrueString:FalseString));
                }
        break;
      case BGETS: {
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
        break;
      case BGETU: {
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
        break;
      case BSET: {
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
        break;
      case NTOH: {
                     u32 off, len;
		     Vector v;

                     POP(u32,len);
                     POP(u32,off);
                     POP(Vector,v);
		     CHECKNILV(v, "NTOH on nil");
		     ntohBits(v, off, len);
                   }
        break;
      case GETB: {
                     Vector v;
                     s32 i;

                     POP(s32,i);
                     POP(Vector,v);
		     CHECKNILV(v, "GETB on a vector which is nil");
		     BOUNDSCHECK(v, i);
		     PUSH(s32,(s32)(v->d.data[i]));
                   }
        break;
      case GET: {
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
        break;
      case GETV: {
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
        break;
      case SET: {
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
        break;
      case SETV: {
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
        break;
      case GSLICE: {
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
        break;
      case SETLOCSRV: {
		      Object newlocsrv;
		      POP(Object, newlocsrv);
		      if (ISNIL(locsrv)) {
			locsrv = newlocsrv;
		      }
                    }
        break;
      case CAT: {
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
        break;
      case LEN: {
                    Vector o1;
		    POP(Vector,o1);
		    CHECKNILV(o1,"LEN on a vector which is nil");
		    PUSH(s32,o1->d.items);
                  }
        break;
      case SETDEBUGGER: {
		      Object newdebugger;
		      POP(Object, newdebugger);
		      if (ISNIL(debugger)) {
			debugger = newdebugger;
		      }
                    }
        break;
      case CALLOID: {
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
        break;
      case LINK: {
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
        break;
      case LINKB: {
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
        break;
      case RET: {
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
        break;
      case QUIT: { 
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
        break;
      case GETLOCSRV: { 
  		  Object o;
		  o = locsrv;
		  PUSH(Object, o);
		  if (ISNIL(o)) {
		    PUSH(ConcreteType, (ConcreteType)JNIL);
		  } else {
		    PUSH(ConcreteType, CODEPTR(o->flags));
		  }
		 }
        break;
      case CREATE: {
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
        break;
      case CREATEVEC: {
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
        break;
      case QUITP: { 
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
        break;
      case BR: { s16 o; IFETCH2(o); pc += o; if (o < 0) BRANCHCHECKSWITCH;}
        break;
      case BRT: { s16 o; u32 t; IFETCH2(o); POP(u32, t);
		  if (t) pc += o; }
        break;
      case BRF: { s16 o; u32 f; IFETCH2(o); POP(u32, f);
		  if (!f) pc += o; }
        break;
      case CASE: { s16 low, high, off; s32 v;
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
        break;
      case TRAPF: { u32 t; POP(u32, t); if (!t) DEBUG("Assertion failure"); }
        break;
      case RETFAIL: { DEBUG("Return and fail"); }
        break;
      case LDSELF: { PUSH(Object, op); }
        break;
      case LDSELFV: { 
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
        break;
      case PUSHNIL: { PUSH(u32, 0x80000000); }
        break;
      case PUSHNILV: { PUSH(u32, 0x80000000); PUSH(u32, 0x80000000); }
        break;
      case POOP: { u32 t; POP(u32, t); }
        break;
      case SYS: {
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
        break;
      case GETENV: {
		  PUSH(Object, ep);
		  PUSH(ConcreteType, et);
		}
        break;
      case SETENV: {
		  POP(ConcreteType, et);
		  POP(Object, ep);
		}
        break;
      case STRI: {
		  String s;
		  s32 x;
		  POP(String, s);
		  CHECKNILS(s, "Nil in STRI");
		  memmove(buf, s->d.data, s->d.items);
		  buf[s->d.items] = '\0';
		  x = mstrtol(buf, 0, 0);
		  PUSH(s32, x);
    		}
        break;
      case CREATEVECLIT: {
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
        break;
      case STRHASH: {
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
        break;
      case BREAKME: {
		  Object o;
		  extern void breakObject(Object o);
		  POP(Object, o);
		  breakObject(o);
		  if (o == op) DEBUG("Breakme executed");
		}
        break;
      case ACPTBLCK: {
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
        break;
      case BREAKPT: {
		 DEBUG("Breakpoint");
    	       }
        break;
      case UPB: {
                    Vector o1;
		    POP(Vector,o1);
		    CHECKNILV(o1, "Nil in UPB");
		    PUSH(s32,o1->d.items-1);
                  }
        break;
      case STRLIT: {
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
        break;
      case LDINDS: {
                   Object o;

		   POP(Object, o);
		   CHECKNILO(o, "Nil invoked (LDINDS)");
		   {
		     LDS(FETCH(u32, (int) o, t));
		   }
		 }
        break;
      case LDVINDS: {
		   u32 v;
		   POP(u32, v);
		   CHECKNILU(v, "Nil invoked (LDVINDS)");
		   {
		     LDS(FETCH(u32,v,t));
		     PF(v, t+4);
		   }
		 }
        break;
      case PUSHCT: {
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
        break;
      case STRF: {
		  String s;
		  float x;
		  POP(String, s);
		  CHECKNILS(s, "Nil in STRF");
		  memmove(buf, s->d.data, s->d.items);
		  buf[s->d.items] = '\0';
		  x = (float)atof(buf);
		  PUSH(float, x);
    		}
        break;
      case XCREATE: {
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
        break;
      case XSYS: {
		    SYNCH(); obsolete("XSYS", state);
		  }
        break;
      case MONINIT: {
		  monitor *m = (monitor *)((Object) op)->d;
		  m->busy = 0;
		  m->waiting = 0;
		}
        break;
      case MONENTER: {
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
        break;
      case MONEXIT: {
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
        break;
      case CONDINIT: {
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
        break;
      case CONDWAIT: {
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
        break;
      case CONDSIGNAL: {
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
        break;
      case CONDAWAITING: {
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
        break;
      case DOLITERALS: {
		    Code c;
		    POP(Code, c);
		    SYNCH(); obsolete("DOLITERALS", state);
		  }
        break;
      case INSTALLINOID: {
		    Object o;
		    u32 seq;
		    POP(Object, o);
		    POP(u32, seq);
		    OIDInsertFromSeq(seq, o);
		  }
        break;
      case GETROOTDIR: {
		    char *buf;
		    String s;
		    buf = getenv("EMERALDROOT");
		    if (buf == NULL) buf = EMERALDROOT;
		    F_SYNCH();
		    s = CreateString(buf);
		    F_UNSYNCH();
		    PUSH(String, s);
		  }
        break;
      case CHECKPOINT: {
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
        break;
      case BXSYS: {
		     SYNCH(); obsolete("BXSYS", state);
		   }
        break;
      case GCOLLECT: {
		  {
		    SYNCH();
		    gcollect();
		    UNSYNCH();
		  }
		}
        break;
      case LAND: { BINARY(s32,&) }
        break;
      case LOR: { BINARY(s32,|) }
        break;
      case LSETBIT: { 
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
        break;
      case LGETBIT: {
		  u32 a, b;
		  POP(u32, b);
		  TOP(u32, a);
		  SETTOP(u32, (a & (1 << (32 - b - 1))) ? 1 : 0);
		}
        break;
      case CALCSIZE: {
		  SYNCH(); obsolete("CALCSIZE", state);
	        }
        break;
      case IABS: { s32 a;
		  TOP(s32, a);
		  SETTOP(s32, ISNIL(a) ? 0 : a < 0 ? -a : a);
		}
        break;
      case CALLOIDS: {
		  IFETCH2(opoid);
		  goto restofcalloid;
		}
        break;
      case CALLSTAR: {
		  SYNCH(); obsolete("CALLSTAR", state);
		}
        break;
      case CALLSTARCLEAN: {
		       SYNCH(); obsolete("CALLSTARCLEAN", state);
		     }
        break;
      case CONFORMS: {
		  AbstractType a, b;
		  POP(AbstractType, b);
		  POP(AbstractType, a);
		  CHECKNIL(AbstractType, a, "Nil a in conforms");
		  CHECKNIL(AbstractType, b, "Nil b in conforms");
		  PUSH(u32, conforms(a, b));
		}
        break;
      case DSTR: { 
		  u32 secs;
		  String s, timeToDate(int);
		  POP(u32, secs);
		  F_SYNCH();
		  s = timeToDate(secs);
		  F_UNSYNCH();
		  PUSH(String, s);
		}
        break;
      case DLOAD: {
		  String s;
		  POP(String, s);
		  CHECKNILS(s, "Nil in DLOAD");
		  loadNGo(s);
		}
        break;
      case RELOCATEVECTOR: {
		  u32 id, i;
		  ATTypeVector v;
		  POP(u32, id);
		  POP(u32, i);
		  POP(ATTypeVector, v);
		  fixObjectReferenceFromSeq(id, (Object)v, OffsetOf(v, &v->d.data[i]));
		}
        break;
      case RELOCATETYPE: {
		  u32 id;
		  ConcreteType xct;
		  POP(u32, id);
		  POP(ConcreteType, xct);
		  fixObjectReferenceFromSeq(id, (Object)xct, OffsetOf(xct, &xct->d.type));
		}
        break;
      case SYNCHINIT: {
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
        break;
      case SYNCHENTER: {
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
        break;
      case GETOID: {
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
        break;
      case SYNCHEXIT: {
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
        break;
      case GETIDSEQ: {
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
        break;
      case SYNCHDIE: {
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
        break;
      case LDLITB: { 
      		  u8 t;
		  IFETCH1(t);
		  PUSH(Object, cp->d.literals->d.data[t].ptr);
		}
        break;
      case SWAPV: { u32 ad, at, bd, bt; 
		   POP(u32, at); 
		   POP(u32, ad); 
		   POP(u32, bt);
		   POP(u32, bd);
		   PUSH(u32, ad);
		   PUSH(u32, at);
		   PUSH(u32, bd);
		   PUSH(u32, bt);
		 }
        break;
      case DOCTLITERALS: {
		    ConcreteType c;
		    POP(ConcreteType, c);
		    /* fix the literals in c */
		    TRACE(trans, 1, ("Fixing literals in %#x (OID %#x) a %.*s",
				     c, OIDSeqOf((Object)c), 
				     c->d.name->d.items, c->d.name->d.data));
		    fixCTLiterals(c);
		  }
        break;
      case CVX: {
      u32 n, i;
      u32 *tsp;
      IFETCH1(n);
      tsp = (u32 *) sp - 2 * n;
      for (i = 1; i < n; i++) {
	tsp[i] = tsp[2 * i];
      }
      sp -= 4 * n;
    }
        break;
      case GCOLLECTOLD: {
		     SYNCH();
		     gcollect();
		     gcollect_old();
		     UNSYNCH();
    }
        break;
      case CODEOF: {
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
        break;
      case BUILDABCON: {
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
        break;
      case CHECKARGABCONB: {
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
        break;
      case CALLS: {
#ifndef USEABCONS
      assert(0);
#else
      assert(0);
#endif /* USEABCONS */
    }
        break;
      case CALLCTB: {
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
        break;
      case CONDSIGNALANDEXIT: {
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
        break;
      case LSETBITS: { 
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
        break;
      case LGETBITS: {
		  u32 a, o, l;
		  POP(u32, l);
		  POP(u32, o);
		  TOP(u32, a);
		  SETTOP(u32, ((a << o) >> (32 - l)));
		}
        break;
      case VIEW: {
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
        break;
      case CALLER: {
      int *fpintp = (int*) fp;
      Object o = (Object) fpintp[-3];
      ConcreteType ct = (ConcreteType) fpintp[-4];
      PUSH( Object, o );
      PUSH( ConcreteType, ct );
    }
        break;
      case INDIR: {
      u32 v;
      POP(u32, v);
      PF(v, 0);
    }
        break;
      case INDIRV: {
      u32 v;
      POP(u32, v); /* The first one is the concrete type, which we ignore */
      POP(u32, v);
      PF(v, 0);
      PF(v, 4);
    }
        break;
      case GETISTATE: {
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
        break;
      case STRTOK: {
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
        break;
      case ADJSP: {
      u16 space;
      IFETCH2(space);
      sp = fp + space;
    }
        break;
      case LSECS: {
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
        break;
      case CREATEGAGGLE: {
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
        break;
      case ADDTOGAGGLE: {
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
        break;
      case GETGAGGLEMEMBER: {
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
        break;
      case GETGAGGLEELEMENT: {
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
        break;
      case GETGAGGLESIZE: {
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
        break;
      default:
	fprintf(stderr, "Undefined bytecode %d\n", opcode);
        break;
    }
  }
}
#undef sb
#undef opp
#undef ep
#undef et
#undef nsoid
#undef nstoid
#undef psoid
#undef psnres

struct ite {
  char *name; char *param; int val;
} IT[] = {
  { "LDI", "u32", 0 } ,
  { "LDIR", "u32", 1 } ,
  { "LDL", "u32", 2 } ,
  { "LDO", "u32", 3 } ,
  { "LDA", "u32", 4 } ,
  { "NCCALL", "u8u8", 5 } ,
  { "STL", "u32", 6 } ,
  { "STO", "u32", 7 } ,
  { "STA", "u32", 8 } ,
  { "LDVL", "u32", 9 } ,
  { "LDVO", "u32", 10 } ,
  { "LDVA", "u32", 11 } ,
  { "STVL", "u32", 12 } ,
  { "STVO", "u32", 13 } ,
  { "STVA", "u32", 14 } ,
  { "LDIS", "s16", 15 } ,
  { "FPOW", "", 16 } ,
  { "LDLS", "s16", 17 } ,
  { "LDOS", "s16", 18 } ,
  { "LDAS", "s16", 19 } ,
  { "STLS", "s16", 20 } ,
  { "STOS", "s16", 21 } ,
  { "STAS", "s16", 22 } ,
  { "LDVLS", "s16", 23 } ,
  { "LDVOS", "s16", 24 } ,
  { "LDVAS", "s16", 25 } ,
  { "STVLS", "s16", 26 } ,
  { "STVOS", "s16", 27 } ,
  { "STVAS", "s16", 28 } ,
  { "LDIB", "s8", 29 } ,
  { "ISTRX", "", 30 } ,
  { "LDLB", "s8", 31 } ,
  { "LDOB", "s8", 32 } ,
  { "LDAB", "s8", 33 } ,
  { "STLB", "s8", 34 } ,
  { "STOB", "s8", 35 } ,
  { "STAB", "s8", 36 } ,
  { "LDVLB", "s8", 37 } ,
  { "LDVOB", "s8", 38 } ,
  { "LDVAB", "s8", 39 } ,
  { "STVLB", "s8", 40 } ,
  { "STVOB", "s8", 41 } ,
  { "STVAB", "s8", 42 } ,
  { "DUP", "", 43 } ,
  { "ENSURESPACE", "", 44 } ,
  { "SWAP", "", 45 } ,
  { "ADD", "", 46 } ,
  { "SUB", "", 47 } ,
  { "MUL", "", 48 } ,
  { "DIV", "", 49 } ,
  { "MOD", "", 50 } ,
  { "NEG", "", 51 } ,
  { "FADD", "", 52 } ,
  { "FSUB", "", 53 } ,
  { "FMUL", "", 54 } ,
  { "FDIV", "", 55 } ,
  { "FNEG", "", 56 } ,
  { "EQ", "", 57 } ,
  { "NE", "", 58 } ,
  { "GT", "", 59 } ,
  { "GE", "", 60 } ,
  { "LT", "", 61 } ,
  { "LE", "", 62 } ,
  { "FCMP", "", 63 } ,
  { "SCMP", "", 64 } ,
  { "AND", "", 65 } ,
  { "OR", "", 66 } ,
  { "NOT", "", 67 } ,
  { "ASSERT", "", 68 } ,
  { "CSTR", "", 69 } ,
  { "FINT", "", 70 } ,
  { "IFLO", "", 71 } ,
  { "ISTR", "", 72 } ,
  { "FSTR", "", 73 } ,
  { "EBSTR", "", 74 } ,
  { "BGETS", "", 75 } ,
  { "BGETU", "", 76 } ,
  { "BSET", "", 77 } ,
  { "NTOH", "", 78 } ,
  { "GETB", "", 79 } ,
  { "GET", "", 80 } ,
  { "GETV", "", 81 } ,
  { "SET", "", 82 } ,
  { "SETV", "", 83 } ,
  { "GSLICE", "", 84 } ,
  { "SETLOCSRV", "", 85 } ,
  { "CAT", "", 86 } ,
  { "LEN", "", 87 } ,
  { "SETDEBUGGER", "", 88 } ,
  { "CALLOID", "u32", 89 } ,
  { "LINK", "u16", 90 } ,
  { "LINKB", "u8", 91 } ,
  { "RET", "u8", 92 } ,
  { "QUIT", "u8", 93 } ,
  { "GETLOCSRV", "", 94 } ,
  { "CREATE", "", 95 } ,
  { "CREATEVEC", "", 96 } ,
  { "QUITP", "", 97 } ,
  { "BR", "s16", 98 } ,
  { "BRT", "s16", 99 } ,
  { "BRF", "s16", 100 } ,
  { "CASE", "case32", 101 } ,
  { "TRAPF", "", 102 } ,
  { "RETFAIL", "u8", 103 } ,
  { "LDSELF", "", 104 } ,
  { "LDSELFV", "", 105 } ,
  { "PUSHNIL", "", 106 } ,
  { "PUSHNILV", "", 107 } ,
  { "POOP", "", 108 } ,
  { "SYS", "u8u8", 109 } ,
  { "GETENV", "", 110 } ,
  { "SETENV", "", 111 } ,
  { "STRI", "", 112 } ,
  { "CREATEVECLIT", "", 113 } ,
  { "STRHASH", "", 114 } ,
  { "BREAKME", "", 115 } ,
  { "ACPTBLCK", "", 116 } ,
  { "BREAKPT", "", 117 } ,
  { "UPB", "", 118 } ,
  { "STRLIT", "", 119 } ,
  { "LDINDS", "u16", 120 } ,
  { "LDVINDS", "u16", 121 } ,
  { "PUSHCT", "", 122 } ,
  { "STRF", "", 123 } ,
  { "XCREATE", "", 124 } ,
  { "XSYS", "u8u8", 125 } ,
  { "MONINIT", "", 126 } ,
  { "MONENTER", "", 127 } ,
  { "MONEXIT", "", 128 } ,
  { "CONDINIT", "", 129 } ,
  { "CONDWAIT", "", 130 } ,
  { "CONDSIGNAL", "", 131 } ,
  { "CONDAWAITING", "", 132 } ,
  { "DOLITERALS", "", 133 } ,
  { "INSTALLINOID", "", 134 } ,
  { "GETROOTDIR", "", 135 } ,
  { "CHECKPOINT", "", 136 } ,
  { "BXSYS", "u8u8", 137 } ,
  { "GCOLLECT", "", 138 } ,
  { "LAND", "", 139 } ,
  { "LOR", "", 140 } ,
  { "LSETBIT", "", 141 } ,
  { "LGETBIT", "", 142 } ,
  { "CALCSIZE", "", 143 } ,
  { "IABS", "", 144 } ,
  { "CALLOIDS", "u16", 145 } ,
  { "CALLSTAR", "", 146 } ,
  { "CALLSTARCLEAN", "", 147 } ,
  { "CONFORMS", "", 148 } ,
  { "DSTR", "", 149 } ,
  { "DLOAD", "", 150 } ,
  { "RELOCATEVECTOR", "", 151 } ,
  { "RELOCATETYPE", "", 152 } ,
  { "SYNCHINIT", "", 153 } ,
  { "SYNCHENTER", "", 154 } ,
  { "GETOID", "", 155 } ,
  { "SYNCHEXIT", "", 156 } ,
  { "GETIDSEQ", "", 157 } ,
  { "SYNCHDIE", "", 158 } ,
  { "LDLITB", "u8", 159 } ,
  { "SWAPV", "", 160 } ,
  { "DOCTLITERALS", "", 161 } ,
  { "CVX", "u8", 162 } ,
  { "GCOLLECTOLD", "", 163 } ,
  { "CODEOF", "", 164 } ,
  { "BUILDABCON", "", 165 } ,
  { "CHECKARGABCONB", "u8", 166 } ,
  { "CALLS", "u16", 167 } ,
  { "CALLCTB", "u8", 168 } ,
  { "CONDSIGNALANDEXIT", "u8", 169 } ,
  { "LSETBITS", "", 170 } ,
  { "LGETBITS", "", 171 } ,
  { "VIEW", "", 172 } ,
  { "CALLER", "", 173 } ,
  { "INDIR", "", 174 } ,
  { "INDIRV", "", 175 } ,
  { "GETISTATE", "", 176 } ,
  { "STRTOK", "", 177 } ,
  { "ADJSP", "u16", 178 } ,
  { "LSECS", "u32", 179 } ,
  { "CREATEGAGGLE", "", 180 } ,
  { "ADDTOGAGGLE", "", 181 } ,
  { "GETGAGGLEMEMBER", "", 182 } ,
  { "GETGAGGLEELEMENT", "", 183 } ,
  { "GETGAGGLESIZE", "", 184 } ,
};

void disassemble(unsigned int ptr, int len, FILE *f)
{
  register struct ite *it;
  register unsigned int base = ptr, limit = ptr + len;
  register unsigned char opcode;
  int i, arg, arg2, arg3;
  short int sarg;

  while (ptr < limit) {
    if (len > 1) fprintf(f, "%4d:\t", ptr - base);
    opcode = *(unsigned char *)ptr++;
    if (opcode < (sizeof IT / sizeof(struct ite))) {
      it = &IT[opcode];
      fprintf(f, "%s\t", it->name);
      if (*it->param) {
	arg = 0;
	if (!strcmp(it->param, "u32")) {
	  UFETCH4(arg, ptr, 1);
	  fprintf(f, "%d (0x%08x)", arg, arg);
	} else if (!strcmp(it->param, "u16")) {
	  UFETCH2(arg, ptr, 1);
	  fprintf(f, "%d (0x%04x)", arg, arg);
	} else if (!strcmp(it->param, "s16")) {
	  UFETCH2(sarg, ptr, 1);
	  arg = sarg;
	  fprintf(f, "%d (0x%04x)", arg, arg);
	} else if (!strcmp(it->param, "u8") || !strcmp(it->param, "s8")) {
	  UFETCH1(arg, ptr, 1);
	  fprintf(f, "%d (0x%02x)", arg, arg);
	} else if (!strcmp(it->param, "u8u8")) {
	  UFETCH1(arg, ptr, 1);
	  UFETCH1(arg2, ptr, 1);
	  fprintf(f, "%d %d (0x%02x 0x%02x)", arg, arg2, arg, arg2);
	} else if (!strcmp(it->param, "u8u16")) {
	  UFETCH1(arg, ptr, 1);
	  UFETCH2(arg2, ptr, 1);
	  fprintf(f, "%d %d (0x%02x 0x%04x)", arg, arg2, arg, arg2);
	} else if (!strcmp(it->param, "case32")) {
	  UFETCH2(arg, ptr, 2);
	  UFETCH2(arg2, ptr, 2);
	  fprintf(f, "%d %d (0x%02x 0x%02x)\n", arg, arg2, arg, arg2);
	  for (i = arg; i <= arg2; i++) {
	    UFETCH2(arg3, ptr, 2);
	    fprintf(f, "\t  %d -> %d\n", i, arg3 + ptr - base);
	  }
	  UFETCH2(arg3, ptr, 2);
	  fprintf(f, "\t  else -> %d", arg3 + ptr - base);
	} else {
	  fprintf(f, "bad param \"%s\"", it->param);
	}
	if (opcode == CALLOID || opcode == CALLOIDS) {
	  fprintf(f, " %s", OperationName(arg));
	}
      }
      fprintf(f, "\n");
    } else {
      fprintf(f, "? %d '%c'\n", opcode, opcode);
    }
  }
}

void outputProfile(void)
{
#ifdef PROFILEINTERPRET
  int i, j, maxindex, max;
  for (i = 0; i < NINSTRUCTIONS; i++) {
    maxindex = 0; max = bc_freq[maxindex];
    for (j = 1; j < NINSTRUCTIONS; j++) {
      if (bc_freq[j] > max) {
	maxindex = j;
	max = bc_freq[maxindex];
      }
    }
    if (max <= 0) return;
    printf("%4d: %15s %8d   %5.2f\n", i, IT[maxindex].name, max,
      (double) max * 100 / totalbytecodes);
    bc_freq[maxindex] = -1;
  }
#endif
}
