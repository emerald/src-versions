/* 
 * @(#)sisc.c	1.2  1/11/90
 */

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

#include "sisc.h"

static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define MAXFILL 0.85

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC

static unsigned stringintHash();

#define Hash(key, sc) (HASH(key) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#endif

/* Return a new, empty SISc */
SISc SIScCreate()
{
  register int i;
  register SISc sc;

  sc = (SISc) malloc(sizeof(SIScRecord));
  sc->size = sizes[0];
  sc->maxCount = sc->size * MAXFILL;
  sc->count = 0;
  sc->table = (SIScTEPtr) malloc((unsigned) sc->size * sizeof(SIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = NULL;
  }
#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif /* DEBUGSC */
  return sc;
}

void SIScDestroy(sc)
register SISc sc;
{
  free((char *)sc->table);
  free((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(sc)
register SISc sc;
{
  register SIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register DomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = sc->size * MAXFILL;
  nh = (SIScTEPtr) malloc((unsigned)(sc->size * sizeof(SIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = NULL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == NULL) continue;
    index = Hash((unsigned char *)key, sc);
    while (1) {
      ne = &nh[index];
      if (ne->key == NULL) {
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
RangeType SIScLookup(sc, key)
register SISc sc;
register DomainType  key;
{
  register int index = Hash((unsigned char *)key, sc);
  register SIScTEPtr e;

#ifdef DEBUGSC
  CheckOutHashTable(sc);
#endif /* DEBUGSC */
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {		/* we did not find it */
      return -1;
    } else if (COMPARE(e->key, key)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void SIScInsert(sc, key, value)
register SISc sc;
register DomainType key;
RangeType value;
{
  register int index;
  register SIScTEPtr e;

  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash((unsigned char *)key, sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {		/* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif /* DEBUGSC */
      return;
    } else if (COMPARE(e->key, key)) {
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
void SIScDelete(sc, key)
register SISc sc;
register DomainType key;
{
  register int index = Hash((unsigned char *)key, sc);
  register RangeType value;
  register SIScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {		/* we did not find it */
#ifdef DEBUGSC
      CheckOutHashTable(sc);
#endif /* DEBUGSC */
      return;
    }
    if (COMPARE(e->key, key)) {
      /* Found it, now remove it */
      sc->count--;
      e->key = NULL;
      e->value = (int)NULL;
      while (1) {
        /* rehash until we reach nil again */
        if (++index >= sc->size) index = 0;
        e = & sc->table[index];
        key = e->key;
        if (key == NULL) {
#ifdef DEBUGSC
	  CheckOutHashTable(sc);
#endif /* DEBUGSC */
	  return;
	}
        /* rehashing is done by removing then reinserting */
        value = e->value;
        e->key = NULL;
	e->value = (int)NULL;
        sc->count--;
        SIScInsert(sc, key, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
void SIScPrint(sc)
register SISc sc;
{
  DomainType key;
  RangeType value;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\t\tValue\n",
    sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
/* FIX THIS */
    printf("%3d\t%-16.16s0x%08.8x\n", index, key, value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *	every key is findable, 
 *	count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register SISc sc;
{
  register int i;
  register SIScTEPtr realElement, e;
  register int index, firstIndex, count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (realElement->key != NULL) {
      count++;
      index = Hash((unsigned char *)realElement->key, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (e->key == NULL) {		/* we did not find it */
	  break;
	} else if (COMPARE(e->key, realElement->key)) {
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
      
      if (index == -1 || !COMPARE(e->key, realElement->key)) {
	/* FIX THIS */
	fprintf(stderr,
	  "Sc problem: Key %s, rightIndex %d, realIndex %d value 0x%x\n",
	  realElement->key, firstIndex, index, realElement->value);
	SIScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    SIScPrint(sc);
  }
}
#endif
/* String hashing function, from Red Dragon Book */

static unsigned stringintHash(key)
register unsigned char *key;
{
  register unsigned h = 0, g;
  for (; *key; key++) {
    h =  (h << 4) + (*key);
    if (g = h & 0xf0000000) {
      h = h ^ (g >> 24);
      h = h ^ g;
    }
  }
  return h;
}
