/* comment me!
 */

#ifndef _EMERALD_IIXSC_H
#define _EMERALD_IIXSC_H

#include "iisc.h"
#define IIXScNIL IIScNIL
#define IIXScIsNIL(x) IIScIsNIL(x)

#define SMALLONES (2 * 1024 + 3)

struct IIXScElement {
  int size, value;
};

typedef struct IIXScRecord {
    union { int i; struct IIXScElement *p; } smallOnes[SMALLONES];
    IISc bigOnes;
    int compacted;
    int count, bigstart;
    struct IIXScElement *pairs;
} IIXScRecord, *IIXSc;

/* OPERATIONS */

/* Return a new, empty Searchable Collection */
IIXSc IIXScCreate(void);

/* Destroy a collection */
void IIXScDestroy(IIXSc);

/* Insert the pair <key, value> into collection IIXSc */
void IIXScInsert(IIXSc sc, int key, int value);

/* bump the value associated with some given key in the IIXSc */
int IIXScBump(IIXSc sc, int key);

/* bump the value associated with some given key in the IIXSc by value */
int IIXScBumpBy(IIXSc sc, int key, int value);

/* Prepare for calling SelectSmaller */
void IIXScCompact(IIXSc sc);

/* Select the largest key in the set that is no larger than key */
int IIXScSelectSmaller(IIXSc sc, int key);

/* Return the value associated with key in collection 
 * IIXSc, or 0 if no such pair exists */
int IIXScLookup(IIXSc sc, int key);

/* DEBUGGING: Print the collection IIXSc */
void IIXScPrint(IIXSc sc);

void IIXScMap(IIXSc sc, void (*f)(int, int, void *), void *a);
#include "storage.h"

#endif /* _EMERALD_IIXSC_H */
