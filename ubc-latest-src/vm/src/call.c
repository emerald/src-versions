/*
 * The stuff you need to handle complicated invocations.
 */


#define E_NEEDS_IOV
#define E_NEEDS_STRING
#include "system.h"

#include "types.h"
#include "iset.h"
#include "iisc.h"
#include "vm_exp.h"
#include "assert.h"
#include "call.h"
#include "bufstr.h"
#include "streams.h"
#include "rinvoke.h"
#include "move.h"
#include "oidtoobj.h"
#include "remote.h"
#include "gc.h"
#include "trace.h"

IISc fixqueue;
IISc allfrozen;
extern int debugInteractively;

inline int isReason(int why, Reason r)
{
  return (why & (int) r) == (int) r;
}

inline int reasonToIndex(int why)
{
  return why == RInitially ? OVE_INITIALLY : OVE_RECOVERY;
}

void CallInit(void)
{
  allfrozen = IIScCreate();
  fixqueue = IIScCreate();
}

void pushAR(State *state, Object obj, ConcreteType ct, int opindex)
{
  PROFILEBUMP(state->pc, ct->d.opVector->d.data[opindex], ct);

#define sp state->sp
  /* stack the old environment */
  PUSH(ConcreteType, state->cp);
  PUSH(Object, state->op);
  PUSH(u32, state->fp);
  PUSH(u32, state->pc);

  /* switch to the called environment */
  state->opp = ct->d.opVector->d.data[opindex];
  state->pc = (u32)state->opp->d.code->d.data;
  state->cp = ct;
  state->op = obj;
  state->fp = sp;
#undef sp
}

void pushBottomAR(State *state)
{
  extern Object upcallStub;
  ConcreteType stubCT = BuiltinInstCT(STUBI);
  u32 sp = state->sp;

  PUSH(ConcreteType, stubCT);
  PUSH(Object, upcallStub);
  PUSH(u32, 0 /* frame pointer */);
  PUSH(u32, (u32) stubCT->d.opVector->d.data[OVE_PROCESS]->d.code->d.data);
  state->sp = sp;
  state->fp = sp;
}
  
void freeze(Object obj, Reason why)
{
  int r = IIScLookup(allfrozen, (int)obj);
  SETBROKEN(obj->flags);

  if (why == RRemote) return;
  if (IIScIsNIL(r)) r = 0;
  r = r | (int)why;
  IIScInsert(allfrozen, (int)obj, r);
}

void addToFixQueue(Object obj, State *state)
{
  SQueue fixq = (SQueue) IIScLookup(fixqueue, (int)obj);

  assert((int)state != -1);
  if (IIScIsNIL(fixq)) {
    IIScInsert(fixqueue, (int)obj, (int)(fixq = SQueueCreate()));
    TRACE(call, 2, ("State %#x waiting for object %#x to init", state, obj));
  }
  SQueueInsert(fixq, state);
}
    
void finishedFixing(Object obj)
{
  SQueue fixq = (SQueue) IIScLookup(fixqueue, (int)obj);
  State *waiter;

  if (IIScIsNIL(fixq)) {
    TRACE(call, 2, ("No waiters"));
  } else {
    while ((waiter = SQueueRemove(fixq))) {
      TRACE(call, 2, ("Thaw resuming state %#x", waiter));
      makeReady(waiter);
    }
    SQueueDestroy(fixq);
    IIScDelete(fixqueue, (int)obj);
  }
}
    
char *ReasonString(int r)
{
  static char buf[5][60];
  static int i = 0;
  char *rval;

  rval = buf[i]; i = (i+1) % 5;
  sprintf(rval, "%s%s%s", 
    r & (int) RInitially ? "Initially " : "",
    r & (int) RRemote ? "Remote " : "",
    r & (int) RDead ? "Dead " : "");
  return rval;
}

extern int invoke(Object obj, ConcreteType ct, int opindex, State *state);

void thaw(Object obj, Reason why)
{
  int r = IIScLookup(allfrozen, (int)obj);
  if (IIScIsNIL(r)) r = 0;
  if (!RESDNT(obj->flags)) r = r | RRemote;

  r = r & ~(int)why;
  TRACE(call, 2, ("Thawing Object %#x a %.*s", obj, 
		     CODEPTR(obj->flags)->d.name->d.items,
		     CODEPTR(obj->flags)->d.name->d.data));
  if (r) {
    /* The object is still broken, but for some other reason */
    TRACE(call, 2, ("Object %#x still broken for %s", ReasonString(r)));
    if (r == RRemote) {
      IIScDelete(allfrozen, (int)obj);
      finishedFixing(obj);
    } else {
      IIScInsert(allfrozen, (int)obj, r);
    }
  } else {
    TRACE(call, 2, ("Object %#x no longer broken"));
    CLEARBROKEN(obj->flags);
    IIScDelete(allfrozen, (int)obj);
    finishedFixing(obj);
  }
}

int duringInitialization(Object obj)
{
  int why = IIScLookup(allfrozen, (int)obj);
  return !IIScIsNIL(why) && ((why & (int)RInitially) == (int)RInitially);
}
  
int isBroken(Object obj)
{
  int why = IIScLookup(allfrozen, (int)obj);
  return !IIScIsNIL(why) && ((why & (int)RDead) == (int)RDead);
}
  
int selfDuringInitialization(Object obj, State *state)
{
  int why = IIScLookup(allfrozen, (int)obj);
  return (Reason)why == RInitially && obj == state->op;
}

void tryToInit(Object obj)
{
  extern IISc fixqueue;
  ISet fixq;
  int why = IIScLookup(allfrozen, (int)obj);

  if ((Reason)why != RInitially) return;
  fixq = (ISet) IIScLookup(fixqueue, (int)obj);
  if (!IIScIsNIL(fixq)) return;

  IIScInsert(fixqueue, (int)obj, (int)SQueueCreate());
  TRACE(initiallies, 1,
	("actively invoking initially/recovery of %#x (%.*s)",
	 obj, CODEPTR(obj->flags)->d.name->d.items,
	 CODEPTR(obj->flags)->d.name->d.data));
  run(obj, reasonToIndex(why), 0);
}

/*
 * Return 0 (success) if interpretation is to continue, 1 if interpretation
 * of the state needs to be defered.
 */
int invokefrozen(Object obj, ConcreteType ct, int opindex, State *state)
{
  int why = IIScLookup(allfrozen, (int)obj);
  if (IIScIsNIL(why)) why = 0;
  if (!RESDNT(obj->flags)) why = why | RRemote;

  if (TRACING(call, 2) || 
      (isReason(why, RInitially) && TRACING(initiallies, 2))) {
    TRACE(call, 0,
	  ("invoking frozen (%s) object %#x (%.*s)",
	   ReasonString(why), obj, ct->d.name->d.items, ct->d.name->d.data));
  }
  if (isReason(why, RDead)) {
    /* It cannot come back */
    return debug(state, "Invocation of failed object");
#ifdef DISTRIBUTED
  } else if (isReason(why, RRemote)) {
    return rinvoke(state, obj, opindex);
#endif
  } else if ((Reason)why == RInitially) {
    extern IISc fixqueue;
    ISet fixq;

    assert(obj != state->op);

    /*
     * First, push the activation record for the actual operation that we 
     * are attempting to invoke so we can return to it when we are resumed,
     * and then run the initially (or just wait for it to finish).
     */
    pushAR(state, obj, ct, opindex);
    
    fixq = (ISet) IIScLookup(fixqueue, (int)obj);
    if (IIScIsNIL(fixq)) {
      IIScInsert(fixqueue, (int)obj, (int)SQueueCreate());
      TRACE(initiallies, 1,
	    ("call invoking initially/recovery of %#x (%.*s)",
	     obj, ct->d.name->d.items, ct->d.name->d.data));
      pushAR(state, obj, ct, reasonToIndex(why));
      return 0;
    } else {
      addToFixQueue(obj, state);
      return 1;
    }
  } else {
    /*
     * There is no reason, probably a remote object that came back.
     */
    CLEARBROKEN(obj->flags);
    return invoke(obj, ct, opindex, state);
  }
}

/*
 * Return 0 (success) if interpretation is to continue, 1 if interpretation
 * of the state needs to be suspended.
 */
int invoke(Object obj, ConcreteType ct, int opindex, State *state)
{
  char buf[64];
  if (ISNIL(obj)) {
    sprintf(buf, "Invoked nil, opindex = %d", opindex);
    return debug(state, buf);
  }
  IFTRACE(call, 1) {
    docallct(ct->d.opVector->d.data[opindex], state->sp, state->fp, ct, obj, state->sb);
  }
  if (HASODP(ct->d.instanceFlags) && BROKEN(obj->flags) &&
      !selfDuringInitialization(obj, state)) {
    return invokefrozen(obj, ct, opindex, state);
  } else {
    pushAR(state, obj, ct, opindex);
    return 0;
  }
}

/*
 * A stack segment (process) has terminated its execution, and now we must
 * figure out what to do next.  The integer argument fail is 1 if a failure
 * is to be propagated to the next stack segment, 2 if an unavailable is to
 * be propagated, and 0 if a normal return is to take place.
 */
State *processDone(State *state, int fail)
{
  State *previousState = 0;

  regRoot(state);
  anticipateGC(64 * 1024);
  unregRoot();

  if (isNoOID(state->psoid)) {
    TRACE(process, 3, ("Nothing to do next"));
    previousState = 0;
  } else {
    TRACE(process, 3, ("Returning to state %s", OIDString(state->psoid)));
    previousState = stateFetch(state->psoid, limbo);
    if (RESDNT(previousState->firstThing)) {
      /*
       * We need to run that state. The results are at the bottom of our
       * stack.
       */
      int i, *ressplace, *ress;
      ress = (int *)state->sp - state->psnres * 2;

      TRACE(process, 3, ("Returning to a local state"));
      assert(sameOID(previousState->nsoid, OIDOf(state)));
      TRACE(process, 5, ("Resetting nsoid in state %#x", previousState));
      previousState->nsoid = nooid;
      previousState->nstoid = nooid;

      /* Simulate a return on that state */
      ressplace = (int *)previousState->sp - state->psnres * 2;
      for (i = 0; i < state->psnres * 2; i++) ressplace[i] = ress[i];
      if (fail) {
	if (!findHandler(previousState, fail - 1, (Object)JNIL)) {
	  previousState = processDone(previousState, fail);
	}
      }
#ifdef DISTRIBUTED
    } else {
      Stream str;
      RemoteOpHeader h;
      h.kind = InvokeReply;
      h.option1 = fail;
      h.status = 0;
      h.ss = state->psoid;
      h.sslocation = getLocFromObj((Object)previousState);
      h.target = OIDOf(state->op);
      h.targetct = OIDOf(state->cp);

      if (fail) {
	TRACE(rinvoke, 2, ("Signalling %s to remote invocation",
			   fail == 1 ? "failure" :
			   fail == 2 ? "unavailable" :
			   "unknown"));
      }
      TRACE(rinvoke, 3, ("Returning %d vars to remote activation %s on %s",
			 state->psnres, OIDString(h.ss),
			 NodeString(h.sslocation)));
      str = StartMsg(&h);
      sendNVars(str, state->psnres, (int *)(state->sp - state->psnres * 2 * 4),
		state->ep, state->et);
      sendMsgTo(h.sslocation, str, h.ss);
      previousState = 0;
#endif
    }
  }
  deleteState(state);
  inhibit_gc--;
  return previousState;
}

/*
 * We have just entered a new invocation, and we need a new stack chunk
 */
State *newStackChunk(State *oldstate)
{
  State *state;
  int *args;
  int sp;
  ConcreteType ct = oldstate->cp;
  OpVectorElement ove = findOpVectorElement(ct, oldstate->pc);
  int nargs = ove->d.nargs, nress = ove->d.nress, i;
  u32 junk;

  state = newState(oldstate->op, ct);
  state->ep = oldstate->ep;
  state->et = oldstate->et;
  state->pc = oldstate->pc;

  sp = state->sb;

  args = (int *)oldstate->sp - 4 - 2 * (nargs + nress);
  /* build the stack */
  for (i = 0; i < 2 * (nargs + nress); i++) { PUSH(int, args[i]); }
  state->sp = sp;
  
  pushBottomAR(state);

#if !defined(OLD_STACK_OVERFLOW_CODE)
#define sp oldstate->sp
  POP(u32, oldstate->pc);
  POP(u32, oldstate->fp);
  POP(Object, oldstate->op);
  POP(ConcreteType, oldstate->cp);
  /* Pop the arguments */
  for (i = 0; i < nargs; i++) {
    POP(u32, junk);
    POP(u32, junk);
  }
#undef sp
#endif

  dependsOn(state, oldstate, nress);
  return state;
}

#ifdef DISTRIBUTED
/*
 * The indicated state has moved elsewhere, so can be deleted.  It is not 
 * finished, so we can't do what the callback is.
 */
void processMovedOut(State *state)
{
  deleteState(state);
}

/*
 * We are returning from an invocation on an object that has died.  Raise
 * failure.  Return true (1) if the entire stack segment has been consumed,
 * false (0) if it should be run.
 */
int returnToBrokenObject(State *state)
{
  State lstate = *state;
  if (findHandler(&lstate, 0, (Object)JNIL)) {
    TRACE(call, 1, ("Return to broken object which is handled"));
    TRACE(process, 1, ("Return to broken object which is handled"));
    *state = lstate;
    return 0;
  } else {
    TRACE(call, 1, ("Unhandled failure in returning to broken object"));
    if (debugInteractively) {
      return debug(state, "Unhandled failure in returning to broken object");
    } else {
      state = processDone(state, 1);
      if (state) makeReady(state);
      return 1;
    }
  }
}

/*
 * Some process has returned, only to find the object owning the previous
 * activation record to be gone.  Send the activation record to the new home
 * of the object.
 */
void returnToForeignObject(State *state, int value)
{
  Object obj;
  Node srv;
  Stream str;
  RemoteOpHeader h;
  
  regRoot(state);
  anticipateGC(64 * 1024);
  unregRoot();

  obj = state->op;
  srv = getLocFromObj(obj);
  h.kind = InvokeForwardRequest;
  h.target = OIDOf(state->op);
  h.targetct = OIDOf(state->cp);
  h.ss = OIDOf((Object)state);
  h.sslocation = myid;

  TRACE(rinvoke, 3, ("Forwarding activation on %#x %s a %.*s", obj, 
		     OIDString(h.target),
		     state->cp->d.name->d.items,
		     state->cp->d.name->d.data));
  TRACE(rinvoke, 4, ("It is on node %s", NodeString(srv)));

  str = StartMsg(&h);
  WriteInt(value, str);
  
  SQueueYank(ready, state);
  if (addActivations(state, str, 1)) {
    processMovedOut(state);
  }

  sendMsgTo(srv, str, h.ss);
  inhibit_gc--;
}

#endif

struct State *stateFetch(OID oid, Node loc)
{
  State *state = (State *)OIDFetch(oid);
#ifdef DISTRIBUTED
  int isnew = 0;
  if (ISNIL(state)) {
    ConcreteType stateCT = BuiltinInstCT(INTERPRETERSTATEI);

    state = (State *)vmMalloc(sizeof(State));
    memset(state, 0, sizeof(*state));
    SETCODEPTR(state->firstThing, stateCT);
    if (inDistGC()) SETDISTGC(state->firstThing);
    OIDInsert(oid, (Object)state);
    TRACE(distgc, 5, ("StateFetch making a %s state %#x with oid %s",
		      RESDNT(state->firstThing) ? "resident" : "nonresident",
		      (unsigned int)state, OIDString(oid)));
    TRACE(process, 5, ("StateFetch making a %s state %#x with oid %s",
		      RESDNT(state->firstThing) ? "resident" : "nonresident",
		      (unsigned int)state, OIDString(oid)));
    isnew = 1;
  }
  if (!RESDNT(state->firstThing) && (isnew || !isNoNode(loc)))
    updateLocation((Object)state, loc);
#else
  assert(!ISNIL(state));
#endif
  return state;
}

void dependsOn(struct State *s, struct State *t, int nress)
{
  assert(!wasGCMalloced(s));
  assert(!wasGCMalloced(t));
  t->nstoid = nooid;
  TRACE(process, 5, ("Setting nsoid in state %#x to %s", t, OIDString(OIDOf(s))));
  if (RESDNT(t->firstThing)) t->nsoid = OIDOf(s);
  s->psoid = OIDOf(t);
  s->psnres = nress;
}

