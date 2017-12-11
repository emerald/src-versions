/*
 * Trivial dynamic read-only arrays
 */

#ifndef _EMERALD_ARRAY_H
#define _EMERALD_ARRAY_H

#ifndef _EMERALD_STORAGE_H
#include "storage.h"
#endif

typedef struct array {
  int *base, *limit, *cp;
} *array;

#define ASUB(a,i) (*((a)->base + (int)(i)))
#define REF(a,i) ((a)->base + (int)(i))
#define ARRAYSIZE(a) ((a)->cp - (a)->base)
extern array arrayCreate(int);
extern void arrayAppend(array, int);
extern void arrayDestroy(array);

#endif /* _EMERALD_ARRAY_H */
