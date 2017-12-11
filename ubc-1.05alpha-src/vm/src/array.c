/*
 * Unbounded arrays of int sized things.
 */

#define E_NEEDS_STRING
#include "system.h"

#include "array.h"

void arrayDestroy(array a)
{
  if(a->base){
    memset((void*)a->base, 0, a->limit-a->base);
    vmFree(a->base);
    a->base = a->limit = a->cp = 0;
    vmFree(a);
  }
}

array arrayCreate(int blocksize)
{
  array a = (array)vmMalloc(sizeof(struct array));
  if (blocksize<2) blocksize = 2; /* required for append to work right */
  a->base = (int *)vmMalloc(blocksize * sizeof(int));
  a->cp   = a->base;
  a->limit= a->base + blocksize - 1;
  return a;
}

void arrayAppend(array a, int l)
{
  int size;
  *a->cp++ = l;
  if (a->cp >= a->limit) {
    size     = a->limit - a->base + 1;
    size    += size;
    a->base  = (int *)vmRealloc(a->base, size * sizeof(int));
    a->limit = a->base + size - 1;
    a->cp    = a->limit - (size >> 1);
  }
}
