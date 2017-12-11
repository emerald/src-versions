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
 * IOScs (searchable collections) are things that map 
 * integers to oids.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

#ifndef _EMERALD_IOSC_H
#define _EMERALD_IOSC_H

#include "storage.h"
#include "types.h"

/*
 * Before using this, one must define the following:
 *	IOScDomainType	- a typedef for the domain (int)
 *	IOScRangeType	- a typedef for the range (OID)
 *	IOScHASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	IOScCOMPARE	- a macro that compares two elements of 
 *				  the domain, evaluating to 1 if they are 
 *				  the same
 */
#define IOScDomainType int
#define IOScRangeType  OID
#define IOScHASH(X) ((unsigned)(((X) >> 2) ^ ((X) << 7)))
#define IOScCOMPARE(X,Y) ((X)==(Y))
extern OID nooid;
#define IOScNIL nooid
#define IOScIsNIL(x) (isNoOID(x))
#define IOScKNIL (-1)
#define IOScKIsNIL(x) ((x) == IOScKNIL)

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is IOSc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct IOScTE {
    IOScDomainType	 key;		/* the key for this entry */
    IOScRangeType	 value;		/* what we want */
} IOScTE, *IOScTEPtr;

typedef struct IOScRecord {
    IOScTEPtr table;
    int size, maxCount, count;
} IOScRecord, *IOSc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
IOSc IOScCreate(void);
IOSc IOScCreateN(int);

/* Destroy a collection */
void IOScDestroy(IOSc sc);

/* Insert the pair <key, value> into collection IOSc */
void IOScInsert(IOSc sc, IOScDomainType key, IOScRangeType value);

/* Delete the pair with key key from the collection IOSc */
void IOScDelete(IOSc sc, IOScDomainType key);

/* Select a random (the first) key from the set sc */
IOScDomainType IOScSelect(IOSc sc, IOScRangeType *rangeptr);

/* Return the value associated with key in collection 
 * IOSc, or IOScNIL if no such key exists */
IOScRangeType IOScLookup(IOSc sc, IOScDomainType key);

/* DEBUGGING: Print the collection IOSc */
void IOScPrint(IOSc sc);

/* Iterate over the elements of the collection IOSc.  
 * At each iteration, IOSckey and IOScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	IOScForEach(someSc, key, value) {
 *	  / * whatever you want to do with key, value * /
 *	} IOScNext();
 */
#define IOScForEach(IOSc, IOSckey, IOScvalue) \
  { \
    int IOScxx_index; \
    for (IOScxx_index = 0; IOScxx_index < (IOSc)->size; IOScxx_index++) { \
      if (!IOScKIsNIL((IOSc)->table[IOScxx_index].key)) { \
	*(IOScDomainType*)(&(IOSckey)) = (IOSc)->table[IOScxx_index].key; \
	*(IOScRangeType *)(&(IOScvalue)) = (IOSc)->table[IOScxx_index].value; \
	{ 

#define IOScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in IOSc */
#define IOScSize(IOSc) ((IOSc)->count)
#endif /* _EMERALD_IOSC_H */
