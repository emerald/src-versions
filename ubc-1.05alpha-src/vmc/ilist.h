/*
 * @(#)ilist.h	1.3  5/24/89
 */
#ifndef ilist_h
#define ilist_h
/*
 * Seqs are an array sequence of some domain.
 * Operations:
 *	create, destroy, insert, member, size, and print
 */

/*
 * Before using this, one must define the following:
 *	IListDomainType	- a typedef for the domain
 *	IListCOMPARE	- a macro that compares two elements of 
 *				  the domain, evaluating to 1 if they are 
 *				  the same
 */
#define IListDomainType int
#define IListCOMPARE(X,Y) ((X)==(Y))

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is IList,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct IListTE {
    IListDomainType key;		/* the key for this entry */
} IListTE, *IListTEPtr;

typedef struct IListRecord {
    IListTEPtr table;
    int size, count;
} IListRecord, *IList;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
IList IListCreate();

/* Destroy a collection */
void IListDestroy();

/* Insert the key into the set IList */
void IListInsert(/* IList sq, IListDomainType key */);

/* Delete the key key from the set IList */
void IListDelete(/* IList sq, IListDomainType key */);

/* Return the key if it is in the set otherwise NULL */
IListDomainType IListMember(/* IList sc, IListDomainType key */);

/* DEBUGGING: Print the collection IList */
void IListPrint(/* IList sc */);

/* Iterate over the elements of the collection IList.  
 * At each iteration, IListkey is set to the next key in the set.  
 * Usage:
 *	IListForEach(someSq, key) {
 *	  / * whatever you want to do with key * /
 *	} IListNext();
 */
#define IListForEach(IList, IListkey) \
  { \
    int IListxx_index; \
    for (IListxx_index = 0; IListxx_index < (IList)->count; IListxx_index++) { \
      *(IListDomainType*)(&(IListkey)) = IList->table[IListxx_index].key; \
      { 

/* Iterate over the elements of the collection IList.  
 * At each iteration, IListkey is set to the next key in the set.  
 * Usage:
 *	IListForEachReverse(someSq, key) {
 *	  / * whatever you want to do with key * /
 *	} IListNext();
 */
#define IListForEachReverse(IList, IListkey) \
  { \
    int IListxx_index; \
    for (IListxx_index = (IList->count-1); IListxx_index >= 0; IListxx_index--) { \
      *(IListDomainType*)(&(IListkey)) = IList->table[IListxx_index].key; \
      { 

/* Iterate over the elements of the collection IList, two at a time.
 * At each iteration, IListkey1 and IListkey2 are set to the next keys
 * in the list.
 * Usage:
 *	IListForEachByTwo(someSq, key1, key2) {
 *	  / * whatever you want to do with key1 and key2 * /
 *	} IListNext();
 */
#define IListForEachByTwo(IList, IListkey1, IListkey2) \
  { \
    int IListxx_index; \
    for (IListxx_index = 0; IListxx_index < (IList)->count; IListxx_index += 2) { \
      *(IListDomainType*)(&(IListkey1)) = IList->table[IListxx_index].key; \
      *(IListDomainType*)(&(IListkey2)) = IList->table[IListxx_index+1].key; \
      {

/* Iterate over the elements of the collection IList, three at a time.
 * At each iteration, IListkey1, IListkey2, IListkey3 are set to the next
 * keys in the set.
 * Usage:
 *	IListForEachByThree(someSq, key1, key2, key3) {
 *	  / * whatever you want to do with key1, key2, key3 * /
 *	} IListNext();
 */
#define IListForEachByThree(IList, IListkey1, IListkey2, IListkey3) \
  { \
    int IListxx_index; \
    for (IListxx_index = 0; IListxx_index < (IList)->count; IListxx_index += 3) { \
      *(IListDomainType*)(&(IListkey1)) = IList->table[IListxx_index].key; \
      *(IListDomainType*)(&(IListkey2)) = IList->table[IListxx_index+1].key; \
      *(IListDomainType*)(&(IListkey3)) = IList->table[IListxx_index+2].key; \
      {

#define IListNext() \
      } \
    } \
  }

/* Return the number of elements in IList */
#define IListSize(IList) ((IList)->count)

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
