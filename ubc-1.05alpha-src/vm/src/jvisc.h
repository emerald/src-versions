/* 
 * JVIScs (searchable collections) are things that map 
 * jekyll vectors onto integers.
 *	Operations create, destroy, insert, lookup, size, and print
 */

#ifndef _EMERALD_JVISC_H
#define _EMERALD_JVISC_H
#include "storage.h"

/*
 * Before using this, one must define the following:
 *	DomainType	- a typedef for the domain
 *	RangeType	- a typedef for the range
 *	HASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	COMPARE		- a macro that compares two elements of the domain,
 *			  evaluating to 1 if they are the same
 */
#include "types.h"
typedef String DomainType;
typedef int   RangeType;

#define COMPARE(A, B) ((((Vector) A)->d.items == ((Vector) B)->d.items)  && \
		       !veccmp((Vector)(A), (Vector)(B)))

#define HASH(key) vecintHash(key)
extern int veccmp(Vector, Vector);

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is JVISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct JVIScTE {
    DomainType	 key;		/* the key for this entry */
    RangeType	 value;		/* what we want */
} JVIScTE, *JVIScTEPtr;

typedef struct JVIScRecord {
    JVIScTEPtr table;
    int size, maxCount, count;
} JVIScRecord, *JVISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
JVISc JVIScCreate(void);

/* Destroy a collection */
void JVIScDestroy(JVISc);

/* Insert the pair <key, value> into collection JVISc */
void JVIScInsert(JVISc sc, DomainType key, RangeType value);

/* Delete the pair with key key from the collection JVISc */
void JVIScDelete(JVISc sc, DomainType key);

/* Return the value associated with key in collection 
 * JVISc, or 0 if no such pair exists */
int JVIScLookup(JVISc sc, DomainType key);

/* DEBUGGING: Print the collection JVISc */
void JVIScPrint(JVISc sc);

/* Iterate over the elements of the collection JVISc.  
 * At each iteration, JVISckey and JVIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	JVIScForEach(someSc, key, value) {
 *	  / * whatever you want to do with key, value * /
 *	} JVIScNext();
 */
#define JVIScForEach(JVISc, JVISckey, JVIScvalue) \
  { \
    int JVIScxx_index; \
    for (JVIScxx_index = 0; JVIScxx_index < (JVISc)->size; JVIScxx_index++) { \
      if ((JVISc)->table[JVIScxx_index].key != NULL) { \
	(JVISckey) = JVISc->table[JVIScxx_index].key; \
	*(RangeType *)(&(JVIScvalue)) = JVISc->table[JVIScxx_index].value; \
	{ 

#define JVIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in JVISc */
#define JVIScSize(JVISc) ((JVISc)->count)

#endif /* _EMERALD_JVISC_H */
