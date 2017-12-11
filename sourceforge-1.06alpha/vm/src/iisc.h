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
 * IIScs (searchable collections) are things that map 
 * elements of some domain onto some range.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

#ifndef _EMERALD_IISC_H
#define _EMERALD_IISC_H
/*
 * Before using this, one must define the following:
 *	IIScDomainType	- a typedef for the domain
 *	IIScRangeType	- a typedef for the range
 *	IIScHASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	IIScCOMPARE	- a macro that compares two elements of 
 *				  the domain, evaluating to 1 if they are 
 *				  the same
 */
#define IIScDomainType int
#define IIScRangeType  int
#define IIScHASH(X) ((unsigned)(((X) >> 2) ^ ((X) << 7)))
#define IIScCOMPARE(X,Y) ((X)==(Y))
#define IIScNIL (-1)
#define IIScIsNIL(x) (((int)x) == IIScNIL)

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is IISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct IIScTE {
    IIScDomainType	 key;		/* the key for this entry */
    IIScRangeType	 value;		/* what we want */
} IIScTE, *IIScTEPtr;

typedef struct IIScRecord {
    IIScTEPtr table;
    int size, maxCount, count;
} IIScRecord, *IISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
IISc IIScCreateN(int);
#define IIScCreate() IIScCreateN(1);

/* Destroy a collection */
void IIScDestroy(IISc);

/* Insert the pair <key, value> into collection IISc */
void IIScInsert(IISc sc, IIScDomainType key, IIScRangeType value);

/* bump the value associated with some given key in the IISc */
int IIScBump(IISc sc, IIScDomainType key);

/* bump the value associated with some given key in the IISc by value */
int IIScBumpBy(IISc sc, IIScDomainType key, int value);

/* Delete the pair with key key from the collection IISc */
void IIScDelete(IISc sc, IIScDomainType key);

/* Select a random (the first) key from the set sc */
IIScDomainType IIScSelect(IISc sc, int *rangeptr);

/* Return the value associated with key in collection 
 * IISc, or 0 if no such pair exists */
int IIScLookup(IISc sc, IIScDomainType key);

/* DEBUGGING: Print the collection IISc */
void IIScPrint(IISc sc);

/* Iterate over the elements of the collection IISc.  
 * At each iteration, IISckey and IIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	IIScForEach(someSc, key, value) {
 *	  / * whatever you want to do with key, value * /
 *	} IIScNext();
 */
#define IIScForEach(IISc, IISckey, IIScvalue) \
  { \
    int IIScxx_index; \
    for (IIScxx_index = 0; IIScxx_index < (IISc)->size; IIScxx_index++) { \
      if ((IISc)->table[IIScxx_index].key != IIScNIL) { \
	*(IIScDomainType*)(&(IISckey)) = (IISc)->table[IIScxx_index].key; \
	*(IIScRangeType *)(&(IIScvalue)) = (IISc)->table[IIScxx_index].value; \
	{ 

#define IIScForEachBackwards(IISc, IISckey, IIScvalue) \
  { \
    int IIScxx_index; \
    for (IIScxx_index = (IISc->size); IIScxx_index >= 0; IIScxx_index--) { \
      if ((IISc)->table[IIScxx_index].key != IIScNIL) { \
	*(IIScDomainType*)(&(IISckey)) = (IISc)->table[IIScxx_index].key; \
	*(IIScRangeType *)(&(IIScvalue)) = (IISc)->table[IIScxx_index].value; \
	{ 

#define IIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in IISc */
#define IIScSize(IISc) ((IISc)->count)

extern void IIScCheckOut(IISc);
#include "storage.h"
#endif
