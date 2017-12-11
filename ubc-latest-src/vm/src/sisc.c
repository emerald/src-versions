/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#include "system.h"

#include "assert.h"
#include "sisc.h"

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

static unsigned stringintHash(unsigned char *);

#define Hash(key, sc) (HASH(key) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc) 
#endif

/* Return a new, empty SISc */
SISc SIScCreate()
{
  register int i;
  register SISc sc;

  sc = (SISc) vmMalloc(sizeof(SIScRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (SIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(SIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = NULL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void SIScDestroy(sc)
register SISc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(SISc sc)
{
  register SIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register DomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (SIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(SIScTE)));
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
  vmFree((char *)sc->table);
  sc->table = nh;
  CHECKOUTHASHTABLE(sc);
}

/* Return the value associated with key in collection sc, or SIScNIL */
RangeType SIScLookup(sc, key)
register SISc sc;
register DomainType  key;
{
  register int index = Hash((unsigned char *)key, sc);
  register SIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {               /* we did not find it */
      return SIScNIL;
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
    if (e->key == NULL) {               /* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
      CHECKOUTHASHTABLE(sc);
      return;
    } else if (COMPARE(e->key, key)) {
      e->value = value;
      CHECKOUTHASHTABLE(sc);
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
    if (e->key == NULL) {               /* we did not find it */
      CHECKOUTHASHTABLE(sc);
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
	  CHECKOUTHASHTABLE(sc);
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
    (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
    printf("%3d\t%-16.16s0x%08x\n", index, key, value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
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
	if (e->key == NULL) {           /* we did not find it */
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

static unsigned stringintHash(unsigned char *key)
{
  register unsigned h = 0, g;
  for (; *key; key++) {
    h =  (h << 4) + (*key);
    if ((g = h & 0xf0000000)) {
      h = h ^ (g >> 24);
      h = h ^ g;
    }
  }
  return h;
}
