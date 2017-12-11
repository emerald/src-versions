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

#ifndef _EMERALD_REMOTE_H
#define _EMERALD_REMOTE_H

#ifndef _EMERALD_RINVOKE_H
#include "rinvoke.h"
#endif

typedef struct RemoteOpHeader {
  unsigned int marker;
  unsigned char kind;
  unsigned char status;
  unsigned char option1;
  unsigned char option2;
  unsigned int distgcseq;
  OID ss;
  Node sslocation;
  OID target;
  OID targetct;
} RemoteOpHeader;

typedef enum {
  EchoRequest, EchoReply,
  InvokeRequest, InvokeReply,
  ObjectRequest, ObjectReply,
  LocateRequest, LocateReply,
  MoveRequest, MoveReply,
  Move3rdPartyRequest, Move3rdPartyReply,
  InvokeForwardRequest, InvokeForwardReply,
  IsFixedRequest, IsFixedReply,
  GaggleUpdate, DistGCInfo,
  DistGCDoneRequest, DistGCDoneReply,
  DistGCDoneReport
} MesageType;

#define EMERALDMARKER 0xdeafdeaf
extern void handleEchoRequest(RemoteOpHeader *, Node, Stream);
extern void handleObjectRequest(RemoteOpHeader *, Node, Stream);
extern void handleMoveRequest(RemoteOpHeader *, Node, Stream);
extern void handleMove3rdPartyRequest(RemoteOpHeader *, Node, Stream);
extern void handleLocateRequest(RemoteOpHeader *, Node, Stream);
extern void handleLocateReply(RemoteOpHeader *, Node, Stream);
extern void handleInvokeRequest(RemoteOpHeader *, Node, Stream);
extern void handleInvokeReply(RemoteOpHeader *, Node, Stream);
extern void handleInvokeForwardRequest(RemoteOpHeader *, Node, Stream);
extern void handleMoveReply(RemoteOpHeader *, Node, Stream);
extern void handleGaggleUpdate(RemoteOpHeader *, Node, Stream);
extern void handleIsFixedRequest(RemoteOpHeader *, Node, Stream);
extern void handleIsFixedReply(RemoteOpHeader *, Node, Stream);
extern void handleDistGCInfo(RemoteOpHeader *, Node, Stream);
extern void handleDistGCDoneRequest(RemoteOpHeader *, Node, Stream);
extern void handleDistGCDoneReply(RemoteOpHeader *, Node, Stream);
extern void handleDistGCDoneReport(RemoteOpHeader *, Node, Stream);
extern int extractHeader(RemoteOpHeader *h, Stream str);
extern void ReadNode(Node *srv, Stream theStream);
extern void InsertNode(Node *t, Bits8 *data);
extern void WriteNode(Node *srv, Stream theStream);
/*
 * We will report as unavailable any object that we can't get the message
 * to.  Sending either a request or a reply message gets into all kinds of
 * trouble, as we would have to come up with a duplicate detection scheme, a
 * scheme for deallocating reply messages when we see the next requests and
 * all sort of other stuff.  Instead we will send a message one time and
 * put the responsibility on the node at the end of the forwarding chain to
 * find the object and send it the message.
 *
 * We still have to figure out how to detect when some message has gotten
 * dropped on the floor.
 *
 * We should check out the status of every remote operation each time a node
 * dies.
 * 
 * For invocations, if the object in question isn't alive, our invocation
 * isn't coming back.  Otherwise we can't know whether the invocation that
 * we did is still in progress, the invocation message got lost, or the
 * reply got lost unless we come up with a way to name the invocation so we
 * can search for it.   We could do that if the sender of the invocation
 * decided what oid the state would get, it could then be located.  This
 * would chew up an oid for every remote invocation, but there are a lot of
 * oids around.
 *
 * For moves we can just locate the two objects in question and then retry
 * the move.
 */
extern int sendMsg(Node srv, Stream str);
extern void sendMsgTo(Node srv, Stream str, OID target);
extern void findAndSendTo(OID target, Stream str);
extern int forwardMsg(Node srv, RemoteOpHeader *h, Stream str);
extern Stream StartMsg(RemoteOpHeader *h);
extern void moveDone(State *state, RemoteOpHeader *request, int fail);
extern void locateDone(State *state);
extern int agressivelyLocate(Object o);
extern void checkForUnavailableInvokes(Object o);
extern void unavailableState(struct State *);
extern void isFixedDone(RemoteOpHeader *request, State *state, int answer);
extern void serveRequest(void);
extern void doRequest(Node srv, Stream str);
extern void processMessages(void);
extern noderecord *allnodes, *thisnode;
extern Object rootdir, rootdirg, node, inctm;
extern void ctcallback(Object);
extern void cticallback(int (*)(IISc, Object), IISc);
extern void sendUnavailableReply(Stream);
extern void *ctstr;
extern Node ctsrv;
extern Node myid, limbo;
extern int isLimbo(Node);
extern noderecord *limbonode;
#endif /* _EMERALD_REMOTE_H */
