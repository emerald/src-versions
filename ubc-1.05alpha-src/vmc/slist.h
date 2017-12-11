/*
 * @(#)slist.h	1.3  5/24/89
 */
#ifndef SList_h
#define SList_h
/*
 * SLists are an array sequence of some domain.
 * Operations:
 *	create, destroy, insert, member, size, and print
 */

/*
 * Before using this, one must define the following:
 *	SListDomainType	- a typedef for the domain
 *	SListCOMPARE	- a macro that compares two elements of
 *				  the domain, evaluating to 1 if they are
 *				  the same
 */
typedef char *SListDomainType;
#define SListCOMPARE(X,Y) ((X)==(Y))

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is SList,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct SListTE {
    SListDomainType key;		/* the key for this entry */
} SListTE, *SListTEPtr;

typedef struct SListRecord {
    SListTEPtr table;
    int size, count;
} SListRecord, *SList;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
SList SListCreate();

/* Destroy a collection */
void SListDestroy();

/* Insert the key into the set SList */
void SListInsert(/* SList sq, SListDomainType key */);

/* Return the key if it is in the set otherwise NULL */
SListDomainType SListMember(/* SList sc, SListDomainType key */);

/* DEBUGGING: Print the collection SList */
void SListPrint(/* SList sc */);

/* Iterate over the elements of the collection SList.
 * At each iteration, SListkey is set to the next key in the list.
 * Usage:
 *	SListForEach(someSq, key) {
 *	  / * whatever you want to do with key * /
 *	} SListNext();
 */
#define SListForEach(SList, SListkey) \
  { \
    int SListxx_index; \
    for (SListxx_index = 0; SListxx_index < (SList)->count; SListxx_index++) { \
      *(SListDomainType*)(&(SListkey)) = SList->table[SListxx_index].key; \
      {

/* Iterate over the elements of the collection SList.  
 * At each iteration, SListkey is set to the next key in the set.  
 * Usage:
 *	SListForEachReverse(someSq, key) {
 *	  / * whatever you want to do with key * /
 *	} SListNext();
 */
#define SListForEachReverse(SList, SListkey) \
  { \
    int SListxx_index; \
    for (SListxx_index = (SList->count-1); SListxx_index >= 0; SListxx_index--) { \
      *(SListDomainType*)(&(SListkey)) = SList->table[SListxx_index].key; \
      { 

/* Iterate over the elements of the collection SList, two at a time.
 * At each iteration, SListkey1 and SListkey2 are set to the next keys
 * in the list.
 * Usage:
 *	SListForEachByTwo(someSq, key1, key2) {
 *	  / * whatever you want to do with key1 and key2 * /
 *	} SListNext();
 */
#define SListForEachByTwo(SList, SListkey1, SListkey2) \
  { \
    int SListxx_index; \
    for (SListxx_index = 0; SListxx_index < (SList)->count; SListxx_index += 2) { \
      *(SListDomainType*)(&(SListkey1)) = SList->table[SListxx_index].key; \
      *(SListDomainType*)(&(SListkey2)) = SList->table[SListxx_index+1].key; \
      {

/* Iterate over the elements of the collection SList, three at a time.
 * At each iteration, SListkey1, SListkey2, SListkey3 are set to the next
 * keys in the set.
 * Usage:
 *	SListForEachByThree(someSq, key1, key2, key3) {
 *	  / * whatever you want to do with key1, key2, key3 * /
 *	} SListNext();
 */
#define SListForEachByThree(SList, SListkey1, SListkey2, SListkey3) \
  { \
    int SListxx_index; \
    for (SListxx_index = 0; SListxx_index < (SList)->count; SListxx_index += 3) { \
      *(SListDomainType*)(&(SListkey1)) = SList->table[SListxx_index].key; \
      *(SListDomainType*)(&(SListkey2)) = SList->table[SListxx_index+1].key; \
      *(SListDomainType*)(&(SListkey3)) = SList->table[SListxx_index+2].key; \
      {

#define SListNext() \
      } \
    } \
  }

/* Return the number of elements in SList */
#define SListSize(SList) ((SList)->count)

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
