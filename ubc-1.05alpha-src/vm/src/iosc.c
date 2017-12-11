/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#include "system.h"
#include "iosc.h"
#include "assert.h"

#define USEPRIMESIZES
#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };
#define Hash(a,sc) (IOScHASH(a) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define Hash(key, sc) (IOScHASH(key) % sc->size)
#endif

#define MAXFILL(x) (((x) * 17) / 20)

/*
 * Turning on DEBUGSC will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#ifdef DEBUGSC
static void CheckOutHashTable(IOSc sc);
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc) 
#endif

static int chooseSize(int size)
{
  int i;
  for (i = 0; sizes[i] <= size; i++) ;
  return sizes[i];
}

/* Return a new, empty IOSc */
IOSc IOScCreateN(int size)
{
  register int i;
  register IOSc sc;

  sc = (IOSc) vmMalloc(sizeof(IOScRecord));
  sc->size = chooseSize(size);
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (IOScTEPtr) vmMalloc((unsigned) sc->size * sizeof(IOScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = IOScKNIL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

IOSc IOScCreate(void)
{
  return IOScCreateN(2);
}

void IOScDestroy(sc)
register IOSc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(IOSc sc)
{
  register IOScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register IOScDomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (IOScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(IOScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = IOScKNIL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (IOScKIsNIL(key)) continue;
    index = Hash(key, sc);
    while (1) {
      ne = &nh[index];
      if (IOScKIsNIL(ne->key)) {
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

/* Return the value associated with key in collection sc, or IOScNIL */
IOScRangeType IOScLookup(sc, key)
register IOSc sc;
register IOScDomainType  key;
{
  register int index = Hash(key, sc);
  register IOScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (IOScKIsNIL(e->key)) {           /* we did not find it */
      return IOScNIL;
    } else if (IOScCOMPARE(e->key, key)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void IOScInsert(sc, key, value)
register IOSc sc;
register IOScDomainType key;
IOScRangeType value;
{
  register int index;
  register IOScTEPtr e;

  assert(!IOScKIsNIL(key));
  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(key, sc);
  while (1) {
    e = &sc->table[index];
    if (IOScKIsNIL(e->key)) {           /* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
      CHECKOUTHASHTABLE(sc);
      return;
    } else if (IOScCOMPARE(e->key, key)) {
      e->value = value;
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Select a random (the first) key from the set sc */
IOScDomainType IOScSelect(sc,rangeptr)
register IOSc sc;
IOScRangeType *rangeptr;
{
  register int index = 0;
  register IOScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (!IOScKIsNIL(e->key)) {          /* we found it */
      *rangeptr = e->value;
      return e->key;
    }
    if (++index >= sc->size) return (int)NULL;
  }
}

/* Remove the entry, if it is there */
void IOScDelete(sc, key)
register IOSc sc;
register IOScDomainType key;
{
  register int index = Hash(key, sc);
  register IOScRangeType value;
  register IOScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (IOScKIsNIL(e->key)) {           /* we did not find it */
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (IOScCOMPARE(e->key, key)) {
      /* Found it, now remove it */
      sc->count--;
      e->key = IOScKNIL;
      while (1) {
	/* rehash until we reach nil again */
	if (++index >= sc->size) index = 0;
	e = & sc->table[index];
	key = e->key;
	if (IOScKIsNIL(key)) {
	  CHECKOUTHASHTABLE(sc);
	  return;
	}
	/* rehashing is done by removing then reinserting */
	value = e->value;
	e->key = IOScKNIL;
	sc->count--;
	IOScInsert(sc, key, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
#define PrintOID(o) printf("%#x.%04x.%04x.%#x", \
  			   o.ipaddress, o.port, o.epoch, o.Seq)

void IOScPrint(sc)
register IOSc sc;
{
  IOScDomainType key;
  IOScRangeType value;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\t\tValue\n",
    (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
    printf("%3d\t0x%08x\t", index, key);
    PrintOID(value);
    printf("\n");
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register IOSc sc;
{
  register int i;
  register IOScTEPtr realElement, e;
  register int index, firstIndex, count;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realElement = &sc->table[i];
    if (!IOScKIsNIL(realElement->key)) {
      count++;
      index = Hash(realElement->key, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (IOScKIsNIL(e->key)) {               /* we did not find it */
	  break;
	} else if (IOScCOMPARE(e->key, realElement->key)) {
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
      
      if (index == -1 || !IOScCOMPARE(e->key, realElement->key)) {
FIX THIS
	fprintf(stderr,
	  "Sc problem: Key 0x%x, rightIndex %d, realIndex %d value 0x%x\n",
	  realElement->key, firstIndex, index, realElement->value);
	IOScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    IOScPrint(sc);
  }
}
#endif
