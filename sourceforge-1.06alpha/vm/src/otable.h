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

/*
 * OTables (searchable collections) are things that map between
 * oids and objects in both directions.  Operations:
 *	create, destroy, insert, lookupbyoid, lookupbyobject, size, and print
 */

#ifndef __EMERALD_OTABLE_H
#define __EMERALD_OTABLE_H

#include "storage.h"
#include "types.h"

#define OTableIsNIL(X) (ISNIL(X))

typedef unsigned short indexType;

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is OTable,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct OTableTE {
    OID			 key;		/* the key for this entry */
    Object		 value;		/* what we want */
    indexType	 ochain;	/* overflow chain */
    indexType	 oidchain;	/* overflow chain */
} OTableTE, *OTableTEPtr;

typedef struct OTableRecord {
    OTableTEPtr table;
    int size, count, free;
    indexType *olookup, *oidlookup;
} OTableRecord, *OTable;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
OTable OTableCreate(void);
OTable OTableCreateN(int);

/* Destroy a collection */
void OTableDestroy(OTable sc);

/* Insert the pair <key, value> into collection OTable */
void OTableInsert(OTable sc, OID a, Object value);

/* Delete the pair with key key from the collection OTable */
void OTableDeleteByOID(OTable sc, OID a);
void OTableDeleteByObject(OTable sc, Object o);

/* Return the value associated with key in the collection,
 * or OTableNIL if no such pair exists */
Object OTableLookupByOID(OTable sc, OID a);
OID OTableLookupByObject(OTable sc, Object o);

/* DEBUGGING: Print the collection OTable */
void OTablePrint(OTable sc);

/* Iterate over the elements of the collection OTable.  
 * At each iteration, OTablekey and OTablevalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	OTableForEach(sc, key_a, value) {
 *	  / * whatever you want to do with key_a, key_b, value * /
 *	} OTableNext();
 */
#define OTableForEach(OTable, OTablekey, OTablevalue) \
  { \
    int OTablexx_index; \
    for (OTablexx_index = 0; OTablexx_index < OTable->size; OTablexx_index++) { \
      if (!OTableIsNIL((OTable)->table[OTablexx_index].value)) { \
	*(OID*)(&(OTablekey)) = (OTable)->table[OTablexx_index].key; \
	*(Object *)(&(OTablevalue)) = (OTable)->table[OTablexx_index].value; \
	{

#define OTableNext() \
	} \
      } \
    } \
  }

/* Iterate over the elements of the collection OTable backwards.  
 * At each iteration, OTablekey and OTablevalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	OTableForEachBackwards(sc, key_a, value) {
 *	  / * whatever you want to do with key_a, key_b, value * /
 *	} OTableNext();
 */
#define OTableForEachBackwards(OTable, OTablekey, OTablevalue) \
  { \
    int OTablexx_index; \
    for (OTablexx_index = OTable->size - 1; OTablexx_index >= 0; OTablexx_index--) { \
      if (!OTableIsNIL((OTable)->table[OTablexx_index].value)) { \
	*(OID*)(&(OTablekey)) = (OTable)->table[OTablexx_index].key; \
	*(Object *)(&(OTablevalue)) = (OTable)->table[OTablexx_index].value; \
	{ 

#define OTableNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in OTable */
#define OTableSize(OTable) ((OTable)->count)

extern void OTableUpdateValue(OTable, Object, Object);
#endif /* _EMERALD_OTABLE_H */
