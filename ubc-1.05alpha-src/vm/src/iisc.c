/* comment me!
 */

#include "iisc.h"

/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#include "system.h"

#include "assert.h"

#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };
#define Hash(a,sc) (IIScHASH(a) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define Hash(key, sc) (IIScHASH(key) % sc->size)
#endif

#define MAXFILL(x) (((x) * 17) / 20)

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC

#ifdef DEBUGSC
void IIScCheckOut();
#define IISCCHECKOUT(sc) IIScCheckOut(sc)
#else
#define IISCCHECKOUT(sc) 
#endif

/* Return a new, empty IISc */
IISc IIScCreateN(int howbig)
{
  register int i;
  register IISc sc;

  sc = (IISc) vmMalloc(sizeof(IIScRecord));
  for (i = 0; sizes[i] < howbig; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (IIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(IIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = IIScNIL;
  }
  IISCCHECKOUT(sc);
  return sc;
}

void IIScDestroy(sc)
register IISc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(IISc sc)
{
  register IIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register IIScDomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (IIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(IIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = IIScNIL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == IIScNIL) continue;
    index = Hash(key, sc);
    while (1) {
      ne = &nh[index];
      if (ne->key == IIScNIL) {
	ne->key = oe->key;
	ne->value = oe->value;
	break;
      } else {
	assert(ne->key !=key);
	index++;
	if (index >= sc->size) index = 0;
      }
    }
  }
  vmFree((char *)sc->table);
  sc->table = nh;
  IISCCHECKOUT(sc);
}

/* Return the value associated with key in collection sc, or IIScNIL */
IIScRangeType IIScLookup(sc, key)
register IISc sc;
register IIScDomainType  key;
{
  register int index = Hash(key, sc);
  register IIScTEPtr e;

  IISCCHECKOUT(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == IIScNIL) {            /* we did not find it */
      return IIScNIL;
    } else if (IIScCOMPARE(e->key, key)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc, or insert 1 */
IIScRangeType IIScBump(sc, key)
register IISc sc;
register IIScDomainType  key;
{
  register int index = Hash(key, sc);
  register IIScTEPtr e;

  IISCCHECKOUT(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == IIScNIL) {            /* we did not find it */
      IIScInsert(sc,key,1);
      return 1;
    } else if (IIScCOMPARE(e->key, key)) {
      return ++e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc by value */
IIScRangeType IIScBumpBy(sc, key, value)
register IISc sc;
register IIScDomainType  key;
int value;
{
  register int index = Hash(key, sc);
  register IIScTEPtr e;

  IISCCHECKOUT(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == IIScNIL) {            /* we did not find it */
      IIScInsert(sc, key, value);
      return 1;
    } else if (IIScCOMPARE(e->key, key)) {
      e->value += value;
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void IIScInsert(sc, key, value)
register IISc sc;
register IIScDomainType key;
IIScRangeType value;
{
  register int index;
  register IIScTEPtr e;

  assert(key != IIScNIL);
  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(key, sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == IIScNIL) {            /* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
      IISCCHECKOUT(sc);
      return;
    } else if (IIScCOMPARE(e->key, key)) {
      e->value = value;
      IISCCHECKOUT(sc);
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Select a random (the first) key from the set sc */
IIScDomainType IIScSelect(sc,rangeptr)
register IISc sc;
IIScRangeType *rangeptr;
{
  register int index = 0;
  register IIScTEPtr e;

  IISCCHECKOUT(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key != IIScNIL) {            /* we found it */
      *rangeptr = e->value;
      return e->key;
    }
    if (++index >= sc->size) return (int)NULL;
  }
}

/* Remove the entry, if it is there */
void IIScDelete(sc, key)
register IISc sc;
register IIScDomainType key;
{
  register int index = Hash(key, sc);
  register IIScRangeType value;
  register IIScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (e->key == IIScNIL) {            /* we did not find it */
      IISCCHECKOUT(sc);
      return;
    }
    if (IIScCOMPARE(e->key, key)) {
      /* Found it, now remove it */
      sc->count--;
      e->key = IIScNIL;
      e->value = IIScNIL;
      while (1) {
	/* rehash until we reach nil again */
	if (++index >= sc->size) index = 0;
	e = & sc->table[index];
	key = e->key;
	if (key == IIScNIL) {
	  IISCCHECKOUT(sc);
	  return;
	}
	/* rehashing is done by removing then reinserting */
	value = e->value;
	e->key = IIScNIL;
	e->value = IIScNIL;
	sc->count--;
	IIScInsert(sc, key, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

#ifdef DEBUGSC
/* DEBUGGING: Print the sc */
void IIScPrint(sc)
register IISc sc;
{
  IIScDomainType key;
  IIScRangeType value;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\t\tValue\n",
    (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
    if (key != IIScNIL) 
      printf("%3d\t0x%08x\t%08x\n", index, key, value);
  }
}

/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
void IIScCheckOut(IISc sc)
{
  register int i;
  register IIScTEPtr realElement;
  register int count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (!IIScIsNIL(realElement->key)) {
      count++;
      if (IIScIsNIL(IIScLookup(sc, realElement->key))) {
	printf("IISc problem: Key %#x value 0x%x\n",
		realElement->key, realElement->value);
	IIScPrint(sc);
	abort();
      }
    }
  }
  if (count != sc->count) {
    printf("Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    IIScPrint(sc);
    abort();
  }
}
#endif
