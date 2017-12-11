#define E_NEEDS_STRING
#include "system.h"

#include "assert.h"
#include "gc.h"
#include "iset.h"
#include "trace.h"
#include "squeue.h"
#include "oidtoobj.h"
#include "remote.h"
#include "read.h"
#include "oisc.h"
#include "locate.h"
#include "timer.h"

ISet remotegreys;
ISet interestingblacks;

#ifndef USEDISTGC
unsigned distGCBitToSend(Object o)
{
  return 0;
}
int inDistGC(void)
{
  return 0;
}
void startDistGC(void)
{}
void newGrey(Object p)
{}
void incomingObject(Object o)
{}
void incomingRef(Object o, int distgcbit)
{}
int isGrey(Object o)
{
  return 0;
}
void makeRefBlack(Object o)
{}
void makeRefGrey(Object o)
{}
void unavailableObject(Object o)
{}
#else
/*
 * The distributed garbage collector.
 *
 * The idea is following the old Emerald one described by Eric Jul and
 * implemented by Niels Christian Juul.  We need a remote grey set, and we
 * need to mark from the root at the beginning of the collection and mark
 * from every incoming grey reference during a collection.  We then just
 * need to send our remote grey and black references around whenever we want
 * and detect termination.
 */


u32  seenGreyTimestamp;
OISc lastTimestamps, newTimestamps;
static enum { dgcWorking, dgcTerminating, dgcDone} stage;
static char * stageNames[] = { "working", "terminating", "done" };

/*
 * Forwards
 */
static void dgcMarkPointers(int count, Object *p_ptr);
static void dgcMarkVariables(int count, word *p_ptr);
static void dgcMarkVariable(Object *p_ptr, ConcreteType *ct_ptr);
static void finishDistGC(u32);
static void dgcMarkOne(Object p);
int dgcMarked(Object p);

unsigned distGCBitToSend(Object o)
{
  int res;
  if (!inDistGC()) {
    return 0;
  } else {
    if (!DISTGC(o->flags)) {
      dgcMarkOne(o);
    }
    if (RESDNT(o->flags)) {
      res = DISTGCBIT;
    } else {
      res = ISetMember(remotegreys, (int)o) ? 0 : DISTGCBIT;
    }
  }
  TRACE(distgc, 5, ("Sending ref %x %s as %s", o, OIDString(OIDOf(o)),
		    res ? "black" : "grey"));
  return res;
}

int inDistGC(void)
{
  assert(distGCSeq == lastCompletedDistGCSeq ||
	 distGCSeq == lastCompletedDistGCSeq + 1);
  return distGCSeq != lastCompletedDistGCSeq;
}

Stream prepareMsg(int option, ISet s)
{
  RemoteOpHeader h;
  Object o;
  OID oid;
  Stream str;

  h.kind = DistGCInfo;
  h.option1 = option;
  str = StartMsg(&h);
  ISetForEach(s, o) {
    oid = OIDOf(o);
    if (isNoOID(oid)) {
      ISetDelete(s, (int)o);
      ISetxx_index --;
    } else {
      WriteOID(&oid, str);
    }
  } ISetNext();
  return str;
}

static int areWeDone(void)
{
  OID oid;
  u32 lastts, newts;
  OIScForEach(lastTimestamps, oid, lastts) {
    newts = OIScLookup(newTimestamps, oid);
    if (newts != lastts) return 0;
  } OIScNext();
  return 1;
}
  
void progressDistGC(void *arg)
{
  noderecord **nd;
  Stream str;
  u32 lastts;
  static int ntimessamegreysize, greysize;
  Object o;
  struct timeval one;

  if (stage == dgcDone) return;
  TRACE(distgc, 3, ("Progress distgc (%s), %d greys, %d blacks",
		    stageNames[stage],
		    ISetSize(remotegreys), ISetSize(interestingblacks)));
  if (greysize == ISetSize(remotegreys)) {
    ntimessamegreysize ++;
  } else {
    greysize = ISetSize(remotegreys);
    ntimessamegreysize = 0;
  }
  if (greysize > 0 && ntimessamegreysize > 3) {
    /*
     * Something is probably wrong, let's try locating our grey objects
     */
    ISetForEach(remotegreys, o) {
      aggressivelyLocate(o);
    } ISetNext();
  }
  for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
    /* Ignore not yet filled out entries */
    if (ISNIL(OIDFetch((*nd)->node))) continue;
    if (! (*nd)->up) continue;
    if (*nd == thisnode) continue;
    if (ISetSize(remotegreys)) {
      TRACE(distgc, 4, ("Sending remote greys (%d)", ISetSize(remotegreys)));
      str = prepareMsg(0, remotegreys);
      sendMsg((*nd)->srv, str);
    }
    if (ISetSize(interestingblacks)) {
      TRACE(distgc, 4, ("Sending interesting blacks (%d)", ISetSize(interestingblacks)));
      str = prepareMsg(1, interestingblacks);
      sendMsg((*nd)->srv, str);
    }
  }
  if (ISetSize(remotegreys) == 0 && ISetSize(interestingblacks) == 0) {
    /* Check for termination */
    if (stage == dgcTerminating) {
      /*
       * If we've received answers from everybody, we are done.
       */
      if (areWeDone()) {
	for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
	  RemoteOpHeader h;
	  /* Ignore not yet filled out entries */
	  if (ISNIL(OIDFetch((*nd)->node))) continue;
	  if (! (*nd)->up) continue;
	  if (*nd == thisnode) continue;
	  memset(&h, 0, sizeof(h));
	  h.kind = DistGCDoneReport;
	  str = StartMsg(&h);
	  WriteInt(distGCSeq, str);
	  sendMsg((*nd)->srv, str);
	}
	/*
	 * We are done, finish gc.
	 */
	finishDistGC(distGCSeq);
	return;
      } else {
	OIScDestroy(lastTimestamps);
	lastTimestamps = newTimestamps;
	newTimestamps = OIScCreate();
      }
    } else {
      /* Start trying to terminate */
      stage = dgcTerminating;
      newTimestamps = OIScCreate();
      lastTimestamps = OIScCreate();
    }
    for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
      RemoteOpHeader h;
      /* Ignore not yet filled out entries */
      if (ISNIL(OIDFetch((*nd)->node))) continue;
      if (! (*nd)->up) continue;
      if (*nd == thisnode) continue;
      memset(&h, 0, sizeof(h));
      h.kind = DistGCDoneRequest;
      str = StartMsg(&h);
      lastts = OIScLookup(lastTimestamps, (*nd)->node);
      if (ISNIL(lastts)) {
	OIScInsert(lastTimestamps, (*nd)->node, 0);
	lastts = 0;
      }
      WriteInt(lastts, str);
      sendMsg((*nd)->srv, str);
    }
  }
  ISetDeleteAll(interestingblacks);
  one.tv_sec = 0; one.tv_usec = 250000;
  afterTime(one, progressDistGC, 0);
}

static void resetDistGC(Object o)
{
  TRACE(distgc, 11, ("Clearing %x", o));
  CLEARDISTGC(o->flags);
}

static void finishDistGC(u32 whichgc)
{
  OID oid;
  Object o;
  int marked = 0, markedstates = 0, unmarkedstates = 0, removed = 0, notremoved = 0;
  extern int nDGCremoved;
  if (whichgc == lastCompletedDistGCSeq) {
    TRACE(distgc, 3, ("Extraneous finish distgc"));
    return;
  }
  TRACE(distgc, 1, ("Dist GC #%d is done", distGCSeq));
  if (stage == dgcTerminating) {
    assert(newTimestamps);
    assert(lastTimestamps);
  }
  stage = dgcDone;
  lastCompletedDistGCSeq = distGCSeq;

  if (newTimestamps) {
    OIScDestroy(newTimestamps); newTimestamps = 0;
  }
  if (lastTimestamps) {
    OIScDestroy(lastTimestamps); lastTimestamps = 0;
  }
  ISetDestroy(remotegreys); remotegreys = 0;
  ISetDestroy(interestingblacks); interestingblacks = 0;

  OTableForEach(ObjectTable, oid, o) {
    if (!wasGCMalloced(o)) {
      if (dgcMarked(o)) {
	markedstates++;
      } else {
	unmarkedstates++;
	if (RESDNT(o->flags)) {
	  TRACE(distgc, 3, ("Why is a local state %#x not marked??", o));
	} else {
	  TRACE(distgc, 4, ("Deleting %#x a state with oid %s", o,
			    OIDString(oid)));
	  deleteState((State *)o);
	}
      }
    } else if (!dgcMarked(o)) {
      if (!isBuiltinOID(oid) &&
	  RESDNT(o->flags) && !ISIMUT(CODEPTR(o->flags)->d.instanceFlags)) {
	TRACE(distgc, 4, ("DGC removing OID %s from %#x a %s %.*s",
			  OIDString(oid), o,
			  RESDNT(o->flags) ? "resident" : "remote",
			  CODEPTR(o->flags)->d.name->d.items,
			  CODEPTR(o->flags)->d.name->d.data));
	OIDRemove(oid, o);
	removed++;
      } else {
	notremoved++;
      }
    } else {
      marked++;
    }
  } OTableNext();
  nDGCremoved += removed;
  TRACE(distgc, 2, ("Dist GC %d: finished cleaning object table", distGCSeq));
  TRACE(distgc, 2, ("%d marked states, %d unmarked states, %d marked, %d removed, %d notremoved",
		    markedstates, unmarkedstates, marked, removed, notremoved));
}

static void countMarkedOIDs(int *objects, int *states)
{
  OID oid;
  Object o;

  *objects = *states = 0;
  OTableForEach(ObjectTable, oid, o) {
    if (!wasGCMalloced(o)) (*states)++;
    else if (dgcMarked(o)) (*objects)++;
  } OTableNext();
}

int countStubs(void)
{
  int count = 0;
  OID oid;
  Object o;

  OTableForEach(ObjectTable, oid, o) {
    if (wasGCMalloced(o) && !RESDNT(o->flags)) count++;
  } OTableNext();
  return count;
}

static void doToAllStates(void (*f)(Object))
{
  OID oid;
  Object o;

  OTableForEach(ObjectTable, oid, o) {
    if (!wasGCMalloced(o)) f(o);
  } OTableNext();
}

void startDistGC(void)
{
  if (inDistGC()) return;
  assert(!remotegreys);
  extern int nDGCs;
  nDGCs ++;
  remotegreys = ISetCreate();
  interestingblacks = ISetCreate();
  stage = dgcWorking;
  seenGreyTimestamp = 1;
  distGCSeq ++;
  TRACE(distgc, 1, ("Starting dist GC #%d", distGCSeq));
  doToNewGeneration(resetDistGC, 0);
  doToOldGeneration(resetDistGC, 0);
  doToAllStates(resetDistGC);
  
  /* Mark */
  TRACE(distgc, 3, ("Marking from roots %d OIDs", OTableSize(ObjectTable)));
  doToExternalRoots(dgcMarkPointers, dgcMarkVariable, dgcMarkVariables, 0, 0);
  IFTRACE(distgc, 3) {
    int objects, states;
    countMarkedOIDs(&objects, &states);
    TRACE(distgc, 3, ("Done marking from roots, %d marked, %d states", objects, states));
  }
  progressDistGC(0);
}

void restartDistGC(int seq)
{
  TRACE(distgc, 1, ("Restarting distgc %d (was %d)", seq, distGCSeq));
  if (remotegreys) {
    ISetDestroy(remotegreys); remotegreys = 0;
  }
  if (interestingblacks) {
    ISetDestroy(interestingblacks); interestingblacks = 0;
  }
  if (newTimestamps) {
    OIScDestroy(newTimestamps); newTimestamps = 0;
  }
  if (lastTimestamps) {
    OIScDestroy(lastTimestamps); lastTimestamps = 0;
  }
  lastCompletedDistGCSeq = distGCSeq = seq - 1;
  startDistGC();
}

static void dgcMarkFields(Object p);

int isGrey(Object o)
{
  return ISetMember(remotegreys, (int)o);
}

void newGrey(Object p)
{
  ISetInsert(remotegreys, (int)p);
  seenGreyTimestamp ++;
  if (stage == dgcTerminating) {
    stage = dgcWorking;
    assert(newTimestamps);
    assert(lastTimestamps);
    OIScDestroy(newTimestamps); newTimestamps = 0;
    OIScDestroy(lastTimestamps); lastTimestamps = 0;
  }
  TRACE(distgc, 4, ("Remote object %x %s is grey", p,
		    OIDString(OIDOf(p))));
}

static void dgcMark(Object p)
{
  if (ISNIL(p)) return;
  TRACE(distgc, 9, ("Looking at %#x %s a %s %s %s",
		    p, OIDString(OIDOf(p)),
		    DISTGC(p->flags) ? "marked" : "unmarked",
		    RESDNT(p->flags) ? "local" : "remote",
		    wasGCMalloced(p) ? "object" : "state"));

  if (dgcMarked(p)) return;
  TRACE(distgc, 10, ("Marking %#x", (unsigned int)p));
		       
  SETDISTGC(p->flags);
  if (!RESDNT(p->flags) && !isNoOID(OIDOf(p))) {
    newGrey(p);
  }
  if (wasGCMalloced(p)) {
    push_ms(p);
  }
}

int dgcMarked(Object p)
{
  return DISTGC(p->flags);
}

static void dgcFlush(void)
{
  Object p;

  while (stack_top != 0) {
    p = move_stack[--stack_top];
    assert(dgcMarked(p));
    dgcMarkFields(p);
  }
}
  
static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}

static void dgcMarkFields(Object p)
{
  word *p_ptr;
  Template temp;
  char *brands, c;
  int count, star;
  ConcreteType ct;
  Object old;

  p_ptr = (word *)p + 1;
  ct = CODEPTR(p->flags);
  dgcMark((Object)ct);
  temp = ct->d.template;

  /* nothing following the first thing of object p */
  if (ISNIL(temp)) return;

  if (!RESDNT(p->flags)) {
    /*
     * This is a stub, so we don't need to do anything.
     */
    TRACE(distgc, 5, ("Not marking the fields of %#x, a stub for a %.*s",
		      p, ct->d.name->d.items, ct->d.name->d.data));
    return;
  }
  TRACE(distgc, 5, ("Marking the fields of %#x, a %.*s",
		    p, ct->d.name->d.items, ct->d.name->d.data));

  brands = (char *) temp->d.data;
  while (1) {
    switch (*brands++) {
    case '%':
      count = 0;
      star = 0;
      while (misdigit (c = *brands++)) {
	count = count * 10 + c - '0';
      }
      if (!count) count = 1;
      if (c == '*') {
	count = *p_ptr++;
	star = 1;
	c = *brands++;
      }
      switch (c) {
      case 'm':
	p_ptr += count * 2;
	break;
      case 'x':
      case 'X':
	while (count--) {
	  old = (Object) *p_ptr;
	  dgcMark(old);
	  p_ptr++;
	}
	break;
      case 'v':
      case 'V':
	while (count--) {
#ifdef USEABCONS
	  AbCon abcon = (AbCon)p_ptr[1];
	  ct = ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
#else
	  ct = (ConcreteType) p_ptr[1];
#endif
	  if (varContainsPointer(ct)) {
	    old = (Object) *p_ptr;
	    dgcMark(old);
	  }
	  dgcMark((Object)ct);
	  p_ptr += 2;
	}
	break;
      case 'l':
      case 'L':
	TRACE(distgc, 5, ("Marking literals at %#x", p));
	count /= 4;
	while (count --) {
	  p_ptr += 3;
	  old = (Object) *p_ptr;
	  dgcMark(old);
	  TRACE(distgc, 8, ("Literal: %#x", old));
	  p_ptr++;
	}
	break;
      case 'q':
	{
	  Object st;
	  TRACE(distgc, 5, ("Marking squeue of condition at %#x", p));
	  assert(count == 1);
	  SQueueForEach((SQueue)*p_ptr, st) {
	    dgcMark(st);
	  } SQueueNext();
	  p_ptr ++;
	}
	break;
      case 'd':
      case 'D':
      case 'f':
      case 'F':
	p_ptr += count;
	break;
      case 'c':
      case 'C':
      case 'b':
      case 'B':
	if (star) count = (count + 3) / 4;
	p_ptr += count;
	break;
      default:
	fprintf (stderr, "cannot figure out brand\n");
	break;
      }
      break;
    case '\0':
      return;
    default:
      fprintf (stderr, "what is '%c' doing in a template?\n", brands[-1]);
      break;
    }
  }
}

static void dgcMarkVariable(Object *p_ptr, ConcreteType *ct_ptr)
{
  ConcreteType ct;
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)*ct_ptr;
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
  ct = *ct_ptr;
#endif

  if (varContainsPointer(ct)) {
    dgcMark(*p_ptr);
  }
  dgcMark((Object) ct);
  dgcFlush();
}

static void dgcMarkVariables(int count, word *p_ptr)
{
  ConcreteType ct;
  while (count--) {
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)p_ptr[1];
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
    ct = (ConcreteType) p_ptr[1];
#endif
    if (varContainsPointer(ct)) {
      dgcMark((Object) *p_ptr);
    }
    dgcMark((Object) ct);
    p_ptr += 2;
  }
  dgcFlush();
}

static void dgcMarkPointers(int count, Object *p_ptr)
{
  while (count-- > 0) {
    dgcMark(*p_ptr);
  }
  dgcFlush();
}

static void dgcMarkOne(Object p)
{
  dgcMark(p);
  dgcFlush();
}

void unavailableObject(Object o)
{
  if (!inDistGC()) return;
  TRACE(distgc, 5, ("Unavailable object %x %s", o, OIDString(OIDOf(o))));
  if (ISetMember(remotegreys, (int)o)) {
    TRACE(distgc, 1, ("Grey object %x %s is lost", o, OIDString(OIDOf(o))));
    ISetDelete(remotegreys, (int)o);
  }
}
  
void incomingObject(Object o)
{
  if (!inDistGC()) return;
  TRACE(distgc, 5, ("Incoming object %x %s",
		    o, OIDString(OIDOf(o))));
  assert(RESDNT(o->flags));
  CLEARDISTGC(o->flags);
  dgcMarkOne(o);
  if (ISetMember(remotegreys, (int)o)) {
    TRACE(distgc, 5, ("Grey object %x %s becomes black", o, OIDString(OIDOf(o))));
    ISetDelete(remotegreys, (int)o);
  }
}

void makeRefBlack(Object o)
{
  ISetDelete(remotegreys, (int)o);
}

void makeRefGrey(Object o)
{
  ISetInsert(remotegreys, (int)o);
}

void incomingRef(Object o, int distgcbit)
{
  if (!inDistGC()) {
    TRACE(distgc, 0, ("Incoming ref for %x %s when not in distgc",
		      o, OIDString(OIDOf(o))));
    return;
  }
  if (distgcbit && RESDNT(o->flags) && !DISTGC(o->flags)) {
    TRACE(distgc, 0, ("Incoming black ref for non marked object %x %s",
		      o, OIDString(OIDOf(o))));
    distgcbit = 0;
  }
  if (!distgcbit) {
    /*
     * The other side thinks this object is grey.
     */
    TRACE(distgc, 5, ("Incoming grey ref %x %s", o, OIDString(OIDOf(o))));
    if (RESDNT(o->flags)) {
      ISetInsert(interestingblacks, (int)o);
      if (!DISTGC(o->flags)) dgcMarkOne(o);
    }
  } else if (ISetMember(remotegreys, (int)o)) {
    TRACE(distgc, 5, ("Grey object %x %s becomes black", o, OIDString(OIDOf(o))));
    ISetDelete(remotegreys, (int)o);
  } else {
    TRACE(distgc, 5, ("Black report for black object %x %s", o, OIDString(OIDOf(o))));
  }
}

void distGCFreeState(State *state)
{
  if (!inDistGC()) return;
  if (ISetMember(remotegreys, (int)state)) {
    ISetDelete(remotegreys, (int)state);
  }
  if (ISetMember(interestingblacks, (int)state)) {
    ISetDelete(interestingblacks, (int)state);
  }
}
    
void handleDistGCDoneRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  u32 ts;
  RemoteOpHeader replyh;
  Stream reply;

  ReadInt(&ts, str);
  TRACE(distgc, 7, ("DistGCDoneRequest %d received", ts));
  if (remotegreys && ISetSize(remotegreys) > 0) {
    TRACE(distgc, 7, ("DistGCDone not replying, have %d greys", ISetSize(remotegreys)));
  } else {
    replyh = *h;
    replyh.kind = DistGCDoneReply;
    reply = StartMsg(&replyh);
    WriteInt(seenGreyTimestamp, reply);
    sendMsg(srv, reply);
    TRACE(distgc, 7, ("DistGCDone sending %d", seenGreyTimestamp));
  }
}

void handleDistGCDoneReply(RemoteOpHeader *h, Node srv, Stream str)
{
  u32 ts;
  noderecord *nd;

  TRACE(distgc, 4, ("DistGCDoneReply from %s received",
		    NodeString(srv)));
  ReadInt(&ts, str);
  nd = getNodeRecordFromSrv(srv);
  TRACE(distgc, 4, ("Got %d from node %s", ts, OIDString(nd->node)));
  if (newTimestamps)
    OIScInsert(newTimestamps, nd->node, ts);
}

void handleDistGCDoneReport(RemoteOpHeader *h, Node srv, Stream str)
{
  u32 whichgc;
  ReadInt(&whichgc, str);
  finishDistGC(whichgc);
}

void handleDistGCInfo(RemoteOpHeader *h, Node srv, Stream str)
{
  Object o;
  OID oid;
  TRACE(distgc, 3, ("DistGCInfo %s received from %s",
		    h->option1 ? "black" : "grey", NodeString(srv)));
  if (!inDistGC())
    startDistGC();
  while (!AtEOF(str)) {
    ReadOID(&oid, str);
    o = OIDFetch(oid);
    if (!ISNIL(o)) 
      incomingRef(o, h->option1 ? DISTGCBIT : 0);
  }
  TRACE(distgc, 4, ("Done with %s DistGCInfo from %s",
		    h->option1 ? "black" : "grey", NodeString(srv)));
}
#endif
