/* comment me!
 */

#define E_NEEDS_STRING
#include "system.h"

#include "iixsc.h"
#include "assert.h"

/* Return a new, empty IIXSc */
IIXSc IIXScCreate()
{
  register IIXSc sc;

  sc = (IIXSc) vmMalloc(sizeof(IIXScRecord));
  memset( (void*)sc->smallOnes, 0, sizeof(sc->smallOnes) );
  sc->compacted = 0;
  sc->bigOnes = IIScCreate();
  return sc;
}

void IIXScCompact(IIXSc sc)
{
  int size, count = 2, value, i, index;
  for (size = 0; size < SMALLONES; size++) if (sc->smallOnes[size].i != 0) count++;
  count += IIScSize(sc->bigOnes);
  sc->pairs = (struct IIXScElement*) vmCalloc(count, 2 * sizeof(int));
  sc->pairs[0].size = 0;
  sc->pairs[0].value = 0;
  index = 1;
  for (size = 0; size < SMALLONES; size++) {
    if (sc->smallOnes[size].i != 0) {
      sc->pairs[index].size = size;
      sc->pairs[index].value = sc->smallOnes[size].i;
      sc->smallOnes[size].p = &sc->pairs[index];
      index++;
    } else {
      sc->smallOnes[size].p = &sc->pairs[index];
    }
  }
  sc->bigstart = index;
  IIScForEach(sc->bigOnes, size, value) {
    if (value > 0) {
      for (i = index - 1; i > 0 && sc->pairs[i].size > size; i--) {
	sc->pairs[i+1] = sc->pairs[i];
      }
      sc->pairs[i+1].size = size;
      sc->pairs[i+1].value = value;
      index++;
    }
  } IIScNext();
  for (i = sc->bigstart; i < index; i++) {
    assert(IIScLookup(sc->bigOnes, sc->pairs[i].size) > 0);
    IIScInsert(sc->bigOnes, sc->pairs[i].size, (int)&sc->pairs[i]);
  }
  assert(sc->pairs[count - 1].size == 0);
  assert(sc->pairs[count - 1].value == 0);
  sc->pairs[count - 1].size = 0x7fffffff;
  sc->pairs[count - 1].value = 0;
  sc->count = index;
  sc->compacted = 1;
}

void IIXScDestroy(sc)
register IIXSc sc;
{
  if (sc->compacted) vmFree((char *)sc->pairs);
  IIScDestroy(sc->bigOnes);
  vmFree((char *)sc);
}

int IIXScLookup(IIXSc sc, int key)
{
  if (sc->compacted) {
    struct IIXScElement *p;
    if (key < SMALLONES) {
      p = sc->smallOnes[key].p;
    } else {
      p = (struct IIXScElement *)IIScLookup(sc->bigOnes, key);
    }
    return p->value;
  } else {
    if (key < SMALLONES) return sc->smallOnes[key].i;
    return IIScLookup(sc->bigOnes, key);
  }
}

static inline struct IIXScElement *find(IIXSc sc, int size)
{
  if (size < SMALLONES) {
    return sc->smallOnes[size].p;
  } else {
    int lb = sc->bigstart, ub = sc->count - 1, try;
    while (lb < ub) {
      try = (lb + ub) / 2;
      if (sc->pairs[try].size == size) {
	return &sc->pairs[try];
      } else if (sc->pairs[try].size < size) {
	lb = try + 1;
      } else {
	ub = try - 1;
      }
    }
    return &sc->pairs[ub];
  }
}

/* Bump the value associated with key in collection sc, or insert 1 */
int IIXScBump(IIXSc sc, int key)
{
  if (sc->compacted) {
    struct IIXScElement *p;
    if (key < SMALLONES) {
      p = sc->smallOnes[key].p;
    } else {
      p = (struct IIXScElement *)IIScLookup(sc->bigOnes, key);
    }
    return ++p->value;
  } else {
    if (key < SMALLONES) {
      return ++sc->smallOnes[key].i;
    } else {
      return IIScBump(sc->bigOnes, key);
    }
  }
}

int IIXScBumpBy(IIXSc sc, int key, int value)
{
  if (sc->compacted) {
    struct IIXScElement *p;
    if (key < SMALLONES) {
      p = sc->smallOnes[key].p;
    } else {
      p = (struct IIXScElement *)IIScLookup(sc->bigOnes, key);
    }
    return p->value += value;
  } else {
    if (key < SMALLONES) {
      return sc->smallOnes[key].i += value;
    } else {
      return IIScBumpBy(sc->bigOnes, key, value);
    }
  }
}

void IIXScInsert(IIXSc sc, int key, int value)
{
  assert(!sc->compacted);
  
  if (key < SMALLONES) sc->smallOnes[key].i = value;
  else IIScInsert(sc->bigOnes, key, value);
}

int IIXScSelectSmaller(IIXSc sc, int key)
{
  struct IIXScElement *r;
  int firstprobe;
  assert(sc->compacted);
  
  r = find(sc, key);
  if (r->size != key || r->value <= 0) {
    firstprobe = key > 10 ? key / 2 + 2 : key - 2;
    while (r->size > firstprobe) --r;
  }
  while (r >= sc->pairs && r->value <= 0) {
    --r;
  }
  if (r >= sc->pairs) {
    r->value--;
    return r->size;
  } else {
    return 0;
  }
}

#ifdef DEBUGSC
void IIXScPrint(IIXSc sc)
{
  int i;

  printf("\nDump of sc @ 0x%05x\nKey\t\tValue\n", (int)sc);
  for (i = 0; i < SMALLONES; i++) {
    if (sc->smallOnes[i].i > 0)
      printf("0x%08x\t%08x\n", i, sc->smallOnes[i].i);
  }
  IIScPrint(sc->bigOnes);
}
#endif

void IIXScMap(IIXSc sc, void (*f)(int, int, void *), void *a)
{
  int i, key, value;
  if (sc->compacted) {
    for (i = 0; i < sc->count; i++) {
      f(sc->pairs[i].size, sc->pairs[i].value, a);
    }
  } else {
    for (i = 0; i < SMALLONES; i++) {
      if (sc->smallOnes[i].i > 0) 
	f(i, sc->smallOnes[i].i, a);
    }
    IIScForEach(sc->bigOnes, key, value) {
      f(key, value, a);
    } IIScNext();
  }
}
