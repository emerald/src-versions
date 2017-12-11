/* comment me!
 */

#ifndef _EMERALD_RINVOKE_H
#define _EMERALD_RINVOKE_H

#ifndef _EMERALD_TYPE_H
#include "types.h"
#endif

#ifndef _EMERALD_DIST_H
#include "dist.h"
#endif

#ifndef _EMERALD_STREAMS_H
#include "streams.h"
#endif

#ifndef _EMERALD_VM_I_H
#include "vm_exp.h"
#endif

extern int receivingObjects;
extern char *gRootNode;

void init_nodeinfo(void);

typedef struct noderecord noderecord;
struct noderecord {
  int up;
  OID node, inctm;
  Node srv;
  noderecord *p;
};

#ifdef DISTRIBUTED
Object doObjectRequest( Node srv, OID *oid, ConcreteType ct );
int doMoveRequest( OID *oid, ConcreteType CT, OID *doid );

typedef struct {
  Node srv;
  Stream str;
} msgrec;

noderecord *getNodeRecordFromSrv(Node srv);
void updateLocation(Object obj, Node srv);
Object getNodeFromObj(Object obj);
Object getNodeFromSrv(Node srv);
Object whereIs(Object obj, ConcreteType ct);
void findLocation(Object obj, ConcreteType ct, struct State *, struct Stream *);
#endif
extern noderecord *getNodeRecordFromObj(Object obj);
Node getMyLoc(void);
Node getLocFromObj(Object obj);

int rinvoke(struct State *state, Object obj, int fn);
void ReadInt(u32 *n, Stream theStream);
void WriteInt( u32 n, Stream str);
Vector getnodes(int onlyactive);
extern void invokeHandleDown(struct noderecord *);
void performReturn(struct State *state);
#endif
