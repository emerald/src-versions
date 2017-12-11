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
 * ISets are set of some domain.  Operations:
 *	create, destroy, insert, member, size, and print
 */

#ifndef _EMERALD_ISET_H
#define _EMERALD_ISET_H
/*
 * Before using this, one must define the following:
 *	ISetDomainType	- a typedef for the domain
 *	ISetHASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	ISetCOMPARE	- a macro that compares two elements of 
 *				  the domain, evaluating to 1 if they are 
 *				  the same
 */
#define ISetDomainType int
#define ISetHASH(X) ((unsigned)(((X) >> 2) ^ ((X) << 7)))
#define ISetCOMPARE(X,Y) ((X)==(Y))

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is ISet,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct ISetTE {
    ISetDomainType	 key;		/* the key for this entry */
} ISetTE, *ISetTEPtr;

typedef struct ISetRecord {
    ISetTEPtr table;
    int size, maxCount, count;
} ISetRecord, *ISet;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
ISet ISetCreate(void);
ISet ISetCreateN(int n);

/* Destroy a collection */
void ISetDestroy(ISet sc);

/* Insert the key into the set ISet */
void ISetInsert(ISet sc, ISetDomainType key);

/* Delete the key key from the set ISet */
void ISetDelete(ISet sc, ISetDomainType key);

/* Delete the key key from the set ISet */
void ISetDeleteAll(ISet sc);

/* Select a random (the first) key from the set sc */
ISetDomainType ISetSelect(ISet sc);

/* Return if key is in the set */
int ISetMember(ISet sc, ISetDomainType key);

/* DEBUGGING: Print the collection ISet */
void ISetPrint(ISet sc);

/* Iterate over the elements of the collection ISet.  
 * At each iteration, ISetkey is set to the next key in the set.  
 * Usage:
 *	ISetForEach(someSc, key) {
 *	  / * whatever you want to do with key * /
 *	} ISetNext();
 */
#define ISetForEach(ISet, ISetkey) \
  { \
    int ISetxx_index; \
    for (ISetxx_index = 0; ISetxx_index < (ISet)->size; ISetxx_index++) { \
      if ((ISet)->table[ISetxx_index].key != 0) { \
	*(ISetDomainType*)(&(ISetkey)) = (ISet)->table[ISetxx_index].key; \
	{ 

#define ISetNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in ISet */
#define ISetSize(ISet) ((ISet)->count)

#include "storage.h"

#endif
