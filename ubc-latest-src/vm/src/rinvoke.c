/* rinvoke.c - support for method invocation on remote objects
 * $Id: rinvoke.c,v 1.14 2007/06/11 02:35:58 norm Exp $
 */

#define E_NEEDS_STRING
#define E_NEEDS_IOV
#include "system.h"

#include "assert.h"
#include "bufstr.h"
#include "builtins.h"
#include "creation.h" 
#include "dist.h"
#include "gc.h"
#include "globals.h"
#include "iisc.h"
#include "locate.h"
#include "misc.h"
#include "move.h"
#include "oidtoobj.h"
#include "read.h"
#include "remote.h"
#include "streams.h"
#include "trace.h"
#include "vm_exp.h"
#include "write.h"

int receivingObjects = 0;
extern int debugInteractively;
extern int fakeUnavailable;

#ifdef DISTRIBUTED

/*
 * The indicated node has failed, find and unavailable any pending
 * operations.  We need to go through outstandingInvokes and aggressively
 * locate the state that holds our continuation.
 */
void invokeHandleDown(struct noderecord *nd)
{
  State *state, *nextstate;

  ISetForEach(allProcesses, state) {
    if (!isNoOID(state->nsoid)) {
      nextstate = (State *)OIDFetch(state->nsoid);
      if (ISNIL(nextstate) || !RESDNT(nextstate->firstThing)) {
	if (ISNIL(nextstate)) nextstate = stateFetch(state->nsoid, limbo);
	aggressivelyLocate((Object)nextstate);
	/*
	 * Because aggressivelyLocate may remove the state from allProcesss
	 * we have to fudge with the index
	 */
	if (allProcesses->table[ISetxx_index].key != (int)state) ISetxx_index--;
      }
    } else if (!isNoOID(state->nstoid)) {
      /*
       * This is an outstanding move, we should do something.
       */
      TRACE(rinvoke, 0, ("A node has failed while a move is outstanding for %s",
			 OIDString(state->nstoid)));
      makeReady(state);
    }
  } ISetNext();
}

void performReturn(State *state)
{
  u32 sp = state->fp;
  OpVectorElement ove = findOpVectorElement(state->cp, state->pc);
  int nargs = ove->d.nargs;
  POP(u32, state->pc);
  POP(u32, state->fp);
  POP(Object, state->op);
  POP(ConcreteType, state->cp);
  sp -= (nargs * 2 * sizeof(u32));
  state->sp = sp;
}

State *extractActivation(Object, ConcreteType, Stream, Node);

void handleInvokeForwardRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  ConcreteType ct;
  Object o;
  unsigned int answer;

  anticipateGC(64*1024 + 2 * StreamLength(str));
  TRACE(rinvoke, 3, ("InvokeForwardRequest received"));
  TRACE(rinvoke, 6, ("Checking for CT for incoming activation"));
  ct = (ConcreteType) doObjectRequest(srv, &h->targetct, ctct);
  assert(! ISNIL(ct));

  TRACE(rinvoke, 4, ("InvokeForwarded for object with ID %s", OIDString(h->target)));
  o = OIDFetch(h->target);
  assert(!ISNIL(o));
  if (RESDNT(o->flags)) {
    int more;
    State *state;
    TRACE(rinvoke, 4, ("The object is here, accepting activation"));
    ReadInt(&answer, str);
    more = memcmp(ReadStream(str, 4), "ACT!", 4);
    assert(!more);
    /* Suck out an activation record - argh! */
    TRACE(rinvoke, 6, ("Incoming activation record!!"));
    state = extractActivation(o, ct, str, srv);
    if (!ISNIL(answer)) {
#define sp state->sp
      PUSH(u32, answer);
      PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
    }
#undef sp
  } else {
    Node newsrv = getLocFromObj(o);
    TRACE(rinvoke, 4, ("Forwarding request to %s", NodeString(newsrv)));
    if (forwardMsg(newsrv, h, str) < 0) {
      Stream newstr;
      RewindStream(str);
      newstr = StealStream(str);
      findAndSendTo(h->target, newstr);
    }
  }
  TRACE(rinvoke, 4, ("Invoke forward request done"));
  inhibit_gc--;
}

void handleInvokeReply(RemoteOpHeader *h, Node srv, Stream str)
{
  State *state;

  anticipateGC(64 * 1024 + 2 * StreamLength(str));
  state = (State *)OIDFetch(h->ss);
  if (ISNIL(state) || !RESDNT(state->firstThing)) {
    /*
     * We probably gc'd this state because we couldn't find any references
     * to it.  Find it and send it this reply.
     */
    Stream newstr;
    RewindStream(str);
    newstr = StealStream(str);
    findAndSendTo(h->ss, newstr);
  } else {
    TRACE(rinvoke, 3, ("InvokeReply received"));

    assert(!ISNIL(state));
    assert(RESDNT(state->firstThing));
    assert(ISetMember(allProcesses, (int)state));

    TRACE(process, 5, ("Resetting nsoid in state %#x", state));
    state->nsoid = nooid;
    state->nstoid = nooid;
    if (h->status) {
      TRACE(rinvoke, 0, ("Obsolete remote invocation return code"));
      h->option1 = 2;
    }
    if (h->option1) {
      /*
       * We are supposed to propagate a failure.
       */
      TRACE(rinvoke, 1, ("Remote invocation raised %s",
			 h->option1 == 1 ? "failure" :
			 h->option1 == 2 ? "unavailable" :
			 "unknown"));
      if (!findHandler(state, h->option1 - 1, (Object)JNIL)) {
	if (!debugInteractively) {
	  state = processDone(state, h->option1);
	} else {
	  char buf[80];
	  sprintf(buf, "Remote invocation raised %s",
		  h->option1 == 1 ? "failure" :
		  h->option1 == 2 ? "unavailable" :
		  "unknown");
	  if (debug(state, buf)) {
	    /*
	     * debug returns 1 when we shouldn't run the state no more.
	     */
	    state = 0;
	  }
	}
      }
      if (state) makeReady(state);
    } else if (RESDNT(state->op->flags) &&
	       BROKEN(state->op->flags) && isBroken(state->op)) {
      if (returnToBrokenObject(state)) {
	/* nothing to do */
      } else {
	makeReady(state);
      }
    } else {
      extractNVars(str, -1, (int *)state->sp, &state->ep, &state->et, srv);
      makeReady(state);
    }
  }
  TRACE(rinvoke, 4, ("Invoke return handled"));
  inhibit_gc--;
}

void handleInvokeRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  Stream newstr;
  int argc = h->option2, retc = h->option1, fn = h->status, i;
  Object obj;
  ConcreteType ct = 0;
  RemoteOpHeader replyh;
  int *sp;
  State *state;

  anticipateGC(64 * 1024 + 2 * StreamLength(str));
  TRACE(rinvoke, 3, ("InvokeRequest received"));
  /* figure out who we're invoking on */
  obj = OIDFetch(h->target);

  if (!ISNIL(obj)) {
    ct = CODEPTR(obj->flags);
    TRACE(rinvoke, 4, ("Target is a %.*s, operation name is %.*s[%d]",
		       ct->d.name->d.items, ct->d.name->d.data, 
		       ct->d.opVector->d.data[fn]->d.name->d.items,
		       ct->d.opVector->d.data[fn]->d.name->d.data, argc));
  } else {
    TRACE(rinvoke, 1, ("Invoking %s op %d [%d] -> [%d]", OIDString(h->target),
		       fn, argc, retc));
  }

  if (ISNIL(obj)) {
    /*
     * Invoke came here, but we don't know anything about this object.
     * First find it, then send it the message.
     */
    TRACE(rinvoke, 1, ("Trying to find the object and send it the message"));
    ct = (ConcreteType)doObjectRequest(replyh.sslocation, &h->targetct, ctct);
    obj = createStub(ct, getNodeRecordFromSrv(replyh.sslocation), h->target);

    RewindStream(str);
    newstr = StealStream(str);
    findAndSendTo(h->target, newstr);
  } else if (!RESDNT(obj->flags)) {
    Node newsrv = getLocFromObj(obj);
    /* Invoke came here, but the object is elsewhere */
    /* First check to see if we think the object is where this invoke
       came from */
    if (SameNode(srv, newsrv) || SameNode(myid, newsrv) || SameNode(limbo, newsrv)) {
      TRACE(rinvoke, 1, ("Have stub, but points back.  Forwarding to limbo"));
      RewindStream(str);
      newstr = StealStream(str);
      findAndSendTo(h->target, newstr);
    } else {
      TRACE(rinvoke, 1, ("Forwarding invoke to %s", NodeString(newsrv)));
      if (forwardMsg(newsrv, h, str) < 0) {
	RewindStream(str);
	newstr = StealStream(str);
	findAndSendTo(h->target, newstr);
      }
    }
  } else if (fakeUnavailable && ((random() % 100) < fakeUnavailable)) {
    newstr = StealStream(str);
    sendUnavailableReply(newstr);
  } else {
    OID oid;
    state = newState(obj, ct);
    OIDRemoveAny((Object)state);
    ReadOID(&oid, str);
    OIDInsert(oid, (Object) state);
    for (sp = (int *)state->sb, i = 0 ; i < 2 * retc ; i++) *sp++ = JNIL;
    extractNVars(str, argc, sp, &state->ep, &state->et, srv);
    sp += argc * 2;
    TRACE(rinvoke, 4, ("Doing upcall on a %.*s",
		       CODEPTR(obj->flags)->d.name->d.items, 
		       CODEPTR(obj->flags)->d.name->d.data));
    state->sp = (u32)sp;
    pushBottomAR(state);

    /* set up the interpreter state */
    state->pc = (u32) ct->d.opVector->d.data[fn]->d.code->d.data;
    dependsOn(state, stateFetch(h->ss, h->sslocation), retc);
    makeReady(state);
  }
  inhibit_gc--;
}

#if 0
Object findLocationOf(State *state, Object obj)
{
  int args[6], findOpByName(ConcreteType, char *);
  ConcreteType bcct = BuiltinInstCT(BITCHUNKI);
  Bitchunk bc;
  ConcreteType ct;
  OID oid;
  static int lookupfn = 0;
  
  bc = (Bitchunk)CreateVector(bcct, sizeof(OID));
  oid = OIDOf(obj);
  memmove(bc->d.data, &oid, sizeof(OID));
  args[0] = (int)JNIL;
  args[1] = (int)JNIL;
  args[2] = (int)bc;
  args[3] = (int)bcct;
  args[4] = (int)OIDFetch(thisnode->node);
  args[5] = (int)BuiltinInstCT(NODEI);
  ct = CODEPTR(locsrv->flags);
  if (!lookupfn) lookupfn = findOpByName(ct, "lookup");
  upcall(locsrv, lookupfn, 0, 2, 1, args);
  return (Object)args[0];
}
#endif

int rinvoke(State *state, Object obj, int fn)
{
  RemoteOpHeader h;
  u32 sb, sp = state->sp;
  int retc, argc;
  Node srv;
  Stream str; 
  ConcreteType ct;

  regRoot(obj);
  regRoot(state);
  anticipateGC(64 * 1024);  
  unregRoot();
  unregRoot();

  /* figure out where we're sending the invocation */
  ct = CODEPTR(obj->flags);
  assert(!RESDNT(obj->flags));
  srv = getLocFromObj(obj);

  /* figure out what object we're invoking on */
  h.target = OIDOf(obj);
  if (isNoOID(h.target)) {
    ConcreteType ct = CODEPTR(obj->flags);
    printf("It was a %.*s\n", ct->d.name->d.items, ct->d.name->d.data);
    return debug(state, "Invoked object with no oid");
  }
  assert(!isNoOID(h.target));
  h.targetct = OIDOf(ct);

  /* push the header information */
  h.kind = InvokeRequest;
  h.status = fn;
  h.option1 = retc = ct->d.opVector->d.data[fn]->d.nress;
  h.option2 = argc = ct->d.opVector->d.data[fn]->d.nargs;

  h.ss = OIDOf((Object)state);
  h.sslocation = myid;
  str = StartMsg(&h);
  state->nstoid = h.target;
  NewOID(&state->nsoid);
  TRACE(process, 5, ("Setting nsoid in state %#x to %s", state,
		     OIDString(state->nsoid)));
  WriteOID(&state->nsoid, str);
  sb = sp - 8 * argc;

  TRACE(rinvoke, 3, ("Invoking on %#x %s a %.*s [%d] -> [%d]", obj, 
		     OIDString(h.target),
		     ct->d.name->d.items,
		     ct->d.name->d.data, argc, retc));
  TRACE(rinvoke, 4, ("It is on node %s", NodeString(srv)));

  sendNVars(str, argc, (int *)sb, state->ep, state->et);
  state->sp = sb;
  inhibit_gc--;
  if (isLimbo(srv)) {
    findAndSendTo(h.target, str);
  } else {
    sendMsgTo(srv, str, h.target);
  }
  return 1;
}
#endif

Vector getnodes(int onlyactive)
{
  ConcreteType nle = BuiltinInstCT(NODELISTELEMENTI);
  ConcreteType nl = BuiltinInstCT(NODELISTI);
  ConcreteType ct;
  Vector thenl;
  Object thenle;
  unsigned int stack[32];
  int i, howmany = 0;
  noderecord **nd;

  for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
    /* Ignore not yet filled out entries */
    if (ISNIL(OIDFetch((*nd)->node))) continue;
    if (onlyactive && ! (*nd)->up) continue;
    howmany ++;
  }
  anticipateGC(64 * 1024 + howmany * 6 * sizeof(u32));
  thenl = CreateVector(nl, howmany);
  for(i = 0, nd = &allnodes->p ; *nd ; nd = &(*nd)->p) {

    /* Ignore not yet filled out entries */
    if (ISNIL(OIDFetch((*nd)->node))) continue;
    if (onlyactive && ! (*nd)->up) continue;

    TRACE(rinvoke, 6, ("Node %d is on %s and up is %d", i,
		       NodeString((*nd)->srv), (*nd)->up));
    /* Build the node list element, it takes 4 arguments */
    /* The node */
    ct = BuiltinInstCT(NODEI); assert(ct);
    stack[0] = (unsigned int) OIDFetch((*nd)->node);
    stack[1] = (unsigned int) ct;
    /* Is it up? */
    ct = BuiltinInstCT(BOOLEANI); assert(ct);
    stack[4] = (unsigned int) (*nd)->up;
    stack[5] = (unsigned int) ct;
    /* incarnation Time */
    ct = BuiltinInstCT(TIMEI); assert(ct);
    stack[2] = (unsigned int) OIDFetch((*nd)->inctm);
    stack[3] = (unsigned int) ct;
    /* lnn */
    stack[6] = (*nd)->node.port << 16 | (*nd)->node.epoch;
    stack[7] = (unsigned int) intct;
    thenle = CreateObjectFromOutside(nle, (u32)stack);
    ((Object*)thenl->d.data)[i] = thenle;
    i ++;
  }
  inhibit_gc--;

  TRACE(rinvoke, 5, ("getactivenodes() got %d nodes", i));
  return thenl;
}

