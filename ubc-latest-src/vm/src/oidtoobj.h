/****************************************************************************
 File     : oidtoobject.h 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Routines to obtain objects from OIDs and vice versa

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_OIDTOOBJECT_H
#define _EMERALD_OIDTOOBJECT_H

#include "types.h"
#include "otable.h"

extern OTable ObjectTable;

extern void OIDToObjectInit(void);
#define OIDFetch(o) (OTableLookupByOID(ObjectTable, (o)))
extern void OIDRemove(OID oid, Object o);
extern void OIDRemoveAny(Object o);
extern void OIDInsert(OID oid, Object o);
extern void OIDInsertFromSeq(unsigned seq, Object o);
extern void UpdateOIDTables(OID oid, Object o);

extern void	NewOID(OID *theOID);
extern Bits32	OIDSeqOf(Object o);
extern int	EqOID(OID oid1, OID oid2);
#define OIDOf(o) (OTableLookupByObject(ObjectTable, (Object)(o)))
extern OID FOIDOf(Object o);
extern OID nooid;
extern AbCon findAbCon(OID, OID), findConCon(ConcreteType);
int findOpByName(ConcreteType ct, char *name);
extern void UpdateObjectLocation(Object oldo, Object newo);

char *OIDString( OID );
#endif /* _EMERALD_OIDTOOBJECT_H */
