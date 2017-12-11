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
 * JOVEIScs (searchable collections) are things that map 
 * jekyll op vector elements onto integers.
 *	Operations create, destroy, insert, lookup, size, and print
 */

#ifndef _EMERALD_JOVEISC_H
#define _EMERALD_JOVEISC_H
/*
 * Before using this, one must define the following:
 *	JOVEISCDomainType	- a typedef for the domain
 *	JOVEISCRangeType	- a typedef for the range
 *	HASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	COMPARE		- a macro that compares two elements of the domain,
 *			  evaluating to 1 if they are the same
 */
#include "types.h"
#include "array.h"
#include "storage.h"

typedef OpVectorElement JOVEISCDomainType;
typedef int   JOVEISCRangeType;

#define JOVEHASH(key, obA) oveintHash((OpVectorElement)key, obA)

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is JOVEISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct JOVEIScTE {
    JOVEISCDomainType	 key;		/* the key for this entry */
    JOVEISCRangeType	 value;		/* what we want */
} JOVEIScTE, *JOVEIScTEPtr;

typedef struct JOVEIScRecord {
    JOVEIScTEPtr table;
    int size, maxCount, count;
} JOVEIScRecord, *JOVEISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
extern JOVEISc JOVEIScCreate(void);

/* Destroy a collection */
extern void JOVEIScDestroy(register JOVEISc sc);

/* Insert the pair <key, value> into collection JOVEISc */
void JOVEIScInsert(register JOVEISc sc, register JOVEISCDomainType key,
		   JOVEISCRangeType value, array obA);

/* Delete the pair with key key from the collection JOVEISc */
extern void JOVEIScDelete(register JOVEISc sc, register JOVEISCDomainType key,
		   array obA);

/* Return the value associated with key in collection 
 * JOVEISc, or 0 if no such pair exists */
extern JOVEISCRangeType JOVEIScLookup(register JOVEISc sc, 
				      register JOVEISCDomainType key,
				      array obA);

/* DEBUGGING: Print the collection JOVEISc */
extern void JOVEIScPrint(register JOVEISc sc);


/* Iterate over the elements of the collection JOVEISc.  
 * At each iteration, JOVEISckey and JOVEIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	JOVEIScForEach(someSc, key, value) {
 *	  / * whatever you want to do with key, value * /
 *	} JOVEIScNext();
 */
#define JOVEIScForEach(JOVEISc, JOVEISckey, JOVEIScvalue) \
  { \
    int JOVEIScxx_index; \
    for (JOVEIScxx_index = 0; JOVEIScxx_index < (JOVEISc)->size; JOVEIScxx_index++) { \
      if ((JOVEISc)->table[JOVEIScxx_index].key != NULL) { \
	(JOVEISckey) = JOVEISc->table[JOVEIScxx_index].key; \
	*(JOVEISCRangeType *)(&(JOVEIScvalue)) = JOVEISc->table[JOVEIScxx_index].value; \
	{ 

#define JOVEIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in JOVEISc */
#define JOVEIScSize(JOVEISc) ((JOVEISc)->count)

#endif /* _EMERALD_JOVEISC_H */
