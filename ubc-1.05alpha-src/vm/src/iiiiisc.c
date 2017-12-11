/* comment me!
 */

#include "iiiiisc.h"

/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#ifndef NULL
#include <stdio.h>
#endif

#ifndef assert
#include "assert.h"
#endif

static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define MAXFILL(x) (((x) * 17) / 20)

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC

#define Hash(a,b,c,d,sc) (IIIIIScHASH(a,b,c,d) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#endif

/* Return a new, empty IIIIISc */
IIIIISc IIIIIScCreate()
{
  register int i;
  register IIIIISc sc;

  sc = (IIIIISc) vmMalloc(sizeof(IIIIIScRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (IIIIIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(IIIIIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key.a = IIIIIScNIL;
  }
#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif DEBUGSC
  return sc;
}

void IIIIIScDestroy(sc)
register IIIIISc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(sc)
register IIIIISc sc;
{
  register IIIIIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (IIIIIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(IIIIIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key.a = IIIIIScNIL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    if (oe->key.a == IIIIIScNIL) continue;
    index = Hash(oe->key.a, oe->key.b, oe->key.c, oe->key.d, sc);
    while (1) {
      ne = &nh[index];
      if (ne->key.a == IIIIIScNIL) {
	ne->key = oe->key;
	ne->value = oe->value;
	break;
      } else {
	index++;
	if (index >= sc->size) index = 0;
      }
    }
  }
  vmFree((char *)sc->table);
  sc->table = nh;
#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif DEBUGSC
}

/* Return the value associated with key in collection sc, or IIIIIScNIL */
IIIIIScRangeType IIIIIScLookup(sc, a, b, c, d)
register IIIIISc sc;
register int  a, b, c, d;
{
  register int index = Hash(a,b,c,d, sc);
  register IIIIIScTEPtr e;

#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif DEBUGSC
  while (1) {
    e = &sc->table[index];
    if (e->key.a == IIIIIScNIL) {               /* we did not find it */
      return IIIIIScNIL;
    } else if (IIIIIScCOMPARE(e->key, a,b,c,d)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc, or insert 1 */
IIIIIScRangeType IIIIIScBump(sc, a,b,c,d)
register IIIIISc sc;
register int  a,b,c,d;
{
  register int index = Hash(a,b,c,d, sc);
  register IIIIIScTEPtr e;

#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif DEBUGSC
  while (1) {
    e = &sc->table[index];
    if (e->key.a == IIIIIScNIL) {               /* we did not find it */
      IIIIIScInsert(sc,a,b,c,d,1);
      return 1;
    } else if (IIIIIScCOMPARE(e->key, a,b,c,d)) {
      return ++e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc by value */
IIIIIScRangeType IIIIIScBumpBy(sc, a,b,c,d, value)
register IIIIISc sc;
register int a,b,c,d;
int value;
{
  register int index = Hash(a,b,c,d, sc);
  register IIIIIScTEPtr e;

#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif DEBUGSC
  while (1) {
    e = &sc->table[index];
    if (e->key.a == IIIIIScNIL) {               /* we did not find it */
      IIIIIScInsert(sc, a,b,c,d, value);
      return 1;
    } else if (IIIIIScCOMPARE(e->key, a,b,c,d)) {
      e->value += value;
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void IIIIIScInsert(sc, a,b,c,d, value)
register IIIIISc sc;
register int a,b,c,d;
IIIIIScRangeType value;
{
  register int index;
  register IIIIIScTEPtr e;

  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(a,b,c,d, sc);
  while (1) {
    e = &sc->table[index];
    if (e->key.a == IIIIIScNIL) {               /* put it here */
      e->key.a = a;
      e->key.b = b;
      e->key.c = c;
      e->key.d = d;
      e->value = value;
      sc->count++;
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif DEBUGSC
      return;
    } else if (IIIIIScCOMPARE(e->key, a,b,c,d)) {
      e->value = value;
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif DEBUGSC
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Remove the entry, if it is there */
void IIIIIScDelete(sc, a,b,c,d)
register IIIIISc sc;
register int a,b,c,d;
{
  register int index = Hash(a,b,c,d, sc);
  IIIIIScDomainType key;
  register IIIIIScRangeType value;
  register IIIIIScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (e->key.a == IIIIIScNIL) {               /* we did not find it */
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif DEBUGSC
      return;
    }
    if (IIIIIScCOMPARE(e->key, a,b,c,d)) {
      /* Found it, now remove it */
      sc->count--;
      e->key.a = IIIIIScNIL;
      e->value = IIIIIScNIL;
      while (1) {
	/* rehash until we reach nil again */
	if (++index >= sc->size) index = 0;
	e = & sc->table[index];
	key = e->key;
	if (key.a == IIIIIScNIL) {
#ifdef DEBUGSC
	  CheckOutHashTable(sc);
#endif DEBUGSC
	  return;
	}
	/* rehashing is done by removing then reinserting */
	value = e->value;
	e->key.a = IIIIIScNIL;
	e->value = IIIIIScNIL;
	sc->count--;
	IIIIIScInsert(sc, key.a, key.b, key.c, key.d, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
void IIIIIScPrint(sc)
register IIIIISc sc;
{
  int index;
  register IIIIIScTEPtr e;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey                                            \tValue\n",
    sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    e = &sc->table[index];
    printf("%3d\t0x%08.8x 0x%08.8x 0x%08.8x 0x%08.8x\t%08.8x\n", index, e->key.a, e->key.b, e->key.c, e->key.d, e->value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register IIIIISc sc;
{
  register int i;
  register IIIIIScTEPtr realElement, e;
  register int index, firstIndex, count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (realElement->key.a != IIIIIScNIL) {
      count++;
      index = Hash(realElement->key.a, realElement->key.b, realElement->key.c, realElement->key.d, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (e->key.a == IIIIIScNIL) {           /* we did not find it */
	  break;
	} else if (IIIIIScCOMPARE(e->key, realElement->key.a, realElement->key.b, realElement->key.c, realElement->key.d)) {
	  break;
	} else {
	  index++;
	  if (index >= sc->size) index = 0;
	  if (index == firstIndex) {
	    index = -1;
	    break;
	  }
	}
      }
      
      if (index == -1 || !IIIIIScCOMPARE(e->key, realElement->key)) {
FIX THIS
	fprintf(stderr,
	  "Sc problem: Key 0x%x, rightIndex %d, realIndex %d value 0x%x\n",
	  realElement->key, firstIndex, index, realElement->value);
	IIIIIScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    IIIIIScPrint(sc);
  }
}
#endif
