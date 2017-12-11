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
extern void UpdateObjectLocation(Object oldo, Object newo);

char *OIDString( OID );
#endif /* _EMERALD_OIDTOOBJECT_H */
