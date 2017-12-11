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
 * OOIScs (searchable collections) are things that map 
 * pairs of oids onto ints.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

#ifndef _EMERALD_OOISC_H
#define _EMERALD_OOISC_H

#include "storage.h"
#include "types.h"

typedef struct {
  OID a, b;
} OOIScDomainType;
#define OOIScRangeType  int
#define OOIScHASH(X,Y) ((unsigned) ((X.ipaddress) ^ ((X.Seq) << 0) ^ \
			 ((Y.ipaddress) << 3) ^ ((Y.Seq) << 1)))
#define OOIScCOMPARE(K,X,Y) (sameOID((K).a, (X)) && sameOID((K).b, (Y)))
#define OOIScNIL (-1)
#define OOIScIsNIL(X) ((int)(X) == OOIScNIL)

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is OOISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct OOIScTE {
    OOIScDomainType	 key;		/* the key for this entry */
    OOIScRangeType	 value;		/* what we want */
} OOIScTE, *OOIScTEPtr;

typedef struct OOIScRecord {
    OOIScTEPtr table;
    int size, maxCount, count;
} OOIScRecord, *OOISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
OOISc OOIScCreate(void);

/* Destroy a collection */
void OOIScDestroy(OOISc sc);

/* Insert the pair <key, value> into collection OOISc */
void OOIScInsert(OOISc sc, OID a, OID b, OOIScRangeType value);

/* bump the value associated with the given key in the OOISc */
int OOIScBump(OOISc sc, OID a, OID b);

/* bump the value associated with some given key in the OOISc by value */
int OOIScBumpBy(OOISc sc, OID a, OID b, int value);

/* Delete the pair with key key from the collection OOISc */
void OOIScDelete(OOISc sc, OID a, OID b);

/* Return the value associated with key in collection 
 * OOISc, or OOIScNIL if no such pair exists */
int OOIScLookup(OOISc sc, OID a, OID b);

/* DEBUGGING: Print the collection OOISc */
void OOIScPrint(OOISc sc);

/* Iterate over the elements of the collection OOISc.  
 * At each iteration, OOISckey and OOIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	OOIScForEach(sc, key_a, key_b, value) {
 *	  / * whatever you want to do with key_a, key_b, value * /
 *	} OOIScNext();
 */
#define OOIScForEach(OOISc, OOISckeya, OOISckeyb, OOIScvalue) \
  { \
    int OOIScxx_index; \
    for (OOIScxx_index = 0; OOIScxx_index < (OOISc)->size; OOIScxx_index++) { \
      if (!OOIScIsNIL((OOISc)->table[OOIScxx_index].value)) { \
	*(OID*)(&(OOISckeya)) = (OOISc)->table[OOIScxx_index].key.a; \
	*(OID*)(&(OOISckeyb)) = (OOISc)->table[OOIScxx_index].key.b; \
	*(OOIScRangeType *)(&(OOIScvalue)) = (OOISc)->table[OOIScxx_index].value; \
	{ 

#define OOIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in OOISc */
#define OOIScSize(OOISc) ((OOISc)->count)

#endif /* _EMERALD_OOISC_H */
