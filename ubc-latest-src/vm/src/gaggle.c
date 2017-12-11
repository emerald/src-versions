#include "system.h"

#include "gaggle.h"
#include "trace.h"

int tracegaggle;
#ifdef DISTRIBUTED
OISc gaggleTable;

static inline int ltOID(OID a, OID b)
{
  if (a.ipaddress < b.ipaddress) return 1;
  if (a.ipaddress > b.ipaddress) return 0;
  if (a.port < b.port) return 1;
  if (a.port > b.port) return 0;
  if (a.epoch < b.epoch) return 1;
  if (a.epoch > b.epoch) return 0;
  if (a.Seq < b.Seq) return 1;
  return 0;
}
		      
void createGaggle(OID g)
{
  gtypeptr value=0;
  TRACE(gaggle, 3, ("Creating gaggle %s", OIDString(g)));
  if (OIScIsNIL(OIScLookup(gaggleTable, g))) {
    OIScInsert(gaggleTable, g, (int)value);
  } else {
    TRACE(gaggle, 3, ("Gaggle %s already existed", OIDString(g)));
  }
}

void initGaggle()
{
  TRACE(gaggle, 3, ("Init gaggle"));
  gaggleTable = OIScCreate(); 
}

void add_gmember(OID gid, OID newMember)
{
  int notExists=1;
  gtypeptr previous, first;
  gtypeptr value = (gtypeptr)OIScLookup(gaggleTable, gid);
  if (OIScIsNIL(value)) value = 0;
  previous = NULL;
  first = value;
  while (value){
    if (sameOID(value->gmember, newMember)) {
      TRACE(gaggle, 1, ("Gaggle member:: %s already exists\n", OIDString(newMember)));
      notExists=0;
      break;
    } else if (ltOID(value->gmember, newMember)) {
      previous = value;
    }
    value=value->next;
  }
  if (notExists){
    gtypeptr temp=(struct gtype *)vmMalloc(sizeof(struct gtype));
    temp->gmember=newMember;
    if (previous == NULL) {
      temp->next = first;
      OIScInsert(gaggleTable, gid, (int)temp);  
    } else {
      temp->next = previous->next;
      previous->next = temp;
    }
    TRACE(gaggle, 3, ("Added member %s to Gaggle %s\n", OIDString(newMember), OIDString(gid)));
  }
}
    

OID get_gmember(OID gid)
{
  Object obj;
  gtypeptr first = (gtypeptr)OIScLookup(gaggleTable, gid), value;
  TRACE(gaggle, 3, ("Looking for gaggle member in %s", OIDString(gid)));
  if (OIScIsNIL(first)) first = 0;
  value = first;
  while (value) {
    obj = OIDFetch(value->gmember);
    assert(!ISNIL(obj));
    TRACE(gaggle, 5, ("Member %s is %s", OIDString(value->gmember), RESDNT(obj->flags) ? "resident" : "not resident"));
    if (RESDNT(obj->flags)) {
      return value->gmember;
    }
    value = value->next;
  }
  return first ? first->gmember : nooid;
}

OID get_gelement(OID gid, int index)
{
  int i=0;
  Object member;
  gtypeptr value=(gtypeptr)OIScLookup(gaggleTable, gid);
  TRACE(gaggle, 3, ("Looking for %dth gaggle member in %s", index, OIDString(gid)));
  if (OIScIsNIL(value)) value = 0;

  if (index < get_gsize(gid)){
    while (i < index){
      value=value->next;
      i++;
    }
    member = OIDFetch(value->gmember);
    TRACE(gaggle, 4, ("Returning %s %x (%s)", OIDString(value->gmember), member, RESDNT(member->flags) ? "resident" : "not resident"));
    return value->gmember;
  }
  else{
    TRACE(gaggle, 2, ("No %dth member exists", index));
    return nooid;
  }
}

int get_gsize(OID gid)
{
  int count=0;
  gtypeptr value=(gtypeptr)OIScLookup(gaggleTable, gid);
  TRACE(gaggle, 3, ("Getting size of gaggle %s", OIDString(gid)));

  if (OIScIsNIL(value)) value = 0;

  while (value != 0) {
    count++;
    value=value->next;
  }
  TRACE(gaggle, 4, ("Gaggle %s has size %d", OIDString(gid), count));

  return count;
}


void sendGmUpdate(Node srv, Stream msg, OID moid, OID ooid, OID ctoid,
		  int dead)
{
  
  Node hislocation;
  Object o;

  TRACE(gaggle, 3,
	  ("sendGaggleUpdate: sending %s %s to gaggle %s to node %s",
	   dead ? "delete" : "add",
	   OIDString(ooid), OIDString(moid), NodeString(srv)));
  WriteInt(dead ? 2 : 1, msg);
  WriteOID(&moid, msg);
  WriteOID(&ooid, msg);
  WriteOID(&ctoid, msg);
  o = OIDFetch(ooid);
  hislocation = getLocFromObj(o);
  WriteNode(&hislocation, msg);
}

void sendGaggleUpdate(OID moid, OID ooid, OID ctoid, int dead)
{
  noderecord *n;
  for (n = allnodes; n; n = n->p) {
    /* we send to the other nodes (not ourself) if they are up */
    if ((n != thisnode)&&(n->up)) {
      RemoteOpHeader msgh;
      Stream msg;

      msgh.kind = GaggleUpdate;
      msgh.ss = nooid;
      msgh.sslocation = myid;
      msgh.target = nooid;
      msgh.targetct = nooid;
  
      msg = StartMsg(&msgh);
      sendGmUpdate(n->srv, msg, moid, ooid, ctoid, dead);
      sendMsg(n->srv, msg);
    }
  }
}

void sendGaggleNews(Node srv, Stream reply)
{
  int index;
  OID moid;
  
  OIScForEach(gaggleTable, moid, index){
     int    size  = get_gsize(moid);
     int    i;

     for (i = 0 ; i < size; i++){  
       OID          ooid    = get_gelement(moid, i);
       Object       gmember = OIDFetch(ooid);
       ConcreteType ct      = CODEPTR(gmember->flags);
       OID          ctoid   = OIDOf(ct);
       sendGmUpdate(srv, reply, moid, ooid, ctoid, 0);
     }
  } OIScNext();
}

void removeFromAllGaggles(Object o)
{
  OID goid, toid;
  gtypeptr value, tonuke;

  toid = OIDOf(o);
  if (isNoOID(toid)) return;

  TRACE(gaggle, 4, ("Removing %s %x (a %.*s) from gaggles", OIDString(toid), o,
		    CODEPTR(o->flags)->d.name->d.items,
		    CODEPTR(o->flags)->d.name->d.data));

  OIScForEach(gaggleTable, goid, value) {
    tonuke = 0;
    if (!value) continue;
    if (sameOID(value->gmember, toid)) {
      tonuke = value;
      OIScInsert(gaggleTable, goid, (int)value->next);
    } else {
      while (value->next) {
	if (sameOID(value->next->gmember, toid)) {
	  tonuke = value->next;
	  value->next = value->next->next;
	  break;
	}
	value = value->next;
      }
    }
    if (tonuke) {
      TRACE(gaggle, 5, ("Found it in gaggle %s", OIDString(goid)));
      vmFree(tonuke);
      sendGaggleUpdate(goid, toid, OIDOf(CODEPTR(o->flags)), 1);
    }
  } OIScNext();
}

void delete_gmember(OID goid, OID deadMember)
{
  gtypeptr value, tonuke;

  TRACE(gaggle, 4, ("Removing %s from gaggle %s", OIDString(deadMember),
		    OIDString(goid)));

  value = (gtypeptr) OIScLookup(gaggleTable, goid);
  tonuke = 0;
  if (!value) {
    TRACE(gaggle, 0, ("Removing %s from unknown gaggle %s", OIDString(deadMember),
		      OIDString(goid)));
    return;
  }

  if (sameOID(value->gmember, deadMember)) {
    tonuke = value;
    OIScInsert(gaggleTable, goid, (int)value->next);
  } else {
    while (value->next) {
      if (sameOID(value->next->gmember, deadMember)) {
	tonuke = value->next;
	value->next = value->next->next;
	break;
      }
      value = value->next;
    }
  }
  if (tonuke) {
    TRACE(gaggle, 5, ("Found it in gaggle %s", OIDString(goid)));
    vmFree(tonuke);
    sendGaggleUpdate(goid, deadMember, nooid, 1);
  }
}
#endif
