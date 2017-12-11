/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#define E_NEEDS_STRING
#include "system.h"

#include "oisc.h"
#include "assert.h"
#include "trace.h"
#include "oidtoobj.h"

static unsigned oiscHash(unsigned char *key, int len);
static void ExpandHashTable(OISc sc);

#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };
#define Hash(key,sc) (oiscHash((unsigned char *)&key, sizeof(key)) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define Hash(key, sc) (oiscHash((char *)&key, sizeof(key)) % sc->size)
#endif

#define MAXFILL(x) (((x) * 17) / 20)
#define OFSIZE(x)  (x)

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

static int chooseSize(int size)
{
  int i;
  for (i = 0; sizes[i] <= size; i++) ;
  return sizes[i];
}

/* Return a new, empty OISc */
OISc OIScCreateN(int size)
{
  register int i;
  register OISc sc;

  sc = (OISc) vmMalloc(sizeof(OIScRecord));
  sc->size = chooseSize(size);
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->ofsize = OFSIZE(sc->size);
  sc->ofcount = 0;
  sc->table = (OIScTEPtr) vmMalloc((unsigned) OIScTSize(sc) * sizeof(OIScTE));
  for (i = 0; i < OIScTSize(sc); i++) {
    sc->table[i].value = OIScNIL;
  }
  for (i = sc->size; i < OIScTSize(sc) - 1; i++) {
    sc->table[i].chain = i + 1;
  }
  sc->of = sc->size;
  CHECKOUTHASHTABLE(sc);
  return sc;
}

OISc OIScCreate(void)
{
  return OIScCreateN(2);
}

/* Return a clone of the given OISc */
OISc OIScClone(OISc original)
{
  register OISc sc;

  sc = (OISc) vmMalloc(sizeof(OIScRecord));
  *sc = *original;
  sc->table = (OIScTEPtr) vmMalloc((unsigned) OIScTSize(sc) * sizeof(OIScTE));
  memmove(sc->table, original->table, (unsigned) OIScTSize(sc)*sizeof(OIScTE));
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void OIScDestroy(sc)
register OISc sc;
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/*
 * Insert the key, value pair in sc.  If the key already exists, change its 
 * value.
 */
static void IOIScInsert(OISc sc, OID a, OIScRangeType value)
{
  register int index;
  register OIScTEPtr e, ne;

  assert(!OIScIsNIL(value));
  if (sc->count >= sc->maxCount || sc->ofcount >= sc->ofsize) ExpandHashTable(sc);
  index = Hash(a, sc);
  e = &sc->table[index];
  if (OIScIsNIL(e->value)) {          /* put it here */
    e->key = a;
    e->value = value;
    e->chain = 0;
    sc->count++;
    return;
  }
  while (1) {
    if (OIScCOMPARE(e->key, a)) {
      e->value = value;
      return;
    } else if (e->chain) {
      e = &sc->table[e->chain];
    } else {
      assert(sc->of);
      e->chain = sc->of;
      ne = &sc->table[sc->of];
      sc->of = ne->chain;
      sc->ofcount++;
      ne->key = a;
      ne->value = value;
      ne->chain = 0;
      sc->count++;
      return;
    }
  }
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(OISc sc)
{
  register OISc newsc;
  register OIScTE *oe, *limit;

  newsc = OIScCreateN(sc->size+1);
  limit = &sc->table[OIScTSize(sc)];
  for (oe = &sc->table[0]; oe < limit; oe++) {
    if (OIScIsNIL(oe->value)) continue;
    IOIScInsert(newsc, oe->key, oe->value);
  }
  vmFree((char *)sc->table);
  *sc = *newsc;
  vmFree((char *)newsc);
  CHECKOUTHASHTABLE(sc);
}

/* Return the value associated with key in collection sc, or OIScNIL */
OIScRangeType OIScLookup(OISc sc, OID a)
{
  register int index = Hash(a, sc);
  register OIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  e = &sc->table[index];
  if (OIScIsNIL(e->value)) return OIScNIL;
  while (1) {
    if (OIScCOMPARE(e->key, a)) {
      return e->value;
    } else if (e->chain) {
      e = &sc->table[e->chain];
    } else {
      return OIScNIL;
    }
  }
}

void OIScInsert(OISc sc, OID a, OIScRangeType value)
{
  IOIScInsert(sc, a, value);
  CHECKOUTHASHTABLE(sc);
}

/* Remove the entry, if it is there */
void OIScDelete(OISc sc, OID a)
{
  register int index = Hash(a, sc);
  register OIScTEPtr e, prev = 0;

  e = &sc->table[index];
  if (OIScIsNIL(e->value)) return;
  while (1) {
    if (OIScCOMPARE(e->key, a)) {
      if (prev) {
	/*
	 * This is in the overflow area
	 */
	int tofree = e - &sc->table[0];
	prev->chain = e->chain;
	sc->table[tofree].chain = sc->of;
	sc->table[tofree].value = OIScNIL;
	sc->of = tofree;
	sc->ofcount--;
      } else if (e->chain) {
	int tofree = e->chain;
	*e = sc->table[tofree];
	sc->table[tofree].chain = sc->of;
	sc->table[tofree].value = OIScNIL;
	sc->of = tofree;
	sc->ofcount--;
      } else {
	e->value = OIScNIL;
      }
      sc->count--;
      return;
    } else {
      prev = e;
      e = &sc->table[e->chain];
    }
  }
}

/* DEBUGGING: Print the sc */
#define PrintOID(o) printf("%08x.%04x.%04x.%08x", \
			   o.ipaddress, o.port, o.epoch, o.Seq)

void OIScPrint(OISc sc)
{
  int index;
  register OIScTEPtr e;

  printf("Dump of sc @ 0x%05x, %d entr%s, current max %d\n", 
	 (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  printf("Index\tKey\t\t\t\t\tValue\n");
  for (index = 0; index < OIScTSize(sc); index++) {
    e = &sc->table[index];
    printf("%3d\t", index);
    PrintOID(e->key);
    printf("\t%08x\n", e->value);
  }
}

#ifdef DEBUGSC
/* DEBUGGING: Print the sc */
void OIScPrintF(OISc sc)
{
  int index;
  register OIScTEPtr e;

  TRACE(memory, 3, ("Dump of sc @ 0x%05x, %d entr%s, current max %d", 
		     (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount));
  TRACE(memory, 3, ("Index\tKey\t\t\t\t\tValue"));
  for (index = 0; index < OIScTSize(sc); index++) {
    e = &sc->table[index];
    if (!OIScIsNIL(e->value)) {
      TRACE(memory, 3, ("%3d\t%s\t%08x",
			 index, OIDString(e->key), e->value));
    }
  }
}

/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
void OIScCheckOutHashTable(OISc sc)
{
  register int i;
  register OIScTEPtr realE, e;
  register int index, firstIndex, count;
  int problemFound = 0;
  count = 0;

  for (i = 0; i < OIScTSize(sc); i++) {
    realE = &sc->table[i];
    if (!OIScIsNIL(realE->value)) {
      count++;
      index = Hash(realE->key, sc);
      firstIndex = index;
      e = &sc->table[index];
      while (1) {
	if (OIScIsNIL(e->value)) {              /* we did not find it */
	  problemFound ++;
	  fprintf(stderr, "Sc problem: Can't find (");
	  PrintOID(realE->key);
	  fprintf(stderr, ") -> %#x\n", realE->value);
	  fprintf(stderr, "  Hashes to index %d\n", firstIndex);
	  break;
	} else if (OIScCOMPARE(e->key, realE->key)) {
	  break;
	} else {
	  e = &sc->table[e->chain];
	}
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr, "Sc problem: Should have %d entries, but found %d.\n", 
	    sc->count, count);
    problemFound ++;
  }
  if (problemFound) {
    OIScPrint(sc);
    abort();
  }
}
#endif

static unsigned oiscHash(unsigned char *key, int len)
{
  register unsigned h = 0, g;
  unsigned char *limit = key + len;
  for (; key < limit; key++) {
    h =  (h << 4) + (*key);
    if ((g = h & 0xf0000000)) {
      h = h ^ (g >> 24);
      h = h ^ g;
    }
  }
  return h;
}
