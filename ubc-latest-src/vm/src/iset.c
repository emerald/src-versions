/*
 * Sets:
 *
 * Expanding hash tables with a key.
 */

#include "system.h"
#include "assert.h"
#include "iset.h"

#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };
#define Hash(key,sc) (ISetHASH(key) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define Hash(key, sc) (ISetHASH(key) % sc->size)
#endif
#define MAXFILL(x) (((x) * 17) / 20)

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC


#ifdef DEBUGSC
static void CheckOutHashTable();
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc) 
#endif

/* Return a new, empty ISet */
ISet ISetCreate()
{
  register int i;
  register ISet sc;

  sc = (ISet) vmMalloc(sizeof(ISetRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (ISetTEPtr) vmMalloc((unsigned) sc->size * sizeof(ISetTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = (int)NULL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

/* Return a new, empty ISet */
ISet ISetCreateN(int n)
{
  register int i;
  register ISet sc;

  sc = (ISet) vmMalloc(sizeof(ISetRecord));
  for (i = 0; sizes[i] < n; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (ISetTEPtr) vmMalloc((unsigned) sc->size * sizeof(ISetTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = (int)NULL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void ISetDestroy(sc)
register ISet sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(ISet sc)
{
  register ISetTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register ISetDomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (ISetTEPtr) vmMalloc((unsigned)(sc->size * sizeof(ISetTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = (int)NULL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == (int)NULL) continue;
    index = Hash(key, sc);
    while (1) {
      ne = &nh[index];
      if (ne->key == (int)NULL) {
	ne->key = oe->key;
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

/* Is key in the set sc */
int ISetMember(sc, key)
register ISet sc;
register ISetDomainType  key;
{
  register int index = Hash(key, sc);
  register ISetTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == (int)NULL) {          /* we did not find it */
      return 0;
    } else if (ISetCOMPARE(e->key, key)) {
      return 1;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Select a random (the first) key from the set sc */
ISetDomainType ISetSelect(sc)
register ISet sc;
{
  register int index = 0;
  register ISetTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key != (int)NULL) {          /* we found it */
      return e->key;
    }
    if (++index >= sc->size) return (int)NULL;
  }
}

void ISetDeleteAll(register ISet sc)
{
  int i;
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = (int)NULL;
  }
  sc->count = 0;
}

/* Insert the key in sc.  If the key already exists, do nothing. */
void ISetInsert(sc, key)
register ISet sc;
register ISetDomainType key;
{
  register int index;
  register ISetTEPtr e;

  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(key, sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == (int)NULL) {          /* put it here */
      e->key = key;
      sc->count++;
      CHECKOUTHASHTABLE(sc);
      return;
    } else if (ISetCOMPARE(e->key, key)) {
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Remove the entry, if it is there */
void ISetDelete(sc, key)
register ISet sc;
register ISetDomainType key;
{
  register int index = Hash(key, sc);
  register ISetTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (e->key == (int)NULL) {          /* we did not find it */
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (ISetCOMPARE(e->key, key)) {
      /* Found it, now remove it */
      sc->count--;
      e->key = (int)NULL;
      while (1) {
	/* rehash until we reach nil again */
	if (++index >= sc->size) index = 0;
	e = & sc->table[index];
	key = e->key;
	if (key == (int)NULL) {
	  CHECKOUTHASHTABLE(sc);
	  return;
	}
	/* rehashing is done by removing then reinserting */
	e->key = (int)NULL;
	sc->count--;
	ISetInsert(sc, key);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

#ifdef DEBUGSC
/* DEBUGGING: Print the set */
void ISetPrint(sc)
register ISet sc;
{
  ISetDomainType key;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\n",
    (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    if (key)
      printf("%3d\t%8d\n", index, key);
  }
}

/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register ISet sc;
{
  register int i;
  register ISetTEPtr realElement, e;
  register int index, firstIndex, count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (realElement->key != NULL) {
      count++;
      index = Hash(realElement->key, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (e->key == NULL) {           /* we did not find it */
	  break;
	} else if (ISetCOMPARE(e->key, realElement->key)) {
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
      
      if (index == -1 || !ISetCOMPARE(e->key, realElement->key)) {
FIX THIS
	fprintf(stderr,
	  "Sc problem: Key 0x%x, rightIndex %d, realIndex %d\n",
	  realElement->key, firstIndex, index);
	ISetPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    ISetPrint(sc);
  }
}
#endif
