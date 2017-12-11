/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#include "system.h"
#include "ooisc.h"
#include "assert.h"

#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };
#define Hash(a,b,sc) (OOIScHASH(a,b) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define Hash(a,b, sc) (OOIScHASH(a,b) % sc->size)
#endif

#define MAXFILL(x) (((x) * 17) / 20)

/*
 * Turning on DEBUGSC will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */


#ifdef DEBUGSC
static void CheckOutHashTable();
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc)
#endif

/* Return a new, empty OOISc */
OOISc OOIScCreate(void)
{
  register int i;
  register OOISc sc;

  sc = (OOISc) vmMalloc(sizeof(OOIScRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (OOIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(OOIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].value = OOIScNIL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void OOIScDestroy(sc)
register OOISc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(OOISc sc)
{
  register OOIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (OOIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(OOIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].value = OOIScNIL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    if (OOIScIsNIL(oe->value)) continue;
    index = Hash(oe->key.a, oe->key.b, sc);
    while (1) {
      ne = &nh[index];
      if (OOIScIsNIL(ne->value)) {
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
  CHECKOUTHASHTABLE(sc);
}

/* Return the value associated with key in collection sc, or OOIScNIL */
OOIScRangeType OOIScLookup(OOISc sc, OID a, OID b)
{
  register int index = Hash(a, b, sc);
  register OOIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (OOIScIsNIL(e->value)) {         /* we did not find it */
      return OOIScNIL;
    } else if (OOIScCOMPARE(e->key, a, b)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc, or insert 1 */
OOIScRangeType OOIScBump(OOISc sc, OID a, OID b)
{
  register int index = Hash(a, b, sc);
  register OOIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (OOIScIsNIL(e->value)) {         /* we did not find it */
      OOIScInsert(sc, a, b, 1);
      return 1;
    } else if (OOIScCOMPARE(e->key, a, b)) {
      return ++e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Bump the value associated with key in collection sc by value */
OOIScRangeType OOIScBumpBy(OOISc sc, OID a, OID b, int value)
{
  register int index = Hash(a, b, sc);
  register OOIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (OOIScIsNIL(e->value)) {         /* we did not find it */
      OOIScInsert(sc, a, b, value);
      return value;
    } else if (OOIScCOMPARE(e->key, a, b)) {
      e->value += value;
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void OOIScInsert(OOISc sc, OID a, OID b, OOIScRangeType value)
{
  register int index;
  register OOIScTEPtr e;

  assert(!OOIScIsNIL(value));
  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(a, b, sc);
  while (1) {
    e = &sc->table[index];
    if (OOIScIsNIL(e->value)) {         /* put it here */
      e->key.a = a;
      e->key.b = b;
      e->value = value;
      sc->count++;
      CHECKOUTHASHTABLE(sc);
      return;
    } else if (OOIScCOMPARE(e->key, a, b)) {
      e->value = value;
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Remove the entry, if it is there */
void OOIScDelete(OOISc sc, OID a, OID b)
{
  register int index = Hash(a, b, sc);
  OOIScDomainType key;
  register OOIScRangeType value;
  register OOIScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (OOIScIsNIL(e->value)) {         /* we did not find it */
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (OOIScCOMPARE(e->key, a, b)) {
      /* Found it, now remove it */
      sc->count--;
      e->value = OOIScNIL;
      while (1) {
	/* rehash until we reach nil again */
	if (++index >= sc->size) index = 0;
	e = & sc->table[index];
	key = e->key;
	if (OOIScIsNIL(e->value)) {
	  CHECKOUTHASHTABLE(sc);
	  return;
	}
	/* rehashing is done by removing then reinserting */
	value = e->value;
	e->value = OOIScNIL;
	sc->count--;
	OOIScInsert(sc, key.a, key.b, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
#define PrintOID(o) printf("%08x.%04d.%04d.%08x", \
			   o.ipaddress, o.port, o.epoch, o.Seq)

void OOIScPrint(OOISc sc)
{
  int index;
  register OOIScTEPtr e;

  printf("Dump of sc @ 0x%05x, %d entr%s, current max %d\n", 
	 (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  printf("Index\tKey\t\t\t\t\t\t\t\tValue\n");
  for (index = 0; index < sc->size; index++) {
    e = &sc->table[index];
    printf("%3d\t", index);
    PrintOID(e->key.a);
    printf("\t");
    PrintOID(e->key.b);
    printf("\t%08x\n", e->value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register OOISc sc;
{
  register int i;
  register OOIScTEPtr realE, e;
  register int index, firstIndex, count;
  int problemFound = 0;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    realE = &sc->table[i];
    if (!OOIScIsNIL(realE->value)) {
      count++;
      index = Hash(realE->key.a, realE->key.b, sc);
      firstIndex = index;
      while (1) {
	e = &sc->table[index];
	if (OOIScIsNIL(e->value)) {             /* we did not find it */
	  problemFound ++;
	  fprintf(stderr, "Sc problem: Can't find (");
	  PrintOID(realE->key.a);
	  fprintf(stderr, ", ");
	  PrintOID(realE->key.b);
	  fprintf(stderr, ") -> %#x\n", realE->value);
	  fprintf(stderr, "  Is at index %d\n", i);
	  fprintf(stderr, "  Hashes to index %d\n", firstIndex);
	  fprintf(stderr, "  Search to index %d doesn't find it\n", index);
	  break;
	} else if (OOIScCOMPARE(e->key, realE->key.a, realE->key.b)) {
	  break;
	} else {
	  index++;
	  if (index >= sc->size) index = 0;
	  assert (index != firstIndex);
	}
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr, "Sc problem: Should have %d entries, but found %d.\n", 
	    sc->count, count);
    problemFound ++;
  }
  if (problemFound) OOIScPrint(sc);
}
#endif
