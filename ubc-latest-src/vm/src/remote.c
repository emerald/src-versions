/*
 * remote.c - basic infrastructure for remote operations
 */
#define E_NEEDS_NETDB
#define E_NEEDS_IOV
#define E_NEEDS_STRING
#include "system.h"

#include "assert.h"
#include "vm_exp.h"
#include "trace.h"
#include "creation.h"
#include "oidtoobj.h"
#include "read.h"
#include "write.h"
#include "bufstr.h"
#include "dist.h"
#include "streams.h"
#include "gc.h"
#include "remote.h"
#include "gaggle.h"
#include "insert.h"
#define E_NEEDS_EXTRACT_OID
#define E_NEEDS_EXTRACT_NODE
#include "extract.h"
#include "locate.h"
#include "move.h"
#include "call.h"

unsigned distGCSeq = 1, lastCompletedDistGCSeq = 1;
noderecord *allnodes = NULL, *thisnode = NULL, *limbonode = NULL;
Node limbo;
static int nodecount = 0;
Object rootdir = (Object)JNIL, node = (Object)JNIL, inctm = (Object)JNIL;
Object rootdirg = (Object)JNIL;
Object locsrv = (Object)JNIL, debugger = (Object)JNIL;
extern int doDistribution;
void *ctstr;
Node ctsrv;
#if !defined(NTRACE)
static char *typenames[] = {
  "EchoRequest",
  "EchoReply",
  "InvokeRequest",
  "InvokeReply",
  "ObjectRequest",
  "ObjectReply",
  "LocateRequest",
  "LocateReply",
  "MoveRequest",
  "MoveReply",
  "Move3rdPartyRequest",
  "Move3rdPartyReply",
  "InvokeForwardRequest",
  "InvokeForwardReply",
  "IsFixedRequest",
  "IsFixedReply",
  "GaggleUpdate",
  "DistGCInfo",
  "DistGCDoneRequest",
  "DistGCDoneReply",
  "DistGCDoneReport" };
#endif  

int isLimbo(Node n)
{
  return n.ipaddress == 0 && n.port == 0 && n.epoch == 0;
}

noderecord *getNodeRecordFromObj(Object obj)
{
  return RESDNT(obj->flags) ? thisnode : *(noderecord **)obj->d;
}

Node getMyLoc(void)
{
  return thisnode->srv;
}

Node getLocFromObj(Object obj)
{
  noderecord *nd = getNodeRecordFromObj(obj);
  return nd ? nd->srv : limbo;
}

#ifdef DISTRIBUTED
static noderecord *handleupdown(Node id, int up);
extern Object createStub(ConcreteType ct, void *stub, OID oid);

static Object ctijunk[100];
static int nextctijunkptr = 0;

void cticallback(int (*isscheduled)(IISc map, Object), IISc map)
{
  int i;
  for (i = 0; i < nextctijunkptr; i++) {
    if (!isscheduled(map, ctijunk[i])) {
      Stream str = (Stream)ctstr;
      OID id;
      id = OIDOf(ctijunk[i]);
      TRACE(rinvoke, 8, ("Checkpoint needs %s", OIDString(id)));
      memmove(WriteStream(str, 4), "CTID", 4);
      WriteOID(&id, str);
    }
  }
  nextctijunkptr = 0;
}

void ctcallback(Object o)
{
  int i;
  if (isABuiltin(o)) return;
  for (i = 0; i < nextctijunkptr; i++) {
    if (ctijunk[i] == o) return;
  }
  assert(nextctijunkptr < 100);
  ctijunk[nextctijunkptr++] = o;
}


noderecord *getNodeRecordFromSrv(Node srv)
{
  noderecord *nd;
  
  for (nd = allnodes; nd && !SameNode(srv,nd->srv); nd = nd->p) ;
  return nd;
}

void updateNodeRecord(Object obj, noderecord *nd)
{
  *(noderecord **)obj->d = nd;
}

void updateLocation(Object obj, Node srv)
{
  if (!RESDNT(obj->flags)) {
    noderecord *nd = getNodeRecordFromSrv(srv);
    if (nd != thisnode) {
      updateNodeRecord(obj, nd);
    } else {
      updateNodeRecord(obj, limbonode);
    }      
  }
}

Object getNodeFromObj(Object obj)
{
  noderecord *nd = getNodeRecordFromObj(obj);
  return nd ? OIDFetch(nd->node) : (Object)JNIL;
}

Object getNodeFromSrv(Node srv)
{
  noderecord *nd = getNodeRecordFromSrv(srv);
  return nd ? OIDFetch(nd->node) : (Object)JNIL;
}
#endif

/*
 * Read an OID from theStream into oid
 */
void ReadOID(OID *oid, Stream theStream)
{
  Bits8 *theBuffer;

  theBuffer = ReadStream(theStream, filesizeofOID);
  ExtractOID(oid, theBuffer);
}

void ReadInt(u32 *n, Stream theStream)
{
  Bits8 *theBuffer;

  theBuffer = ReadStream(theStream, sizeof(u32));
  ExtractBits32(n, theBuffer);
}


void WriteInt(u32 n, Stream str)
{
  Bits8 *theBuffer;

  theBuffer = WriteStream(str, sizeof(Bits32));
  InsertBits32(&n, theBuffer);
}

#ifdef DISTRIBUTED
void parseAddr(char *str, unsigned int *addr, unsigned short *port)
{
  char *colon, *comma;
  struct hostent *h = NULL;

  comma = (char *)strchr(str, ',');
  if (comma) *comma = '\0';
  colon = (char *)strchr(str, ':');
  if (!colon) {
    *port = EMERALDFIRSTPORT + getplane();
  } else {
    *colon = '\0';
    *port = mstrtol(colon + 1, 0, 0);
  }
  if ('a' <= str[0] && str[0] <= 'z') {
    h = gethostbyname(str);
    if (h == NULL) {
      fprintf(stderr, "parseAddr: gethostbyname failed!\n");
      return;
    } else { 
      memcpy(addr, h->h_addr, sizeof(*addr));
    }
  } else {
    *addr = inet_addr(str);
  }
  if (colon) *colon = ':';
  if (comma) *comma = ',';
}

static int ping(Node);

void objectArrived(OID oid)
{
}  
#endif

void init_nodeinfo(void)
{
  struct timeval tm;
  OID Orootdirg;
  ConcreteType ct, ctd, ctdg;
  int stack[16];
#ifdef DISTRIBUTED
  extern char *gRootNode;
  Node rootnodeid;
#endif

  TRACE(rinvoke, 5, ("Init node info"));
  if (thisnode) { return; }

  /* allocate space and new OIDs */
  limbonode = (noderecord*) vmMalloc(sizeof(noderecord));
  memset(limbonode, 0, sizeof(noderecord));
  assert(limbonode != NULL);
  limbonode->up = 0; limbonode->p = NULL; nodecount++;
  assert(!allnodes);
  allnodes = limbonode;

  /* allocate space and new OIDs */
  thisnode = (noderecord*) vmMalloc(sizeof(noderecord));
  assert(thisnode != NULL);
  NewOID(&thisnode->node);
  assert(thisnode->node.Seq == 1);
  NewOID(&thisnode->inctm);
  assert(thisnode->inctm.Seq == 2);
  thisnode->up = 1; thisnode->p = NULL; nodecount++;
  allnodes->p = thisnode;
  Orootdirg.ipaddress = 0x10101010;
  Orootdirg.port = 0x2020;
  Orootdirg.epoch = 0x3030;
  Orootdirg.Seq = 0x40404040;
  ctd = BuiltinInstCT(RDIRECTORYI); assert(ctd);
  ctdg = BuiltinInstCT(DIRECTORYGAGGLEI); assert(ctdg);
  inhibit_gc++;
#ifdef DISTRIBUTED
  thisnode->srv = myid;
#endif

  /*
   * create the IncarnationTime object.  We do this early, because in the
   * process of getting going someone else might ask us for it.
   */
  ct = BuiltinInstCT(TIMEI); assert(ct);
  if (gettimeofday(&tm, NULL) < 0) {
    perror("gettimeofday");
    time((time_t *)&tm.tv_sec); tm.tv_usec = 0;
  }
  stack[0] = (unsigned int) tm.tv_sec;
  stack[1] = (unsigned int) intct;
  stack[2] = (unsigned int) tm.tv_usec;
  stack[3] = (unsigned int) intct;
  TRACE(sys, 3, ("Creating my incarnation time"));
  inctm = CreateObjectFromOutside(ct, (u32)stack);
  OIDInsert(thisnode->inctm, inctm);

#ifdef DISTRIBUTED
  if (doDistribution) {
    DRegisterNotify((void (*)(Node, int))handleupdown);
  }
  if (!gRootNode || !strcmp(gRootNode, "here")) {
  } else if (!strcmp(gRootNode, "search")) {
    unsigned int addr;
    unsigned short port;
    int i;

    for (i = 0; i < 10; i++) {
      char *path = getenv("EMERALDMACHINES");
      if (!path || !*path) path = "localhost";
      while (path && *path) {
	parseAddr(path, &addr, &port);
	rootnodeid.ipaddress = addr;
	port = port + i * EMERALDPORTSKIP;
	rootnodeid.port = port;
	rootnodeid.epoch = 0;
	if ((rootnodeid.ipaddress == myid.ipaddress || rootnodeid.ipaddress == htonl(0x7f000001)) && rootnodeid.port == myid.port) {
	  /* This is me */
	} else {
	  TRACE(rinvoke, 1, ("Trying %s", NodeString(rootnodeid)));
	  if (DProd(&rootnodeid) >= 0) {
	    assert(rootnodeid.port == port);
	    if (ping(rootnodeid) >= 0) goto done;
	  }
	}
	path = strchr(path, ',');
	if (path) path++;
      }
    }
    printf("Can't find a running emerald node\nEMERALDMACHINES=%s\n", getenv("EMERALDMACHINES"));
  done: ;
    
  } else {
    unsigned int addr;
    unsigned short port;

    TRACE(rinvoke, 1, ("Trying to contact %s", gRootNode));
    parseAddr(gRootNode, &addr, &port);
    rootnodeid.ipaddress = addr;
    rootnodeid.port = port;
    rootnodeid.epoch = 0;
    if (DProd(&rootnodeid) < 0) {
      printf("Can't contact emerald on %s\n", gRootNode);
      exit(1);
    }
    assert(rootnodeid.port == port);
    if (ping(rootnodeid) < 0) {
      extern int checkSameUser;
      printf("Can't ping emerald on %s", gRootNode);
      if (!checkSameUser) printf(" (probably user mismatch)");
      printf("\n");
      exit(1);
    }
  }
  /* We need to create a root directory gaggle */
  rootdirg = CreateUninitializedObject(ctdg);
  OIDInsert(Orootdirg, rootdirg);
  stack[0] = (int)rootdirg;
  stack[1] = (int)ctdg;
  rootdir = CreateObjectFromOutside(ctd, (u32)stack);
  if (doDistribution) {
    printf("Emerald listening on port %d %x, epoch %d %x\n", myid.port, myid.port, myid.epoch, myid.epoch);
  }
#endif

  /* create the Node object */
  ct = BuiltinInstCT(NODEI); assert(ct);
  stack[0] = (int)rootdirg;
  stack[1] = (int)(ISNIL(rootdir) ? (ConcreteType)JNIL : CODEPTR(rootdirg->flags));
  stack[2] = MyNode.port << 16 | MyNode.epoch;
  stack[3] = (unsigned int) intct;
  TRACE(sys, 3, ("Creating my node"));
  node = CreateObjectFromOutside(ct, (u32) stack);
  OIDInsert(thisnode->node, node);
  inhibit_gc--;
}

/*
 * Read a Node from theStream into srv
 */
void ReadNode(Node *srv, Stream theStream)
{
  Bits8 *theBuffer;

  theBuffer = ReadStream(theStream, filesizeofNode);
  ExtractNode(srv, theBuffer);
}


void InsertNode(Node *t, Bits8 *data)
{
  /* no hton desired here */
  *(Bits32 *)data = t->ipaddress;
  InsertBits16(&t->port, data + 4);
  InsertBits16(&t->epoch, data + 6);
}

/*
 * Read a Node from theStream into srv
 */
void WriteNode(Node *srv, Stream theStream)
{
  Bits8 *theBuffer;

  theBuffer = WriteStream(theStream, filesizeofNode);
  InsertNode(srv, theBuffer);
}
#ifdef DISTRIBUTED
int ExtractHeader(RemoteOpHeader *h, Stream str)
{
  RemoteOpHeader *sh;
  sh = (RemoteOpHeader *)ReadStream(str, sizeof(RemoteOpHeader));
  if (!sh) return -1;

  ExtractBits32(&h->marker, (Bits8 *)&sh->marker);
  /* copy the 4 char fields */
  *((int *)h + 1) = *((int *)sh + 1);

  ExtractBits32(&h->distgcseq, (Bits8 *)&sh->distgcseq);
  ExtractOID(&h->ss, (Bits8 *)&sh->ss);
  ExtractNode(&h->sslocation, (Bits8 *)&sh->sslocation);
  ExtractOID(&h->target, (Bits8 *)&sh->target);
  ExtractOID(&h->targetct, (Bits8 *)&sh->targetct);
  if (h->marker != EMERALDMARKER) {
#ifdef WIN32MALLOCDEBUG
	  vmMallocCheck();
#endif
	  abort();
  }
  return 0;
}

Stream StartMsg(RemoteOpHeader *h)
{
  Stream str;
  RemoteOpHeader *sh;
  str = CreateStream(WriteBufferStream, NULL); assert(str);
  sh = (RemoteOpHeader *)WriteStream(str, sizeof(RemoteOpHeader));
  h->marker = EMERALDMARKER;
  h->distgcseq = distGCSeq << 1 | inDistGC();
  InsertBits32(&h->marker, (Bits8 *)&sh->marker);
  /* copy the 4 char fields */
  *((int *)sh + 1) = *((int *)h + 1);

  InsertBits32(&h->distgcseq, (Bits8 *)&sh->distgcseq);
  InsertOID(&h->ss, (Bits8 *)&sh->ss);
  InsertNode(&h->sslocation, (Bits8 *)&sh->sslocation);
  InsertOID(&h->target, (Bits8 *)&sh->target);
  InsertOID(&h->targetct, (Bits8 *)&sh->targetct);
  return str;
}

int forwardMsg(Node srv, RemoteOpHeader *h, Stream str)
{
  struct iovec oiov;
  int rval;

  RewindStream(str);
  TRACE(rinvoke, 10, ("forwardMsg: len=%d", BufferLength(str)));
  BufferToIovec(str, &oiov);
  rval = DSend(srv, oiov.iov_base, oiov.iov_len);
  return rval;
}
  
int sendMsg(Node srv, Stream str)
{
  struct iovec oiov;
  int rval;

  TRACE(rinvoke, 10, ("sendMsg: len=%d", BufferLength(str)));
  BufferToIovec(str, &oiov);
  rval = DSend(srv, oiov.iov_base, oiov.iov_len);
  DestroyStream(str);
  return rval;
}


void findAndSendTo(OID target, Stream str)
{
  Object obj = OIDFetch(target);
  if (ISNIL(obj)) {
    /*
     * This must be a state, because we throw them away too aggressively.
     */
    ConcreteType ct = BuiltinInstCT(INTERPRETERSTATEI);
    obj = createStub(ct, limbonode, target);
  }
  findLocation(obj, CODEPTR(obj->flags), 0, str);
}

void sendMsgTo(Node srv, Stream str, OID target)
{
  struct iovec oiov;

  TRACE(rinvoke, 10, ("sendMsg: len=%d", BufferLength(str)));
  BufferToIovec(str, &oiov);
  if (DSend(srv, oiov.iov_base, oiov.iov_len) < 0) {
    /*
     * Find the object, then send the message again.
     */
    TRACE(dist, 1, ("Can't send message to node %s", NodeString(srv)));
    findAndSendTo(target, str);
  } else {
    DestroyStream(str);
  }
}

void sendUnavailableReply(Stream str)
{
  RemoteOpHeader request, reply;
  Stream replystr, readstr;

  /*
   * If the stream is a write stream, then I wrote it and its reply location
   * is going to be me.  Don't bother trying to reply to yourself.
   */
  if (!IsReadStream(str)) {
    DestroyStream(str);
    return;
  }
  readstr = WriteToReadStream(str, 0);
  ExtractHeader(&request, readstr);
  DestroyStream(readstr);

  if (!SameNode(request.sslocation, myid)) {
    reply = request;
    switch (request.kind) {
    case InvokeRequest:
      reply.kind = InvokeReply;
      reply.status = 0;
      reply.option1 = 2;
      break;
    case MoveRequest:
    case Move3rdPartyRequest:
      reply.kind = MoveReply;
      reply.status = 0;
    default:
      TRACE(locate, 0, ("Can't reply about message type %s",
			typenames[request.kind]));
      DestroyStream(str);
      return;
    }
    replystr = StartMsg(&reply);
    sendMsg(request.sslocation, replystr);
  } else {
    TRACE(locate, 0, ("Can't reply to myself about message type %s",
		      typenames[request.kind]));
  }
  DestroyStream(str);
}

void doEchoRequest(struct noderecord *thisnode, Node srv)
{
  RemoteOpHeader h;
  Stream str;
  h.kind = EchoRequest;
  h.ss = nooid;
  h.sslocation = myid;
  h.target = nooid;
  h.targetct = nooid;
  str = StartMsg(&h);
  WriteInt(0, str);
  WriteOID(&thisnode->node, str);
  WriteOID(&thisnode->inctm, str);
  WriteInt(1, str);
  TRACE(rinvoke, 3, ("EchoRequest to %s", NodeString(srv)));

  if (sendMsg(srv, str) < 0) {
    printf("Can't send the echo request message\n");
    exit(1);
  }
}

void unavailableState(State *state)
{
  State *otherstate;
  Object target;
  OID oid = OIDOf(state);
  TRACE(rinvoke, 4, ("Checking for outstanding invocation for state %x %s",
		     (unsigned int)state, OIDString(OIDOf(state))));
  ISetForEach(allProcesses, otherstate) {
    if (sameOID(otherstate->nsoid, oid)) {
      target = OIDFetch(otherstate->nstoid);
      TRACE(rinvoke, 5, ("Unavailable in object %x a %.*s", target,
			 CODEPTR(target->flags)->d.name->d.items,
			 CODEPTR(target->flags)->d.name->d.data));
      TRACE(unavailable, 5, ("Raising unavailable in state %#x", otherstate));
      TRACE(process, 5, ("Resetting nsoid in state %#x", otherstate));
      otherstate->nsoid = nooid;
      otherstate->nstoid = nooid;
      if (!unavailable(otherstate, target)) makeReady(otherstate);
      /*
       * Because unavailable may remove the state from allProcesss
       * we have to fudge with the index
       */
      if (allProcesses->table[ISetxx_index].key != (int)otherstate) ISetxx_index--;
    }
  } ISetNext();
}

void checkForUnavailableInvokes(Object o)
{
  State *state;
  OID oid = OIDOf(o);

  TRACE(rinvoke, 4, ("Unavailable invokes checking %d processes", ISetSize(allProcesses)));
  ISetForEach(allProcesses, state) {
    TRACE(unavailable, 9, ("Checking state %#x", state));
    if (sameOID(state->nstoid, oid) || sameOID(state->nsoid, oid)) {
      TRACE(rinvoke, 1, ("Unavailing invocation on %s a %.*s",
			 OIDString(OIDOf(o)),
			 CODEPTR(o->flags)->d.name->d.items,
			 CODEPTR(o->flags)->d.name->d.data));
      TRACE(process, 5, ("Resetting nsoid in state %#x", state));
      state->nsoid = nooid;
      state->nstoid = nooid;
      if (!unavailable(state, o)) makeReady(state);
      /*
       * Because unavailable may remove the state from allProcesss
       * we have to fudge with the index
       */
      if (allProcesses->table[ISetxx_index].key != (int)state) ISetxx_index--;
    }
  } ISetNext();
}

static void doUpcallHandlers(Object thenode, Object theinctm, char *name)
{
  Object args[4];
  int fn, fail = 0;
  ConcreteType nodect;

  if (ISNIL(node)) return;
  nodect = BuiltinInstCT(NODEI);

  args[0] = thenode;
  args[1] = (Object)CODEPTR(thenode->flags);
  args[2] = theinctm;
  args[3] = (Object)CODEPTR(theinctm->flags);
  fn = findOpByName(nodect, name);
  upcall(node, fn, &fail, 2, 0, (int *)args);
}

static void nukeNode(noderecord *nd)
{
  Object thenode, theinctm;
  theinctm = OIDFetch(nd->inctm);
  thenode = OIDFetch(nd->node);
  nd->up = 0;
  invokeHandleDown(nd);
  moveHandleDown(nd);
  locateHandleDown(nd);
  doUpcallHandlers(thenode, theinctm, "nodedown");
}

noderecord *update_nodeinfo_fromOIDs(OID nodeOID, OID inctmOID, int up)
{
  noderecord **nd;
  Object thenode, inctm;
  ConcreteType ct;

  TRACE(rinvoke, 8, ("Updating node info for %08x.%04x.%04x -> %s", nodeOID.ipaddress, nodeOID.port, nodeOID.epoch, up ? "up": "down"));
  for(nd = &allnodes ; *nd ; nd = &((*nd)->p)) {
    if (nodeOID.ipaddress == (*nd)->node.ipaddress &&
	nodeOID.port == (*nd)->node.port &&
	nodeOID.epoch == (*nd)->node.epoch) {
      TRACE(rinvoke, 9, ("Already had one"));      
      (*nd)->up = up;
      if (!up) {
	nukeNode(*nd);
      } 
      return *nd;
    }
  }

  TRACE(rinvoke, 9, ("Making a new one"));      
  *nd = (noderecord*) vmMalloc(sizeof(noderecord));
  assert(*nd != NULL);
  (*nd)->p = NULL; nodecount++;
  (*nd)->up = up; 
  (*nd)->srv.ipaddress =  htonl(nodeOID.ipaddress);
  (*nd)->srv.port = nodeOID.port;
  (*nd)->srv.epoch = nodeOID.epoch;

  /* create the node object */
  ct = BuiltinInstCT(NODEI); assert(ct);
  (*nd)->node = nodeOID;

  thenode = doObjectRequest((*nd)->srv, &(*nd)->node, ct);
  assert(thenode && !ISNIL(thenode));

  /* retrieve the IncarnationTime object */
  ct = BuiltinInstCT(TIMEI); assert(ct);
  (*nd)->inctm = inctmOID;
  if (up) {
    inctm = doObjectRequest((*nd)->srv, &(*nd)->inctm, ct);
    if (ISNIL(inctm)) {
      TRACE(rinvoke, 0, ("update_nodeinfo: failed to retrieve inctm"));
      *nd = (*nd)->p; nodecount--; return NULL;
    }
  } else if (! ISNIL((inctm = OIDFetch((*nd)->inctm)))) {
    /* We already have the object */
  } else {
    /* TODO:
       We need to probably create a fake incarnation time object, because we
       believe that we will never have stubs for immutable objects.
     */
    int stack[512];
    ct = BuiltinInstCT(TIMEI); assert(ct);
    stack[0] = 0;
    stack[1] = (unsigned int) intct;
    stack[2] = 0;
    stack[3] = stack[1];
    inctm = CreateObjectFromOutside(ct, (u32)stack);
    OIDInsert(inctmOID, inctm);
  }
  doUpcallHandlers(thenode, inctm, up ? "nodeup" : "nodedown");
  return *nd;
}

static noderecord *handleupdown(Node id, int up)
{
  OID nodeOID, inctmOID;
  nodeOID.ipaddress = ntohl(id.ipaddress);
  nodeOID.port = id.port;
  nodeOID.epoch = id.epoch;
  nodeOID.Seq = 1;

  inctmOID = nodeOID;
  inctmOID.Seq = 2;

  TRACE(rinvoke, 8, ("Handling updown for %s -> %s", NodeString(id), up ? "up" : "down"));
  return update_nodeinfo_fromOIDs(nodeOID, inctmOID, up);
}

void update_nodeinfo(Stream str, Node srv)
{
  OID nodeOID, inctmOID;
  u32 up;
  u32 which;

  while (!AtEOF(str)) {
    TRACE(rinvoke, 10, ("Looking at another reply"));
    ReadInt(&which, str);
    if (which == 0) {
      ReadOID(&nodeOID, str);
      ReadOID(&inctmOID, str);
      ReadInt(&up, str);
      TRACE(rinvoke, 11, ("nodeoid = %s", OIDString(nodeOID)));
      TRACE(rinvoke, 11, ("inctmoid = %s", OIDString(inctmOID)));
      (void)update_nodeinfo_fromOIDs(nodeOID, inctmOID, up);
    } else if (which == 1) {
      handleGaggleUpdate(NULL, srv, str);
    } else {
      assert(0);
    }
  }
}

static int readyForBusiness;

void handleEchoReply(RemoteOpHeader *h, Node srv, Stream str)
{
  TRACE(rinvoke, 10, ("EchoReply: %d bytes", BufferLength(str)));
  TRACE(rinvoke, 4, ("EchoReply received"));
  update_nodeinfo(str, srv);
  readyForBusiness = 1;
}
  
void handleEchoRequest(RemoteOpHeader *header, Node srv, Stream str)
{
  RemoteOpHeader replyh;
  Stream reply;

  TRACE(rinvoke, 3, ("EchoRequest received"));
  if (BufferLength(str) != 2 * filesizeofOID + 2 * sizeof(u32)) {
    TRACE(rinvoke, 0, ("EchoRequest: invalid length"));
  } else {
    noderecord *n;
    update_nodeinfo(str, srv);
    replyh.kind = EchoReply;
    replyh.ss = nooid;
    replyh.sslocation = myid;
    replyh.target = nooid;
    replyh.targetct = nooid;
    reply = StartMsg(&replyh);
    
    for (n = allnodes->p; n; n = n->p) {
      TRACE(rinvoke, 6, ("EchoRequest: sending info on node %s - %s", 
			 OIDString(n->node), n->up ? "up" : "down"));
      WriteInt(0, reply);
      WriteOID(&n->node, reply);
      TRACE(rinvoke, 11, ("nodeoid = %s", OIDString(n->node)));
      WriteOID(&n->inctm, reply);
      TRACE(rinvoke, 11, ("inctmoid = %s", OIDString(n->inctm)));
      WriteInt(n->up, reply);
    }
    sendGaggleNews(srv, reply);
    sendMsg(srv, reply);
    TRACE(rinvoke, 4, ("EchoReply sent"));
  }
}

void handleObjectReply(RemoteOpHeader *h, Node srv, Stream str)
{
  Object o;
  TRACE(rinvoke, 7, ("ObjectReply received for %s", OIDString(h->target)));
  if (h->status == 0) {
    TRACE(rinvoke, 0, ("ObjectReply: remote object not found"));
  } else if (h->status == 1) {
    TRACE(rinvoke, 9, ("ObjectReply: received real object"));
    o = OIDFetch(h->target);
    if (!ISNIL(o)) {
      TRACE(rinvoke, 1, ("Got an object reply for an object I already have."));
    } else {
      o = ExtractObjects(str, srv);
      assert(OIDFetch(h->target) == o);
      CLEARBROKEN(o->flags);
      objectArrived(h->target);
    }
  } else {
    TRACE(rinvoke, 0, ("ObjectReply: didn't receive immutable object"));
  }
}

Object
doObjectRequest(Node srv, OID *oid, ConcreteType ct)
{
  Stream str;
  Object o;

  TRACE(rinvoke, 7,
	("doObjectRequest: ct '%.*s' %s",
	 ct->d.name->d.items, ct->d.name->d.data, OIDString(*oid)));
  if (! ISNIL(o = OIDFetch(*oid))) {
    TRACE(rinvoke, 8, ("doObjectRequest: found it locally"));
    return o;
  }
  if (ISIMUT(ct->d.instanceFlags)) {
    RemoteOpHeader h;
    h.kind = ObjectRequest;
    h.ss = nooid;
    h.sslocation = myid;
    h.target = *oid;
    h.targetct = OIDOf(ct);
    str = StartMsg(&h); assert(str);
    TRACE(rinvoke, 8, ("doObjectRequest, sending to node %s",
		       NodeString(srv)));
    sendMsgTo(srv, str, h.target);
    while (ISNIL(o = OIDFetch(*oid))) {
      processMessages();
    }
  } else {
    noderecord *nd;
    TRACE(rinvoke, 9, ("doObjectRequest: creating proxy to object"));
    for(nd=allnodes ; nd && ! SameNode(srv,nd->srv) ; nd=nd->p);
    if (nd) {
      TRACE(rinvoke, 9, ("proxy is on %s", NodeString(nd->srv)));
    } else {
      TRACE(rinvoke, 0, ("doObjectRequest: warning, no nd"));
    }
    o = createStub(ct, nd, *oid);
  }
  return o;
}

void handleObjectRequest(RemoteOpHeader *h, Node srv, Stream str)
{
  RemoteOpHeader replyh;
  Stream reply;
  Object o;
  ConcreteType ct;

  TRACE(rinvoke, 7, ("ObjectRequest received"));
  if (BufferLength(str) != 0) {
    TRACE(rinvoke, 0, ("ObjectRequest: invalid length"));
  } else {
    replyh.kind = ObjectReply;
    replyh.option1 = 0;
    TRACE(rinvoke, 8, ("ObjectRequest: for object %s", OIDString(h->target)));
    if ((replyh.status = !ISNIL(o = OIDFetch(h->target)))) {
      ct = CODEPTR(o->flags);
      replyh.option1 = ISIMUT(ct->d.instanceFlags) ? 1 : 0;
    }
    replyh.ss = h->ss;
    replyh.sslocation = h->sslocation;
    replyh.target = h->target;
    replyh.targetct = h->targetct;
    reply = StartMsg(&replyh);
    if (replyh.option1) {
      TRACE(rinvoke, 8, ("ObjectRequest: sending immutable object"));
      checkpointCTCallback = ctcallback;
      checkpointCTIntermediateCallback = cticallback;
      ctstr = reply;
      Checkpoint(o, CODEPTR(o->flags), reply);
      ctstr = 0;
      memmove(WriteStream(reply, 4), "DONE", 4);
    }
    sendMsg(srv, reply);
  }
}

#include "mqueue.h"
extern MQueue incoming;

void serveRequest(void)
{
  Node srv;
  Stream str;
  struct iovec iov;

  
  MQueueRemove(incoming, &srv, &iov.iov_len, (void **)&iov.iov_base);
  str = CreateStream(FreeBufferStream, &iov); assert(str);
  doRequest(srv, str);
}

void doRequest(Node srv, Stream str)
{
  RemoteOpHeader header;
  void (*handler)(RemoteOpHeader *header, Node srv, Stream str);

  if (ExtractHeader(&header, str) < 0) {
    TRACE(rinvoke, 0, ("dstsrv: runt packet received"));
    DestroyStream(str);
    return;
  }
#ifdef USEDISTGC
  TRACE(distgc, 10, ("Incoming msg from %s, type %s, distgcseq %d (%s), mine %d",
		     NodeString(srv), typenames[header.kind], header.distgcseq >> 1,
		     (header.distgcseq & 1) ? "active" : "passive", distGCSeq));
  if ((header.distgcseq >> 1) != distGCSeq) {
    int hisdistgcseq = header.distgcseq >> 1;
    int hesindistgc  = header.distgcseq & 1;
    TRACE(distgc, 3, ("Incoming distgc = %d (%s), mine = %d",
		      hisdistgcseq, hesindistgc ? "active" : "passive",
		      distGCSeq));
    if (hisdistgcseq < distGCSeq) {
      /* Ignore it */
    } else if (hesindistgc) {
      if (inDistGC()) {
	restartDistGC(hisdistgcseq);
      } else {
	if (readyForBusiness) {
	  TRACE(distgc, 1, ("Starting gc #%d", hisdistgcseq));
	  distGCSeq = lastCompletedDistGCSeq = hisdistgcseq - 1;
	  startDistGC();
	}
      }
    } else {
      /* He is passive */
      if (inDistGC()) {
	/* Shouldn't happen should it? */
	TRACE(distgc, 0, ("He's passive %d, I'm active %d",
			  hisdistgcseq, distGCSeq));
	abort();
      } else {
	lastCompletedDistGCSeq = distGCSeq = hisdistgcseq;
      }
    }
  }
#endif
  TRACE(rinvoke, 8, ("serveRequest: req by %s, msgtype=%d, len=%d",
		     NodeString(srv), header.kind,
		     BufferLength(str)));
  TRACE(rinvoke, 9, ("reply to %s @ %s",
		     OIDString(header.ss), NodeString(header.sslocation)));
  switch(header.kind) {
  case EchoRequest:
    handler = handleEchoRequest;
    break;
  case EchoReply:
    handler = handleEchoReply;
    break;
  case ObjectRequest:
    handler = handleObjectRequest;
    break;
  case ObjectReply:
    handler = handleObjectReply;
    break;
  case InvokeRequest:
    handler = handleInvokeRequest;
    break;
  case LocateRequest:
    handler = handleLocateRequest;
    break;
  case LocateReply:
    handler = handleLocateReply;
    break;
  case MoveRequest:
    handler = handleMoveRequest;
    break;
  case MoveReply:
    handler = handleMoveReply;
    break;
  case Move3rdPartyRequest:
    handler = handleMove3rdPartyRequest;
    break;
  case InvokeForwardRequest:
    handler = handleInvokeForwardRequest;
    break;
  case IsFixedRequest:
    handler = handleIsFixedRequest;
    break;
  case IsFixedReply:
    handler = handleIsFixedReply;
    break;
  case InvokeReply:
    handler = handleInvokeReply;
    break;
  case GaggleUpdate:
    handler = handleGaggleUpdate;
    break;
#ifdef USEDISTGC
  case DistGCInfo:
    handler = handleDistGCInfo;
    break;
  case DistGCDoneRequest:
    handler = handleDistGCDoneRequest;
    break;
  case DistGCDoneReply:
    handler = handleDistGCDoneReply;
    break;
  case DistGCDoneReport:
    handler = handleDistGCDoneReport;
    break;
#endif
  default:
    TRACE(rinvoke, 0, ("dstsrv: unknown packet type: %d", header.kind));
    DestroyStream(str);
    return;
  }
  handler(&header, srv, str);
  DestroyStream(str);
}

static int ping(Node srv)
{
  int res;
  extern int findsocket(Node *t, int create);
  doEchoRequest(thisnode, srv);
  while (!readyForBusiness && findsocket(&srv, 0) > 0)
    processMessages();
  res = findsocket(&srv, 0) > 0 ? 0 : -1;
  TRACE(rinvoke, 3, ("Ping %s", res < 0 ? "failed" : "succeeded"));
  return res;
}

void moveDone(State *state, RemoteOpHeader *request, int fail)
{
  if (!RESDNT(state->firstThing)) {
    RemoteOpHeader h;
    TRACE(rinvoke, 4, ("Forwarding waking ss %s on %s", 
		       OIDString(OIDOf((Object)state)),
		       NodeString(getLocFromObj((Object)state))));
    h.kind = MoveReply;
    h.ss = OIDOf((Object)state);
    h.sslocation = getLocFromObj((Object)state);
    h.target = request->target;
    h.targetct = request->targetct;
    h.status = fail;
    sendMsgTo(getLocFromObj((Object)state), StartMsg(&h), h.ss);
  } else {
    state->nstoid = nooid;
    assert(ISetMember(allProcesses, (int)state));
    makeReady(state);
  }
}

void isFixedDone(RemoteOpHeader *h, State *state, int answer)
{
  if (!RESDNT(state->firstThing)) {
    RemoteOpHeader replyh;
    Stream reply;
    TRACE(rinvoke, 4, ("Forwarding waking ss %s on %s", 
		       OIDString(OIDOf((Object)state)),
		       NodeString(getLocFromObj((Object)state))));
    replyh.kind = IsFixedReply;
    replyh.option1 = h->option1;
    replyh.ss = OIDOf((Object)state);
    replyh.sslocation = getLocFromObj((Object)state);
    replyh.target = nooid;
    replyh.targetct = nooid;
    reply = StartMsg(&replyh);
    WriteInt(answer, reply);
    sendMsgTo(getLocFromObj((Object)state), reply, replyh.ss);
  } else {
    assert(ISetMember(allProcesses, (int)state));
    if (RESDNT(state->op->flags)) {
      if (!ISNIL(answer)) {
#define sp state->sp
	PUSH(int, answer);
	PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
      }
      makeReady(state);
#undef sp
    } else {
      returnToForeignObject(state, answer);
    }
  }
}

void handleGaggleUpdate(RemoteOpHeader *h, Node sender, Stream str)
{
  OID moid, ooid, ctoid;
  Node location;
  u32 opcode;
  ConcreteType ct;

  TRACE(rinvoke, 7, ("GaggleUpdate received"));
  if (h != NULL) {
    ReadInt(&opcode, str);
    assert(opcode == 1 || opcode == 2);
  } else {
    opcode = 1;
  }
  ReadOID(&moid, str);
  ReadOID(&ooid, str);
  ReadOID(&ctoid, str);
  ReadNode(&location, str);
  if (opcode == 1) {
    ct = (ConcreteType)doObjectRequest(sender, &ctoid, ctct);
    if (ISNIL(OIDFetch(ooid))) {
      noderecord *nd = getNodeRecordFromSrv(location);
      if (!nd) nd = getNodeRecordFromSrv(sender);
      (void)createStub(ct, nd, ooid);
    }
    add_gmember(moid, ooid);
  } else if (opcode == 2) {
    delete_gmember(moid, ooid);
  } else {
    assert(0);
  }
}

#endif
