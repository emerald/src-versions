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
 * OIScs (searchable collections) are things that map 
 * pairs of oids onto ints.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

#ifndef __EMERALD_OISC_H
#define __EMERALD_OISC_H

#include "storage.h"
#include "types.h"

typedef OID OIScDomainType;
#define OIScRangeType  int
#define OIScHASH(X) ((unsigned) (((X).ipaddress) ^ (((X).Seq) << 0)))
#define OIScCOMPARE(K,X) (sameOID((K), (X)))
#define OIScNIL (JNIL)
#define OIScIsNIL(X) ((int)(X) == OIScNIL)
#define OIScTSize(sc) ((sc)->size + (sc)->ofsize)
/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is OISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct OIScTE {
    OIScDomainType	 key;		/* the key for this entry */
    OIScRangeType	 value;		/* what we want */
    int			 chain;		/* overflow chain */
} OIScTE, *OIScTEPtr;

typedef struct OIScRecord {
    OIScTEPtr table;
    int size, maxCount, count, ofsize, ofcount, of;
} OIScRecord, *OISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
OISc OIScCreate(void);
OISc OIScCreateN(int);
OISc OIScClone(OISc original);

/* Destroy a collection */
void OIScDestroy(OISc sc);

/* Insert the pair <key, value> into collection OISc */
void OIScInsert(OISc sc, OID a, OIScRangeType value);

/* Delete the pair with key key from the collection OISc */
void OIScDelete(OISc sc, OID a);

/* Return the value associated with key in collection 
 * OISc, or OIScNIL if no such pair exists */
int OIScLookup(OISc sc, OID a);

/* DEBUGGING: Print the collection OISc */
void OIScPrint(OISc sc);
void OIScPrintF(OISc sc);

/* Iterate over the elements of the collection OISc.  
 * At each iteration, OISckey and OIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	OIScForEach(sc, key_a, value) {
 *	  / * whatever you want to do with key_a, key_b, value * /
 *	} OIScNext();
 */
#define OIScForEach(OISc, OISckey, OIScvalue) \
  { \
    int OIScxx_index; \
    for (OIScxx_index = 0; OIScxx_index < OIScTSize(OISc); OIScxx_index++) { \
      if (!OIScIsNIL((OISc)->table[OIScxx_index].value)) { \
	*(OID*)(&(OISckey)) = (OISc)->table[OIScxx_index].key; \
	*(OIScRangeType *)(&(OIScvalue)) = (OISc)->table[OIScxx_index].value; \
	{

#define OIScNext() \
	} \
      } \
    } \
  }

/* Iterate over the elements of the collection OISc backwards.  
 * At each iteration, OISckey and OIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	OIScForEachBackwards(sc, key_a, value) {
 *	  / * whatever you want to do with key_a, key_b, value * /
 *	} OIScNext();
 */
#define OIScForEachBackwards(OISc, OISckey, OIScvalue) \
  { \
    int OIScxx_index; \
    for (OIScxx_index = OIScTSize(OISc) - 1; OIScxx_index >= 0; OIScxx_index--) { \
      if (!OIScIsNIL((OISc)->table[OIScxx_index].value)) { \
	*(OID*)(&(OISckey)) = (OISc)->table[OIScxx_index].key; \
	*(OIScRangeType *)(&(OIScvalue)) = (OISc)->table[OIScxx_index].value; \
	{ 

#define OIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in OISc */
#define OIScSize(OISc) ((OISc)->count)

#endif /* _EMERALD_OISC_H */
