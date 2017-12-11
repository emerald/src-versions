/* move.c - support for method invocation on remote objects
 * $Id: move.c,v 1.17 2007/06/11 02:35:58 norm Exp $
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
#include "move.h"
#include "oidtoobj.h"
#include "read.h"
#include "remote.h"
#include "streams.h"
#include "trace.h"
#include "vm_exp.h"
#include "write.h"

IISc fixedMap;

static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}

int sizeFromTemplate(Template t)
{
  int count, size = 0, totalsize = 0;
  char c, *brands;

  if (ISNIL(t)) return 0;

  brands = (char *)t->d.data;
  while(*brands != '\0') {
    switch (*brands++) {
    case '%':
      count = 0;
      while (misdigit(c = *brands++)) {
	count = count * 10 + c-'0';
      }
      if (!count) count = 1;
      assert(c != '*');
      switch(c) {
      case 'm':
	assert(count == 1);
	size = 8;
	break;
      case 'X':
      case 'x':
      case 'D':
      case 'd':
      case 'F':
      case 'f':
	size = 4;
	break;
      case 'C':
      case 'c':
      case 'B':
      case 'b':
	size = 4;
	break;
      case 'V':
      case 'v':
	size = 8;
	break;
      case 'l':
      case 'L':
      case 'q':
	TRACE(rinvoke, 0, ("Brand %c can't appear in an activation record", c));
	assert(0);
	break;
      default:
	TRACE(rinvoke, 0, ("can't figure brand %c", c));
	assert(0);
      }
      totalsize += count * size;
      break;
    default:
      TRACE(rinvoke, 0, ("What is '%c' doing in a template?", brands[-1]));
      assert(0);
      break;
    }
  }
  return totalsize;
}

#ifdef DISTRIBUTED

extern int receivingObjects;
extern Object createStub(ConcreteType ct, void *stub, OID oid);

void handleMove3rdPartyRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  Object o;
  Node newsrv;
  Stream newstr;

  TRACE(rinvoke, 3, ("Move3rdPartyRequest received"));
  o = OIDFetch(h->target);
  ReadNode(&newsrv, str);
  TRACE(rinvoke, 5, ("Move3rd: move %s to %s", OIDString(h->target),
		     NodeString(newsrv)));
  if (!ISNIL(o) && RESDNT(o->flags)) {
    if (SameNode(newsrv, getMyLoc())) {
      TRACE(rinvoke, 4, ("The object is already here, keeping it"));
      if (h->option1) fixHere(o);
      moveDone(stateFetch(h->ss, h->sslocation), h, 0);
    } else if (isFixedHere(o) && h->option1 != 2) {
      TRACE(rinvoke, 4, ("The object is fixed here, failing"));
      moveDone(stateFetch(h->ss, h->sslocation), h, 1);
    } else {
      TRACE(rinvoke, 4, ("The object is here, sending it to %s", NodeString(newsrv)));
      move(h->option1, o, newsrv, stateFetch(h->ss, h->sslocation));
    }
  } else if (!ISNIL(o)) {
    Node forwardto = getLocFromObj(o);
    TRACE(rinvoke, 4, ("Forwarding request to %s", NodeString(forwardto)));
    if (forwardMsg(forwardto, h, str) < 0) {
      RewindStream(str);
      newstr = StealStream(str);
      findAndSendTo(h->target, newstr);
    }
  } else {
    /*
     * First generate a stub, and then try to find the object and send this on.
     */
    ConcreteType ct = (ConcreteType)doObjectRequest(srv, &h->targetct, ctct);
    o = createStub(ct, limbonode, h->target);
    RewindStream(str);
    newstr = StealStream(str);
    findAndSendTo(h->target, newstr);
  }
}

State *extractActivation(Object, ConcreteType, Stream, Node);

void handleMoveRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  ConcreteType ct;
  RemoteOpHeader replyh;
  Stream reply;  StreamByte *buf;
  Object o;
  int wasPresent;

  anticipateGC(64 * 1024 + 2 * StreamLength(str));
  TRACE(rinvoke, 3, ("MoveRequest received"));

  TRACE(rinvoke, 6, ("Checking for CT for incoming object"));
  ct = (ConcreteType) doObjectRequest(srv, &h->targetct, ctct);
  assert(! ISNIL(ct));

  TRACE(rinvoke, 4, ("Received object with ID %s", OIDString(h->target)));
  wasPresent = !ISNIL(OIDFetch(h->target));

  o = ExtractObjects(str, srv);

  assert(o == OIDFetch(h->target));
  TRACE(rinvoke, 6, ("Received object is at address %#x", o));
  if (h->option2) freeze(o, RInitially);
  if (wasPresent) { 
    /* We already had this object, make sure it gets marked as resident */
    TRACE(rinvoke, 6, ("Thawing %#x", o));
    thaw(o, RRemote);
  }
  if (h->option1) {
    TRACE(rinvoke, 3, ("Fixing %#x, %s here", o, OIDString(OIDOf(o))));
    fixHere(o);
  }
  
  while (1) {
    buf = ReadStream(str, 4);
    if (!memcmp(buf, "ACT!", 4)) {
      /* Suck out an activation record - argh! */
      TRACE(rinvoke, 6, ("Incoming activation record!!"));
      (void)extractActivation(o, ct, str, srv);
    } else if (!memcmp(buf, "DONE", 4)) {
      break;
    } else {
      assert(0);
    }
  }
  if (!isNoOID(h->ss)) {
    State *state;
    state = stateFetch(h->ss, h->sslocation);
    if (!RESDNT(state->firstThing)) {
      replyh = *h;
      replyh.kind = MoveReply;
      replyh.status = 0;
      reply = StartMsg(&replyh);
      TRACE(rinvoke, 4, ("Send successful move reply to %s @ %s",
			 OIDString(h->ss), NodeString(h->sslocation)));
      sendMsgTo(replyh.sslocation, reply, replyh.ss);
    } else {
      state->nstoid = nooid;
      TRACE(rinvoke, 4, ("Move done, informing state %s",
			 OIDString(h->ss)));
      assert(ISetMember(allProcesses, (int)state));
      makeReady(state);
    }
  }
  TRACE(rinvoke, 4, ("Move request done"));
  inhibit_gc--;
}
  
void findActivationsInObject(Object, Stream);

void movecpcallback(Object o)
{
  TRACE(rinvoke, 6, ("Moving %#x a %.*s, too",
		     o, CODEPTR(o->flags)->d.name->d.items,
		     CODEPTR(o->flags)->d.name->d.data));
  becomeStub(o, CODEPTR(o->flags), getNodeRecordFromSrv(ctsrv));
}

int move(int option1, Object obj, Node srv, State *state)
{
  Stream str;
  ConcreteType ct;
  RemoteOpHeader h;
  Node currentloc;
  noderecord *nr = getNodeRecordFromSrv(srv);

  if (!nr->up) {
    RemoteOpHeader h;
    TRACE(rinvoke, 2, ("Not moving %s to dead node %s", OIDString(OIDOf(obj)), NodeString(srv)));
    h.target = OIDOf(obj);
    h.targetct = OIDOf(CODEPTR(obj->flags));
    moveDone(state, &h, 1);
    return 0;
  }
  regRoot(obj);
  regRoot(state);
  anticipateGC(64 * 1024);
  unregRoot();
  unregRoot();
  ct = CODEPTR(obj->flags);

  
  h.kind = MoveRequest;
  h.option1 = option1;
  h.option2 = duringInitialization(obj);
  h.target = FOIDOf(obj);
  h.targetct = OIDOf(ct);
  if (state->op == obj) {
    h.ss = nooid;
    h.sslocation = myid;
  } else {
    h.ss = FOIDOf((Object)state);
    h.sslocation = getLocFromObj((Object)state);
    state->nstoid = h.target;
  }

  if (RESDNT(obj->flags)) {
    TRACE(rinvoke, 3, ("Moving %#x %s a %.*s from here to %s", obj,
		       OIDString(h.target),
		       ct->d.name->d.items, ct->d.name->d.data,
		       NodeString(srv));)
    str = StartMsg(&h);

    checkpointCallback = movecpcallback;
    checkpointCTCallback = ctcallback;
    checkpointCTIntermediateCallback = cticallback;
    ctstr = str;
    ctsrv = srv;
    Checkpoint(obj, ct, str);
    checkpointCallback = 0;
    ctstr = 0;
    memset(&ctsrv, 0, sizeof(ctsrv));
    memmove(WriteStream(str, 4), "DONE", 4);

    becomeStub(obj, ct, getNodeRecordFromSrv(srv));
    findActivationsInObject(obj, str);
    if (duringInitialization(obj)) thaw(obj, RInitially);

    sendMsg(srv, str);
  } else {
    /*
     * Send a message to the node holding the object, asking it to send
     * the object to the destination.  We'll do this like with invocations,
     * where we may get redirections.
     */
    h.kind = Move3rdPartyRequest;
    currentloc = getLocFromObj(obj);
    TRACE(rinvoke, 3, ("Asking %s to move %s a %.*s to %s",
		       NodeString(currentloc), OIDString(h.target),
		       ct->d.name->d.items, ct->d.name->d.data,
		       NodeString(srv)));
    str = StartMsg(&h);
    WriteNode(&srv, str);
    sendMsgTo(currentloc, str, h.target);
  }
  inhibit_gc--;
  return 0;
}

void handleMoveReply(RemoteOpHeader *h, Node srv, Stream str)
{
  Object obj = OIDFetch(h->target);
  State *state;

  TRACE(rinvoke, 4, ("Move done"));
  updateLocation(obj, srv);
  if (isNoOID(h->ss)) {
    /* This is for me, but there is no state waiting for the result */
  } else {
    state = stateFetch(h->ss, h->sslocation);
    if (!RESDNT(state->firstThing)) {
      TRACE(rinvoke, 4, ("Forwarding move done to new ss location %s", 
			 NodeString(getLocFromObj((Object)state))));
      if (forwardMsg(getLocFromObj((Object)state), h, str) < 0) {
	Stream newstr;
	RewindStream(str);
	newstr = StealStream(str);
	findAndSendTo(h->ss, newstr);
      }
    } else {
      assert(ISetMember(allProcesses, (int)state));
      state->nstoid = nooid;
      if (!h->status || !debug(state, "Move failure")) {
	makeReady(state);
      }
    }
  }
}

ConcreteType buildSpoofCT(Template t, int size)
{
  ConcreteType ct;
  ConcreteType covct = BuiltinInstCT(COPVECTORI);

  ct = gc_malloc(sizeof *ct);
  SETRESDNT(ct->flags);
  SETCODEPTR(ct->flags, ctct);
  if (inDistGC()) SETDISTGC(ct->flags);
  ct->d.name = TrueString;
  ct->d.filename = TrueString;
  ct->d.template = t;
  ct->d.instanceSize = size;
  ct->d.instanceFlags = HASODPBIT;
  ct->d.opVector = (OpVector)CreateVector(covct, 3);
  return ct;
}

void sendNVars(Stream str, int n, int *args, Object ep, ConcreteType et)
{
  ConcreteType spoofvCT = BuiltinInstCT(VECTOROFANYI);
  Vector spoofv;
  OID oido;

  spoofv = (Vector) gc_malloc(sizeof(FirstThing) + sizeof(u32) + 8 * (n + 1));
  spoofv->d.items = n + 1;
  SETRESDNT(spoofv->flags);
  SETCODEPTR(spoofv->flags, spoofvCT);
  if (inDistGC()) SETDISTGC(spoofv->flags);

  *(Object *)spoofv->d.data = ep;
  *(ConcreteType *)(spoofv->d.data + 4) = et;
  memcpy(spoofv->d.data + 8, args, 8 * n);

  NewOID(&oido); OIDInsert(oido, (Object) spoofv);
  WriteOID(&oido, str);
  ctstr = str;
  checkpointCTCallback = ctcallback;
  checkpointCTIntermediateCallback = cticallback;
  Checkpoint((Object)spoofv, spoofvCT, str);
  ctstr = 0;
  memmove(WriteStream(str, 4), "DONE", 4);
  OIDRemove(oido, (Object)spoofv);
}

void extractNVars(Stream str, int n, int *args, Object *epp, ConcreteType *etp,
		  Node srv)
{
  Vector spoofv;
  OID oido;

  ReadOID(&oido, str);
  spoofv = (Vector) ExtractObjects(str, srv);
  spoofv = (Vector) OIDFetch(oido);

  OIDRemove(oido, (Object)spoofv);

  *epp = *(Object *)spoofv->d.data;
  *etp = *(ConcreteType *)(spoofv->d.data + 4);
  if (n >= 0) {
    assert(spoofv->d.items == n + 1);
    memcpy(args, spoofv->d.data + 8, 8 * n);
  } else {
    /* The caller didn't know how many there are, but they should be placed
     * before args
     */
    args -= (spoofv->d.items - 1) * 2;
    memcpy(args, spoofv->d.data + 8, (spoofv->d.items - 1) * 8);
  }
}

void sendNVarsAlone(Stream str, int n, int *args)
{
  ConcreteType spoofvCT = BuiltinInstCT(VECTOROFANYI);
  Vector spoofv;
  OID oido;

  spoofv = (Vector) gc_malloc(sizeof(FirstThing) + sizeof(u32) + 8 * n);
  spoofv->d.items = n;
  SETRESDNT(spoofv->flags);
  SETCODEPTR(spoofv->flags, spoofvCT);
  if (inDistGC()) SETDISTGC(spoofv->flags);

  memcpy(spoofv->d.data, args, 8 * n);

  NewOID(&oido); OIDInsert(oido, (Object) spoofv);
  WriteOID(&oido, str);
  ctstr = str;
  checkpointCTCallback = ctcallback;
  checkpointCTIntermediateCallback = cticallback;
  Checkpoint((Object)spoofv, spoofvCT, str);
  ctstr = 0;
  memmove(WriteStream(str, 4), "DONE", 4);
  OIDRemove(oido, (Object)spoofv);
}

void extractNVarsAlone(Stream str, int n, int *args, Node srv)
{
  Vector spoofv;
  OID oido;

  ReadOID(&oido, str);
  spoofv = (Vector) ExtractObjects(str, srv);
  spoofv = (Vector) OIDFetch(oido);

  OIDRemove(oido, (Object)spoofv);

  if (n >= 0) {
    assert(spoofv->d.items == n);
    memcpy(args, spoofv->d.data, 8 * n);
  } else {
    /* The caller didn't know how many there are, but they should be placed
     * before args
     */
    args -= spoofv->d.items * 2;
    memcpy(args, spoofv->d.data, spoofv->d.items * 8);
  }
}

void getPreviousState(State *state, OID *oidp, Node *locp)
{

  *oidp = state->psoid;
  if (!isNoOID(state->psoid)) {
    *locp = getLocFromObj((Object)stateFetch(state->psoid, limbo));
  } else {
    *locp = getMyLoc();
  }
}

/*
 * Return true if we added all of the activations (so we don't need the stack)
 * any more.
 */
int addActivations(State *state, Stream str, int ready)
{
  ConcreteType spoofCT = 0;
  int opindex = findOpVectorIndex(state->cp, state->pc);
  OpVectorElement ove = state->cp->d.opVector->d.data[opindex];
  int templateSize = sizeFromTemplate(ove->d.template);
  int nargsandress;
  Object spoof = 0;
  OID oido, oidct, prevstateoid, newstateoid;
  Node prevstatesrv;
  int result, howmany, pcoffset;
  
  pcoffset = state->pc - (u32)ove->d.code->d.data;
  if (pcoffset) {
    spoofCT = buildSpoofCT(ove->d.template, templateSize);
    spoof = gc_malloc(templateSize + sizeof(FirstThing));
    SETRESDNT(spoof->flags);
    SETCODEPTR(spoof->flags, spoofCT);
    if (inDistGC()) SETDISTGC(spoof->flags);
    memcpy(spoof->d, (void *)state->fp, templateSize);
  }
  memmove(WriteStream(str, 4), "ACT!", 4);
  WriteInt(ready, str);
  TRACE(rinvoke, 5, ("Adding activation for op %d in object %#x a %.*s",
		     opindex, state->op,
		     state->cp->d.name->d.items, state->cp->d.name->d.data));

  newstateoid = OIDOf(state);
  WriteOID(&state->nsoid, str);
  WriteOID(&state->nstoid, str);
  if (bottomStackFrame(state)) {
    /*
     * Don't bother coming back here, go to the previous one instead
     * Also, no need to allocate a new oid for the part of the stack 
     * left behind.
     */
    TRACE(rinvoke, 7, ("Nothing to come back to"));
    getPreviousState(state, &prevstateoid, &prevstatesrv);
    state->nsoid = nooid;
    state->nstoid = nooid;
    result = 1;
  } else {
    OIDRemoveAny((Object)state);
    /* Allocate an oid for the left over piece of the stack */
    NewOID(&prevstateoid);
    OIDInsert(prevstateoid, (Object)state);
    TRACE(rinvoke, 5, ("Splitting a stack created a state with OID %s", OIDString(prevstateoid)));
    state->nstoid = OIDOf(state->op);
    TRACE(process, 5, ("Setting nsoid in state %#x to %s", state, OIDString(newstateoid)));

    state->nsoid = newstateoid;
    prevstatesrv = getMyLoc();
    result = 0;
  }
  TRACE(rinvoke, 6, ("Return to state %s on %s", OIDString(prevstateoid),
	NodeString(prevstatesrv)));

  WriteOID(&newstateoid, str);
  WriteInt(opindex, str);
  WriteInt(pcoffset, str);

  WriteOID(&prevstateoid, str);
  WriteNode(&prevstatesrv, str);

  if (pcoffset) {
    howmany = !state->fp ? 0 :
      state->pc == (u32)ove->d.code->d.data ? 0 :
      (state->sp - state->fp - templateSize) / 8;
    WriteInt(howmany, str);
    if (howmany) sendNVarsAlone(str, howmany, (int *)(state->fp + templateSize));
    NewOID(&oidct); OIDInsert(oidct, (Object) spoofCT);
    NewOID(&oido); OIDInsert(oido, (Object) spoof);
    WriteOID(&oidct, str);
    WriteOID(&oido, str);

    ctstr = str;
    checkpointCTCallback = ctcallback;
    checkpointCTIntermediateCallback = cticallback;
    Checkpoint(spoof, spoofCT, str);
    ctstr = 0;
    memmove(WriteStream(str, 4), "DONE", 4);

    OIDRemove(oidct, (Object)spoofCT);
    OIDRemove(oido, spoof);
    recordSize(spoof, (templateSize + sizeof(FirstThing)) / 4);
  }
  nargsandress = ove->d.nargs + ove->d.nress;
  sendNVars(str, nargsandress, (int *)state->fp - 4 - 2 * nargsandress, state->ep, state->et);
  if (!result) performReturn(state);
  return result;
}

State *extractActivation(Object obj, ConcreteType ct, Stream str, Node srv)
{
  ConcreteType spoofCT;
  u32 opindex, pcoffset;
  OpVectorElement ove;
  int templateSize = 0, nargsandress, i, howmany, sp;
  Object spoof = 0;
  OID oido, oidct, prevstateoid, newstateoid, nsoid, nstoid;
  Node prevstatesrv;
  State *state, *prevstate;
  int *topress = 0, ready;

  ReadInt((u32 *)&ready, str);
  ReadOID(&nsoid, str);
  ReadOID(&nstoid, str);
  ReadOID(&newstateoid, str);
  ReadInt(&opindex, str);
  ReadInt(&pcoffset, str);
  ReadOID(&prevstateoid, str);
  ReadNode(&prevstatesrv, str);
  ove = ct->d.opVector->d.data[opindex];
  if (pcoffset) {
    templateSize = sizeFromTemplate(ove->d.template);

    spoofCT = buildSpoofCT(ove->d.template, templateSize);

    ReadInt((u32 *)&howmany, str);
    if (howmany) {
      topress = vmMalloc(howmany * 8);
      extractNVarsAlone(str, howmany, topress, srv);
    }

    ReadOID(&oidct, str);
    ReadOID(&oido, str);
    OIDInsert(oidct, (Object) spoofCT);

    spoof = ExtractObjects(str, srv);
    assert(spoof == OIDFetch(oido));
    OIDRemove(oidct, (Object)spoofCT);
    OIDRemove(oido, spoof);
  }
  nargsandress = ove->d.nargs + ove->d.nress;
  state = (State *)OIDFetch(newstateoid);
  if (ISNIL(state)) {
    /*
     * States get allocated ids, this one will get its real id 30 lines
     * from now.
     */
    state = newState(obj, ct);
    OIDRemoveAny((Object)state);
  } else {
    assert(!RESDNT(state->firstThing));
    setupState(state, obj, ct);
    if (!isNoOID(state->nsoid)) {
      TRACE(process, 0, ("Non resident state %#x %s with a nsoid",
			 state, OIDString(newstateoid)));
    }
  }
  state->nsoid = nsoid;
  state->nstoid = nstoid;

  extractNVars(str, nargsandress, (int *)state->sb, &state->ep, &state->et, srv);
  state->sp = state->sb + 2 * nargsandress * sizeof(int);

  pushBottomAR(state);

  sp = state->sp;
  if (pcoffset) {
    if (templateSize > 0) {
      int *args = (int *)spoof->d;
      for(i=0 ; i < templateSize / 4; i++) {
	PUSH(int, args[i]);
      }
    }
    recordSize(spoof, (templateSize + sizeof(FirstThing)) / 4);
  }

  /* set up the interpreter state */
  state->opp = ove;
  state->pc = (u32)ove->d.code->d.data + pcoffset;
  if (pcoffset && howmany) {
    for (i = 0; i < howmany * 2; i++) {
      PUSH(int, topress[i]);
    }
    vmFree(topress);
  }
  state->sp = (u32) sp;

  TRACE(rinvoke, 5, ("Got an activation %#x %s", state, OIDString(newstateoid)));
  OIDInsert(newstateoid, (Object)state);
  ISetInsert(allProcesses, (int)state);
  if (!isNoOID(prevstateoid)) {
    prevstate = stateFetch(prevstateoid, prevstatesrv);
    dependsOn(state, prevstate, ove->d.nress);
    prevstate->nstoid = OIDOf(obj);
  }
  if (ready) {
    TRACE(rinvoke, 5, ("Making the activation ready"));
    makeReady(state);
  } else {
    TRACE(rinvoke, 5, ("The activation is not runnable"));
  }
  return state;
}

void findActivationsInObject(Object obj, Stream str)
{
  State *state;
  ConcreteType ct = CODEPTR(obj->flags);
  extern ISet running;

  TRACE(rinvoke, 7, ("Looking for activations in %#x a %.*s", obj,
		     ct->d.name->d.items, ct->d.name->d.data));
  ISetForEach(allProcesses, state) {
    TRACE(rinvoke, 5, ("Looking at %x %s in %x", state,
		       OIDString(OIDOf((Object)state)), state->op));
    if (HASODP(state->cp->d.instanceFlags) && state->op == obj) {
      TRACE(rinvoke, 8, ("Found one"));
      if (addActivations(state, str, SQueueYank(ready, state) || ISetMember(running, (int)state))) {
	processMovedOut(state);
	/* Because processMovedOut removes the state from allProcesss
	 * we have to fudge with the index
	 */
	ISetxx_index --;
      }
    }
  } ISetNext();
  TRACE(rinvoke, 5, ("That is all"));
  memmove(WriteStream(str, 4), "DONE", 4);
}

void doIsFixed(Object obj, State *state, int option)
{
  Node srv;
  Stream str;
  RemoteOpHeader h;
  ConcreteType ct = CODEPTR(obj->flags);

  state->nstoid = OIDOf(obj);
  h.kind = IsFixedRequest;
  h.ss = FOIDOf((Object)state);
  h.sslocation = myid;
  h.target = OIDOf(obj);
  h.targetct = OIDOf(CODEPTR(obj->flags));
  h.option1 = option;
  srv = getLocFromObj(obj);

  /* push the header information */
  str = StartMsg(&h);
  TRACE(rinvoke, 3, ("Asking %s about fixedness of %#x %s a %.*s", obj,
		     NodeString(srv), OIDString(h.target),
		     ct->d.name->d.items, ct->d.name->d.data));

  sendMsgTo(srv, str, h.target);
}

void handleIsFixedRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  int answer;
  Object op;
  State *state;

  op = OIDFetch(h->target);
  if (!ISNIL(op) && RESDNT(op->flags)) {
    if (h->option1 == 1) {
      unfixHere(op);
      answer = JNIL;
    } else {
      answer = isFixedHere(op);
    }
    state = stateFetch(h->ss, h->sslocation);
    isFixedDone(h, state, answer);
  } else {
    Node forwardto = getLocFromObj(op);
    TRACE(rinvoke, 4, ("Forwarding isfixed request to %s", NodeString(forwardto)));
    if (forwardMsg(forwardto, h, str) < 0) {
      Stream newstr;
      RewindStream(str);
      newstr = StealStream(str);
      findAndSendTo(h->target, newstr);
    }
  }
}

void handleIsFixedReply(RemoteOpHeader *h, Node srv, Stream str)
{
  unsigned int answer;
  State *state = (State *)OIDFetch(h->ss);
  ReadInt(&answer, str);
  if (RESDNT(state->firstThing)) {
    assert(ISetMember(allProcesses, (int)state));
    if (RESDNT(state->op->flags)) {
      if (!h->option1 && !ISNIL(answer)) {
#define sp state->sp
	PUSH(int, answer);
	PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
      }
      makeReady(state);
#undef sp
    } else {
      returnToForeignObject(state, answer);
    }
  } else {
    Node forwardto = getLocFromObj((Object)state);
    TRACE(rinvoke, 4, ("Forwarding isfixed request to %s", NodeString(forwardto)));
    if (forwardMsg(forwardto, h, str) < 0) {
      Stream newstr;
      RewindStream(str);
      newstr = StealStream(str);
      findAndSendTo(h->ss, newstr);
    }
  }
}

/*
 * The indicated node has failed, investigate the state of the any pending
 * remote requests that may be proceeding on that node.  
 */
void moveHandleDown(struct noderecord *nd)
{

}
#endif /* DISTRIBUTED */

void fixHere(Object o)
{
  assert(RESDNT(o->flags));
  if (!fixedMap) fixedMap = IIScCreate();
  IIScInsert(fixedMap, (int)o, 1);
}

void forgetIsFixedHere(Object o)
{
  if (fixedMap)
    IIScDelete(fixedMap, (int)o);
}

void unfixHere(Object o)
{
  assert(RESDNT(o->flags));
  if (fixedMap)
    IIScDelete(fixedMap, (int)o);
}

int isFixedHere(Object o)
{
  if (!fixedMap) fixedMap = IIScCreate();
  return IIScLookup(fixedMap, (int)o) == 1;
}
