/* comment me!
 */

#define E_NEEDS_STRING
#include "system.h"

#include "streams.h"
#include "storage.h"
#include "vm_exp.h"
#include "types.h"
#include "iisc.h"
#include "trace.h"
#include "vm.h"
#include "misc.h"
#include "squeue.h"
#include "assert.h"
#include "iset.h"
#include "creation.h"
#include "globals.h"
#include "dist.h"
#include "call.h"

extern ISet allProcesses;

/*
 * Extra space for malloc overruns
 */
#define EXTRASPACE  0

Object AllocateObject(ct, size)
ConcreteType ct;
int size;
{
  Object o;

  regRoot(ct);
  o = (Object) gc_malloc(sizeofObject + EXTRASPACE + size);
  unregRoot();
  SETRESDNT(o->flags);
  SETCODEPTR(o->flags, ct);
  if (inDistGC()) SETDISTGC(o->flags);
  return o;
}

Object CreateUninitializedObject(ConcreteType ct)
{
  Object o;
  regRoot(ct);
  o = AllocateObject(ct, ct->d.instanceSize);
  unregRoot();
  if (HASINITIALLY(ct)) freeze(o, RInitially);
  return o;
}

Object CreateObjectFromOutside(ConcreteType ct, unsigned int sb)
{
  Object o;
  OpVectorElement ove;
  regRoot(ct);
  o = AllocateObject(ct, ct->d.instanceSize);
  unregRoot();
  ove = ct->d.opVector->d.data[OVE_INITIALLY];
  if (!ISNIL(ove)) {
    State *state = newState(o, ct);
    int res;
    freeze(o, RInitially);
    TRACE(initiallies, 1, ("Invoking initially of a %.*s",
			   ct->d.name->d.items,
			   ct->d.name->d.data));
    memcpy((void *)state->sb, (void *)sb, 8 * ove->d.nargs);
    state->sp = state->fp = state->sb + 8 * ove->d.nargs;
    pushBottomAR(state);

    /* set up the interpreter state */
    state->pc = (u32) ove->d.code->d.data;
    res = interpret(state);
    assert(res == 0);
  }
  return o;
}

/*
 * Create-and-initialize routines for builtin types.
 */

Vector CreateVector(ConcreteType ct, unsigned nelems)
{
  Vector v;
  int is;

  is = (ct->d.instanceSize < 0 ?
	-ct->d.instanceSize : ct->d.instanceSize);
  regRoot(ct);
  v = (Vector) AllocateObject(ct, nelems*is+sizeof(int));
  unregRoot();
  assert (!HASINITIALLY(ct));
  v->d.items = nelems;
  return v;
}

String CreateString(char *s)
{
  int n = strlen(s);
  String o = (String) CreateVector(BuiltinInstCT(STRINGI),n);
  o->d.items = n;
  memmove(o->d.data, s, n);
  return o;
}

void runState(State *state, int asynch)
{
  extern int interpret(State *);
  extern ISet running;

  if (asynch) {
    makeReady(state);
  } else {
    ISetInsert(running, (int)state);
    interpret(state);
    ISetDelete(running, (int)state);
  }
}

/*
 * Return true if the current stack frame is the last one.
 */
int bottomStackFrame(State *state)
{
  int *fpintp = (int *)state->fp;
  return fpintp == 0 || fpintp[-2] == 0;
}

State *newState(Object o, ConcreteType ct)
{
  ConcreteType stateCT = BuiltinInstCT(INTERPRETERSTATEI);
  State *state;
  OID oid;

  state = (State *)vmMalloc(sizeof(State));
  state->firstThing = RESDNTBIT;
  SETCODEPTR(state->firstThing, stateCT);
  if (inDistGC()) SETDISTGC(state->firstThing);
  state->cp = ct;
  state->op = o;
  state->sb = (int)vmMalloc(stackSize);
  state->sp = state->sb;
  state->opp = (OpVectorElement)JNIL;
  state->ep = (Object) JNIL;
  state->et = (ConcreteType) JNIL;
  state->nstoid = nooid;
  state->nsoid = nooid;
  state->psoid = nooid;
  state->psnres = 0;
  NewOID(&oid); 
  OIDInsert(oid, (Object)state);
  TRACE(distgc, 5, ("Created a state %#x with OID %s", state, OIDString(oid)));
  TRACE(rinvoke, 5, ("Created a state %#x with OID %s", state, OIDString(oid)));
  TRACE(process, 5, ("Created a state %#x with OID %s", state, OIDString(oid)));
  ISetInsert(allProcesses, (int)state);
  return state;
}

void deleteState(State *state)
{
  TRACE(distgc, 5, ("Deleting a state %#x with oid %s",
		    (unsigned int)state, OIDString(OIDOf(state))));

  TRACE(process, 5, ("Deleting a state %#x with oid %s",
		    (unsigned int)state, OIDString(OIDOf(state))));
  if (!isNoOID(state->nsoid)) {
    TRACE(process, 0, ("State %#x still has nsoid %s",
		       state, OIDString(state->nsoid)));
  }
  ISetDelete(allProcesses, (int)state);

  OIDRemoveAny((Object)state);
#ifdef USEDISTGC
  distGCFreeState(state);
#endif
  tryToFindState(state);
  if (state->sb) vmFree((void *)state->sb);
  vmFree(state);
}

void setupState(State *state, Object o, ConcreteType ct)
{
  ISetInsert(allProcesses, (int)state);
  SETRESDNT(state->firstThing);
  state->cp = ct;
  state->op = o;
  state->sb = (int)vmMalloc(stackSize);
  state->sp = state->sb;
  state->opp = (OpVectorElement)JNIL;
  state->ep = (Object) JNIL;
  state->et = (ConcreteType) JNIL;
}

/*
 * Run takes an object and executes the indexed operation:
 * one of OVE_INITIALLY, OVERECOVERY, or OVE_PROCESS.
 * The stack pointer to use is given by sp; a new stack is allocated
 * if that parameter is a 0.
 *
 * In the sequential version, this calls the interpreter directly,
 * and is therefore synchronous.  In the concurrent version, this
 * asynchronously creates a new process and continues for processes.
 */
void run(Object o, int index, int asynch)
{
  extern int debugFirst;
  ConcreteType ct;
  OpVectorElement ope;
  State *state;

  ct = CODEPTR(o->flags);
  state = newState(o, ct);

  ope = ct->d.opVector->d.data[index];
  state->opp = ope;
  state->ep = (Object) JNIL; state->et = (ConcreteType) JNIL;
  state->pc = (int)ope->d.code->d.data;

  pushBottomAR(state);

  if (debugFirst) {
    debugFirst = 0; 
    (void) debug(state, "First time");
  }
  PROFILEBUMP(0, ope, ct);
  IFTRACE(call, 1) {
    docall(-index-1, state->sp, state->fp, state->cp, state->op, state->sb);
  }
  runState(state, index == OVE_PROCESS || asynch);
}
