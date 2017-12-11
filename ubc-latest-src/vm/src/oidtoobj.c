/****************************************************************************
 File     : oidtoobject.c 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Routines to obtain objects from OIDs and vice versa

 Modifications
 -------------

*****************************************************************************/

#include "system.h"

#include "vm_exp.h"
#include "iset.h"
#include "oidtoobj.h"
#include "ooisc.h"
#include "globals.h"
#include "trace.h"
#include "read.h"
#include "assert.h"

/*
 * The initial size of the object table.  If it is too small, it gets
 * increased, but due to malloc's behaviour it costs a lot of data space.
 */
#define OBJECTTABLESIZE (24 * 1024)

OTable ObjectTable;

static Bits16        NextOIDepoch = 0;
static Bits32        NextOIDSeq = 1;
OID nooid = { 0, 0, 0, 0 };
static void resolveRelocations(OID, Object);
OID MyBaseOID;


/*
 * Initialize the ObjectTable
 */

void OIDToObjectInit() {
  ObjectTable = OTableCreateN(OBJECTTABLESIZE);
}

/*
 * Add entries to the ObjectTable
 */

void UpdateOIDTables(OID oid, Object o) {
  if (!wasGCMalloced(o)) {
    TRACE(oid, 8, ("Inserting non gcmalloced object %#x with oid %s", o, OIDString(oid)));
  }
  TRACE(oid, 3, ("Inserting %#x with OID %s", o, OIDString(oid)));
  SETHASOID(o->flags);
  OTableInsert(ObjectTable, oid, o);
  resolveRelocations(oid, o);
}

void OIDRemove(OID oid, Object o)
{
#ifndef NDEBUG
  Object old = OIDFetch(oid);
  if (old != o) {
    ftrace("OIDRemove botch:  %#x != %#x", (u32)old , (u32)o);
  }
#endif
  TRACE(oid, 3, ("Removing id from %#x %s", o, OIDString(oid)));

  CLEARHASOID(o->flags);
  OTableDeleteByObject(ObjectTable, o);
}

void OIDRemoveAny(Object o)
{
  OID hisoid = OTableLookupByObject(ObjectTable, o);
  if (!isNoOID(hisoid)) {
    CLEARHASOID(o->flags);
    OTableDeleteByObject(ObjectTable, o);
    TRACE(oid, 2, ("Removing oid %s from %#x", OIDString(hisoid), o));
  }
}

void OIDInsert(OID oid, Object o)
{
  Object old;
 
  old = OIDFetch(oid);
  if (!ISNIL(old)) {
    if (old != o) {
      TRACE(oid, 0, ("Defining an id that already exists %s -> %#x, a %.*s",
		     OIDString(oid), old,
		     CODEPTR(old->flags)->d.name->d.items,
		     CODEPTR(old->flags)->d.name->d.data));
    }
    OTableDeleteByObject(ObjectTable, old);
  }
  UpdateOIDTables(oid, o);
}

void UpdateObjectLocation(Object oldo, Object newo)
{
  OID oid;

  assert(HASOID(newo->flags));
  oid = OIDOf(oldo);
  TRACE(oid, 2, ("Moving oid %s from %#x to %#x", OIDString(oid), oldo, newo));
  OTableUpdateValue(ObjectTable, oldo, newo);
}
    
/* 
 * Add an OID to the table, using only its sequence value.  This routine
 * provides compatibility for the old data structures, which used only the
 * sequence value as significant.
 */

void OIDInsertFromSeq(unsigned seq, Object o)
{
  OID oid;

  oid = nooid;
  oid.Seq = seq;
  OIDInsert(oid, o);
}

static void resolveRelocations(OID id, Object o)
{
  ISet relocations;
  Relocation *r;

  relocations = (ISet) OIScLookup(relocationMap, id);
  if (OIScIsNIL(relocations)) return;
  TRACE(relocation, 1, ("Found object %#x for which %d relocations exist",
			id.Seq, ISetSize(relocations)));
  ISetForEach(relocations, r) {
    TRACE(relocation, 2, ("Setting location %#x+%#x",
			  r->o, r->offset));
    *(Object *)((char *)r->o + r->offset) = o;
    stoCheck(r->o, o);
    vmFree((char *) r);
  } ISetNext();
  ISetDestroy(relocations);
  OIScDelete(relocationMap, id);
}

/*
 * Generate a new oid
 */
void NewOID(OID *theOID)
{
  theOID->ipaddress = MyBaseOID.ipaddress;
  theOID->port = MyBaseOID.port;
  theOID->epoch = MyBaseOID.epoch;
  theOID->Seq = NextOIDSeq++;
  if (!theOID->Seq) {
    NextOIDepoch++;
    assert(0);
    theOID->epoch = NextOIDepoch;
  }
}

/*
 * Compare two OID's for equality
 */
int EqOID(OID oid1, OID oid2)
{
  return ((oid1.ipaddress == oid2.ipaddress) &&
         (oid1.port == oid2.port) &&
	 (oid1.epoch == oid2.epoch) && (oid1.Seq == oid2.Seq));
}

Bits32 OIDSeqOf(Object o)
{
  OID oid = OIDOf(o);
  if (!isNoOID(oid)) return oid.Seq;
  else return JNIL;
}

int findOpByName(ConcreteType ct, char *name)
{
  int i, nops, len = strlen(name);
  nops = ct->d.opVector->d.items;
  for (i = 3; i < nops; i++) {
    OpVectorElement e = ct->d.opVector->d.data[i];
    if (e->d.name->d.items == len && !memcmp(e->d.name->d.data, name, len))
      return i;
  }
  return -999999;
}

#ifdef USEABCONS
OOISc abConMap = NULL;

OpVectorElement findOp(ConcreteType ct, unsigned id)
{
  int i, nops;
  nops = ct->d.opVector->d.items;
  for (i = 3; i < nops; i++) {
    OpVectorElement e = ct->d.opVector->d.data[i];
    if (e->d.id == id)
      return e;
  }
  return (OpVectorElement)JNIL;
}

AbCon findAbCon(OID abOID, OID conOID)
{
  AbCon abcon;
  ConcreteType con;
  AbstractType ab;
  int i, nops;

  if (abConMap == NULL) abConMap = OOIScCreate();
  abcon = (AbCon)OOIScLookup(abConMap, abOID, conOID);
  if (OOIScIsNIL(abcon)) {
    ab = (AbstractType) OIDFetch( abOID);
    con= (ConcreteType) OIDFetch(conOID);
    nops = ab->d.ops->d.items;
    abcon = (AbCon) vmMalloc(sizeofAbCon + nops * sizeof(OpVectorElement));
    abcon->d.abOID = abOID;
    abcon->d.conOID = conOID;
    abcon->d.ab = ab;
    abcon->d.con = con;
    abcon->d.nops = nops;
    for (i = 0; i < nops; i++) {
      abcon->d.ops[i] = findOp(con, ab->d.ops->d.data[i]->d.id);
    }
    OOIScInsert(abConMap, abOID, conOID, (int)abcon);
  }
  return abcon;
}

AbCon findConCon(ConcreteType con)
{
  AbCon abcon;
  int i, nops;

  if (abConMap == NULL) abConMap = OOIScCreate();
  abcon = (AbCon)OOIScLookup(abConMap, OIDOf(con), OIDOf(con));
  if (OOIScIsNIL(abcon)) {
    nops = con->d.opVector->d.items;
    abcon = (AbCon) vmMalloc(sizeofAbCon + nops * sizeof(OpVectorElement));
    abcon->d.abOID = OIDOf(con);
    abcon->d.conOID = OIDOf(con);
    abcon->d.ab = (AbstractType) con;		/* TODO: this is broken */
    abcon->d.con = con;
    abcon->d.nops = nops;
    for (i = 0; i < nops; i++) {
      abcon->d.ops[i] = con->d.opVector->d.data[i];
    }
    OOIScInsert(abConMap, OIDOf(con), OIDOf(con), (int)abcon);
  }
  return abcon;
}

void verifyAbCon(AbCon *abcon, AbstractType ab)
{
  OID abOID = OIDOf(ab);
  if (!sameOID(abOID, (*abcon)->d.abOID)) {
    *abcon = findAbCon(abOID, (*abcon)->d.conOID);
  }
}
#endif

char *OIDString( OID o )
{
  static char buf[5][60];
  static int i = 0;
  char *rval;

  rval = buf[i]; i = (i+1) % 5;
  sprintf( rval, "%08x.%04x.%04x.%08x", o.ipaddress, o.port,
                                        o.epoch, o.Seq );
  return rval;
}

OID FOIDOf(Object o)
{
  OID r = OIDOf(o);
  if (isNoOID(r)) {
    NewOID(&r);
    OIDInsert(r, o);
  }
  return r;
}
