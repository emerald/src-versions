/*
 * locate.c - support for finding remote objects
 */

#define E_NEEDS_STRING
#define E_NEEDS_IOV
#include "system.h"

#include "bufstr.h"
#include "remote.h"
#include "locate.h"

OISc outstandingLocates;
void doAggressiveLocate(Object o, locationRecord *l);

#ifdef DISTRIBUTED
static locationRecord *locationInProgress(OID oid)
{
  locationRecord *l;
  if (!outstandingLocates) outstandingLocates = OIScCreateN(16);
  l = (locationRecord *)OIScLookup(outstandingLocates, oid);
  return OIScIsNIL(l) ? 0 : l;
}

static locationRecord *newLocation(Object obj, ConcreteType ct)
{
  locationRecord *l = (locationRecord *)vmMalloc(sizeof *l);
  l->oid = OIDOf(obj);
  l->ctoid = OIDOf(ct);
  l->stage = LEasy;
  l->count = 1;
  l->outstandingRequests = 0;
  l->waitingStates = ISetCreate();
  l->waitingMsgs = ISetCreate();
  OIScInsert(outstandingLocates, l->oid, (int)l);
  TRACE(locate, 5, ("Added a location record for %s, now %d", OIDString(l->oid), OIScSize(outstandingLocates)));
  return l;
}

static void locationResolved(locationRecord *l, Node srv)
{
  State *state;  Stream str;
  OID oid = l->oid;
  Object obj = OIDFetch(oid);

  if (SameNode(srv, limbo)) {
    TRACE(locate, 1, ("Object %s lost because %s",
		      OIDString(oid),
		      (l->count == LOCATE_TIMES_TO_TRY) ? "count exceeded" :
		      (ISetSize(l->outstandingRequests) == 0) ? "0 set size" :
		      (RESDNT(obj->flags)) ? "resident" : "found somewhere"));
  }
  TRACE(locate, 3, ("Object %s has been found at %s",
		     OIDString(oid),
		     SameNode(srv, limbo) ? "limbo" : NodeString(srv)));

  if (!ISNIL(obj) && !wasGCMalloced(obj) && SameNode(srv, limbo)) {
    unavailableState((State *)obj);
  }

  if (!ISNIL(obj) && !RESDNT(obj->flags)) {
    updateLocation(obj, srv);
    if (SameNode(srv, limbo)) {
      checkForUnavailableInvokes(obj);
      unavailableObject(obj);
    }
  }

  if (RESDNT(obj->flags)) {
    TRACE(locate, 1, ("Object moved back here"));
  }

  ISetForEach(l->waitingStates, state) {
    /*
     * We need to remove it so that when we delete the state we don't panic.
     */
    l->waitingStates->table[ISetxx_index].key = 0;
    l->waitingStates->count --;
    if (!RESDNT(state->firstThing)) {
      RemoteOpHeader h;
      Stream str;

      TRACE(locate, 4, ("Informing state %s", NodeString(getLocFromObj((Object)state))));
      h.kind = LocateReply;
      h.option1 = 0;
      h.status = 0;
      h.target = l->oid;
      h.targetct = l->ctoid;
      h.ss = nooid;
      h.sslocation = myid;
      str = StartMsg(&h);
      sendMsgTo(getLocFromObj((Object)state), str, OIDOf(state));
    } else if (SameNode(srv, limbo)) {
      if (!unavailable(state, obj)) makeReady(state);
    } else {
#define sp state->sp
      PUSH(Object, getNodeFromSrv(srv));
      PUSH(ConcreteType, BuiltinInstCT(NODEI));
#undef sp
      makeReady(state);
    }
  } ISetNext();
  OIScDelete(outstandingLocates, l->oid);
  ISetDestroy(l->waitingStates);
  l->waitingStates = 0;
  ISetForEach(l->waitingMsgs, str) {
    if (RESDNT(obj->flags)) {
      Stream upstr;
      TRACE(locate, 1, ("Location resolved here, can't send the message to myself"));
      upstr = WriteToReadStream(str, 1);
      doRequest(myid, upstr);
    } else if (SameNode(srv, limbo)) {
      sendUnavailableReply(str);
    } else {
	if (sendMsg(srv, str) < 0) {
	    TRACE(locate, 1, ("locationResolved:  can't send reply"));
	};
    }
  } ISetNext();
  ISetDestroy(l->waitingMsgs);
  l->waitingMsgs = 0;
  if (l->outstandingRequests) {
    ISetDestroy(l->outstandingRequests);
    l->outstandingRequests = 0;
  }
  TRACE(locate, 5, ("Deleted a location record for %s, now %d", OIDString(l->oid), OIScSize(outstandingLocates)));
  vmFree(l);
}
    
void locateHandleDown(noderecord *nd)
{
  OID oid;
  locationRecord *l;

  if (!outstandingLocates) return;
  TRACE(locate, 2, ("Dead node won't answer location requests"));
  OIScForEachBackwards(outstandingLocates, oid, l) {
    if (l->outstandingRequests && ISetMember(l->outstandingRequests, (int)nd)){
      TRACE(locate, 3, ("Outstanding %s locate request to dead node for %s",
			l->stage == LEasy ? "easy" : "aggressive",
			OIDString(oid)));
      ISetDelete(l->outstandingRequests, (int)nd);
      if (ISetSize(l->outstandingRequests) ==  0) {
	/* We got no from everybody */
	if (l->count >= LOCATE_TIMES_TO_TRY) {
	  locationResolved(l, limbo);
	  OIScxx_index ++;
	} else {
	  l->count ++;
	  l->stage = LEasy;
	  doAggressiveLocate(OIDFetch(oid), l);
	}
      }
    }
  } OIScNext();
}
      
int doEasyLocate(Object obj, locationRecord *l)
{
  Node srv;
  RemoteOpHeader h;
  srv = getLocFromObj(obj);
  if (SameNode(srv, myid)) {
    updateLocation(obj, limbo);
    return -1;
  } else if (SameNode(srv, limbo)) {
    return -1;
  } else {
    h.kind = LocateRequest;
    h.option1 = 0;
    h.target = l->oid;
    h.targetct = l->ctoid;
    h.ss = nooid;
    h.sslocation = myid;
    l->outstandingRequests = ISetCreate();
    ISetInsert(l->outstandingRequests, (int)getNodeRecordFromSrv(srv));
    if (sendMsg(srv, StartMsg(&h)) < 0) {
      TRACE(locate, 1, ("doEasyLocate: sendMsg failed"));
      ISetDelete(l->outstandingRequests, (int)getNodeRecordFromSrv(srv));
      return -1;
    }
    return 0;
  }
}

void doAggressiveLocate(Object o, locationRecord *l)
{
  noderecord **nd;
  Stream str;

  TRACE(locate, 3, ("Aggressively locating %s", OIDString(OIDOf(o))));
  if (l->stage == LAggressive) return;
  l->stage = LAggressive;
  if (!l->outstandingRequests)
    l->outstandingRequests = ISetCreate();
  for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
    RemoteOpHeader h;
    /* Ignore not yet filled out entries */
    if (ISNIL(OIDFetch((*nd)->node))) {
      TRACE(locate, 4, ("Can't fetch the node for %s", OIDString((*nd)->node)));
      continue;
    }
    if (! (*nd)->up) {
      TRACE(locate, 4, ("Node %s is not up", OIDString((*nd)->node)));
      continue;
    }
    if (*nd == thisnode) {
      TRACE(locate, 4, ("Node %s is me", OIDString((*nd)->node)));
      continue;
    }
    memset(&h, 0, sizeof(h));
    h.kind = LocateRequest;
    h.option1 = 1;
    h.target = l->oid;
    h.targetct = l->ctoid;
    h.ss = nooid;
    h.sslocation = myid;
    str = StartMsg(&h);
    if (sendMsg((*nd)->srv, str) >= 0) {
      ISetInsert(l->outstandingRequests, (int)(*nd));
    } else {
      TRACE(locate, 4, ("Can't send message to %s srv %s",
			OIDString((*nd)->node), NodeString((*nd)->srv)));
    }
  }
  if (ISetSize(l->outstandingRequests) == 0) {
    locationResolved(l, limbo);
  } else {
    TRACE(locate, 4, ("%d outstanding requests for %s",
	  ISetSize(l->outstandingRequests), OIDString(l->oid)));
  }
}

void findLocation(Object obj, ConcreteType ct, State *state, Stream str)
{
  locationRecord *l = locationInProgress(OIDOf(obj));
  int isnew = 0;
  if (!l) {
    l = newLocation(obj, ct);
    isnew = 1;
  }
  if (state) {
    ISetInsert(l->waitingStates, (int)state);
  } else if (str) {
    ISetInsert(l->waitingMsgs, (int)str);
  }
  if (isnew) {
    if (doEasyLocate(obj, l) < 0) {
      doAggressiveLocate(obj, l);
    }
  }
}

/*
 * We suspect that it is gone, make sure.
 */
void aggressivelyLocate(Object obj)
{
  locationRecord *l = locationInProgress(OIDOf(obj));
  if (!l) {
    l = newLocation(obj, CODEPTR(obj->flags));
  }
  doAggressiveLocate(obj, l);
}

Object whereIs(Object obj, ConcreteType ct)
{
#ifdef DISTRIBUTED
  if (ISNIL(obj) || 
      !HASODP(ct->d.instanceFlags) ||
      RESDNT(obj->flags)) {
    return OIDFetch(thisnode->node);
  } else {
    return getNodeFromObj(obj);
  }
#else
  assert(0);
#endif
}

void handleLocateRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  RemoteOpHeader replyh;
  Stream reply;
  Object obj; ConcreteType ct;
  Node loc;

  TRACE(locate, 3, ("Locating %s", OIDString(h->target)));

  /* figure out who we're locating */
  obj = OIDFetch(h->target);

  if (!ISNIL(obj)) {
    ct = CODEPTR(obj->flags);
    loc = getLocFromObj(obj);
    TRACE(locate, 4, ("It is a %.*s", 
		       ct->d.name->d.items, ct->d.name->d.data));
  }
      
  if (!ISNIL(obj) && RESDNT(obj->flags)) {
    TRACE(locate, 4, ("Got a location request for a resident object"));
    replyh = *h;
    replyh.kind = LocateReply;
    replyh.status = 0;		/* Found it here */
    reply = StartMsg(&replyh);
    if (sendMsg(h->sslocation, reply) < 0) {
	TRACE(locate, 1, ("handleLocationRequest: can't send found it here reply"));
    }
  } else if (h->option1 == 0) {
    /* Forwarding is allowed */
    if (ISNIL(obj) || SameNode(loc, limbo) || SameNode(loc, srv) || forwardMsg(loc, h, str) < 0) {
      /* we've hit the end of the line */
      replyh = *h;
      replyh.kind = LocateReply;
      replyh.status = 1;	/* Not found */
      reply = StartMsg(&replyh);
      if (sendMsg(h->sslocation, reply) < 0) {
	  TRACE(locate, 1, ("handleLocationRequest: can't send not found reply"));
      }
      TRACE(locate, 4, ("Can't find %s reply to %s",
			 OIDString(h->target), NodeString(srv)));
    } else {
      TRACE(locate, 4, ("FIXME: Not really forwarding request to %s", NodeString(loc)));
    }
  } else {
    TRACE(locate, 4, ("Got a demand-reply location request for a non resident object"));
    replyh = *h;
    replyh.kind = LocateReply;
    replyh.status = 1;		/* Not here */
    reply = StartMsg(&replyh);
    if (sendMsg(srv, reply) < 0) {
	TRACE(locate, 1, ("handleLocationRequest: can't send not found reply"));
    }
  }
}

void handleLocateReply(RemoteOpHeader *h, Node srv, Stream str)
{
  Object obj;
  locationRecord *l;
  noderecord *nd = getNodeRecordFromSrv(srv);

  TRACE(locate, 3, ("LocateReply received for %s", OIDString(h->target)));

  l = locationInProgress(h->target);
  if (!l) {
    TRACE(locate, 2, ("Spurious locate reply for unknown request"));
  } else {
    /* figure out who we were locating */
    obj = OIDFetch(h->target);
    if (ISNIL(obj)) {
      ConcreteType ct = (ConcreteType)doObjectRequest(srv, &h->targetct, ctct);
      obj = createStub(ct, limbonode, h->target);
    }
    if (RESDNT(obj->flags)) {
      TRACE(locate, 1, ("Object moved back here"));
      locationResolved(l, myid);
    } else if (h->status == 0) {
      TRACE(locate, 3, ("Located %s  at %s", OIDString(h->target),
			NodeString(srv)));
      locationResolved(l, srv);
    } else if (h->option1 == 0) {
      /* We haven't tried very hard yet */
      if (l->outstandingRequests && ISetMember(l->outstandingRequests, (int)nd)) {
	ISetDelete(l->outstandingRequests, (int)nd);
      }
      doAggressiveLocate(obj, l);
    } else {
      if (ISetMember(l->outstandingRequests, (int)nd)) {
	ISetDelete(l->outstandingRequests, (int)nd);
	if (ISetSize(l->outstandingRequests) ==  0) {
	  /* We got no from everybody */
	  if (l->count >= LOCATE_TIMES_TO_TRY) {
	    locationResolved(l, limbo);
	  } else {
	    l->count ++;
	    l->stage = LEasy;
	    doAggressiveLocate(obj, l);
	  }
	}
      } else {
	TRACE(locate, 1, ("Got a forced reply from unrequested node %s",
			  NodeString(srv)));
      }
    }
  }
}
#endif
