/*
 * @(#)iisc.h	1.2  2/1/89
 */
#ifndef IISc_h
#define IISc_h
/*
 * IIScs (searchable collections) are things that map 
 * elements of some domain onto some range.  Operations:
 *	create, destroy, insert, lookup, size, and print
 */

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
#define IIScHASH(X) ((unsigned)((X) ^ ((X) << 4)))
#define IIScCOMPARE(X,Y) ((X)==(Y))

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
IISc IIScCreate();

/* Destroy a collection */
void IIScDestroy();

/* Insert the pair <key, value> into collection IISc */
void IIScInsert(/* IISc sc, IIScDomainType key, IIScRangeType value */);

/* Delete the pair with key key from the collection IISc */
void IIScDelete(/* IISc sc, IIScDomainType key */);

/* Return the value associated with key in collection 
 * IISc, or 0 if no such pair exists */
int IIScLookup(/* IISc sc, IIScDomainType key */);

/* DEBUGGING: Print the collection IISc */
void IIScPrint(/* IISc sc */);

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
      if ((IISc)->table[IIScxx_index].key != NULL) { \
	*(IIScDomainType*)(&(IISckey)) = IISc->table[IIScxx_index].key; \
	*(IIScRangeType *)(&(IIScvalue)) = IISc->table[IIScxx_index].value; \
	{ 

#define IIScNext() \
	} \
      } \
    } \
  }

/* Return the number of elements in IISc */
#define IIScSize(IISc) ((IISc)->count)

#endif
