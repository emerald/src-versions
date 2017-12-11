/* 
 * @(#)sisc.h	1.1  2/1/89
 */
#ifndef SISc_h
#define SISc_h
/*
 * SIScs (searchable collections) are things that map 
 * elements of some domain onto some range.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

/*
 * Before using this, one must define the following:
 *	DomainType	- a typedef for the domain
 *	RangeType	- a typedef for the range
 *	HASH		- a macro that computes an integer from a given
 *			  element of the domain
 *	COMPARE		- a macro that compares two elements of the domain,
 *			  evaluating to 1 if they are the same
 */
typedef char *DomainType;
typedef int   RangeType;

#define COMPARE(A, B) (!strcmp((A), (B)))

#define HASH(key) stringintHash((unsigned char *)key)

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is SISc,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct SIScTE {
    DomainType	 key;		/* the key for this entry */
    RangeType	 value;		/* what we want */
} SIScTE, *SIScTEPtr;

typedef struct SIScRecord {
    SIScTEPtr table;
    int size, maxCount, count;
} SIScRecord, *SISc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
SISc SIScCreate();

/* Destroy a collection */
void SIScDestroy();

/* Insert the pair <key, value> into collection SISc */
void SIScInsert(/* SISc sc, DomainType key, RangeType value */);

/* Delete the pair with key key from the collection SISc */
void SIScDelete(/* SISc sc, DomainType key */);

/* Return the value associated with key in collection 
 * SISc, or 0 if no such pair exists */
int SIScLookup(/* SISc sc, DomainType key */);

/* DEBUGGING: Print the collection SISc */
void SIScPrint(/* SISc sc */);

/* Iterate over the elements of the collection SISc.  
 * At each iteration, SISckey and SIScvalue are set to the next
 * <key, value> pair in the collection.  
 * Usage:
 *	SIScForEach(someSc, key, value) {
 *	  / * whatever you want to do with key, value * /
 *	} SIScNext();
 */
#define SIScForEach(SISc, SISckey, SIScvalue) \
  { \
    int SIScxx_index; \
    for (SIScxx_index = 0; SIScxx_index < (SISc)->size; SIScxx_index++) { \
      if ((SISc)->table[SIScxx_index].key != NULL) { \
	(SISckey) = SISc->table[SIScxx_index].key; \
	*(RangeType *)(&(SIScvalue)) = SISc->table[SIScxx_index].value; \
	{ 

#define SIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in SISc */
#define SIScSize(SISc) ((SISc)->count)

#ifdef USEGCMALLOC
extern char *gc_malloc(), *gc_calloc(), *gc_realloc(), *gc_free();
#define malloc(x) gc_malloc(x)
#define calloc(x,y) gc_calloc(x,y)
#define realloc(x,y) gc_realloc(x,y)
#define free(x) gc_free(x)
#else
#include <stdlib.h>
#endif

#endif
