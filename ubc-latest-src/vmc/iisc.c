/*
 * @(#)iisc.c	1.2  1/11/90
 */
#include "iisc.h"

/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#ifndef NULL
#include <stdio.h>
#endif

#ifndef assert
#include <assert.h>
#endif

static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define MAXFILL 0.375

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC

#define Hash(key, sc) (IIScHASH(key) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#endif

/* Return a new, empty IISc */
IISc IIScCreate()
{
  register int i;
  register IISc sc;

  sc = (IISc) malloc(sizeof(IIScRecord));
  sc->size = sizes[0];
  sc->maxCount = sc->size * MAXFILL;
  sc->count = 0;
  sc->table = (IIScTEPtr) malloc((unsigned) sc->size * sizeof(IIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = 0;
  }
#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif /* DEBUGSC */
  return sc;
}

void IIScDestroy(sc)
register IISc sc;
{
  free((char *)sc->table);
  free((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(sc)
register IISc sc;
{
  register IIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register IIScDomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = sc->size * MAXFILL;
  nh = (IIScTEPtr) malloc((unsigned)(sc->size * sizeof(IIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = 0;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == 0) continue;
    index = Hash(key, sc);
    while (1) {
      ne = &nh[index];
      if (ne->key == 0) {
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
  free((char *)sc->table);
  sc->table = nh;
#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif /* DEBUGSC */
}

/* Return the value associated with key in collection sc, or -1 */
IIScRangeType IIScLookup(sc, key)
register IISc sc;
register IIScDomainType  key;
{
  register int index = Hash(key, sc);
  register IIScTEPtr e;

#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif /* DEBUGSC */
  while (1) {
    e = &sc->table[index];
    if (e->key == 0) {		/* we did not find it */
      return -1;
    } else if (IIScCOMPARE(e->key, key)) {
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

  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(key, sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == 0) {		/* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif /* DEBUGSC */
      return;
    } else if (IIScCOMPARE(e->key, key)) {
      e->value = value;
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif /* DEBUGSC */
      return;
    }
    if (++index >= sc->size) index = 0;
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
    if (e->key == 0) {		/* we did not find it */
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif /* DEBUGSC */
      return;
    }
    if (IIScCOMPARE(e->key, key)) {
      /* Found it, now remove it */
      sc->count--;
      e->key = 0;
      e->value = 0;
      while (1) {
        /* rehash until we reach nil again */
        if (++index >= sc->size) index = 0;
        e = & sc->table[index];
        key = e->key;
        if (key == 0) {
#ifdef DEBUGSC
	  CheckOutHashTable(sc);
#endif /* DEBUGSC */
	  return;
	}
        /* rehashing is done by removing then reinserting */
        value = e->value;
        e->key = 0;
	e->value = 0;
        sc->count--;
        IIScInsert(sc, key, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
void IIScPrint(sc)
register IISc sc;
{
  IIScDomainType key;
  IIScRangeType value;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\t\tValue\n",
    sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
    printf("%3d\t0x%08.8x\t%08.8x\n", index, key, value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *	every key is findable, 
 *	count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register IISc sc;
{
  register int i;
  register IIScTEPtr realElement, e;
  register int index, firstIndex, count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (realElement->key != 0) {
      count++;
      index = Hash(realElement->key, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (e->key == 0) {		/* we did not find it */
	  break;
	} else if (IIScCOMPARE(e->key, realElement->key)) {
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
      
      if (index == -1 || !IIScCOMPARE(e->key, realElement->key)) {
FIX THIS
	fprintf(stderr,
	  "Sc problem: Key 0x%x, rightIndex %d, realIndex %d value 0x%x\n",
	  realElement->key, firstIndex, index, realElement->value);
	IIScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    IIScPrint(sc);
  }
}
#endif
