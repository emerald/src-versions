/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#define E_NEEDS_STRING
#include "system.h"

#include "otable.h"
#include "assert.h"
#include "trace.h"
#include "oidtoobj.h"

static void ExpandHashTable(OTable sc);

#if !defined(USEPRIMESIZES)
static int sizes[] = {
  4, 8, 16, 32,
  64, 128, 256, 512,
  1024, 2048, 4096, 8192,
  16*1024, 32*1024, 64*1024, 128*1024,
  256*1024, 512*1024, 1024*1024, 2*1024*1024,
  4*1024*1024, 8*1024*1024, 16*1024*1024 };

#define p(x) ((unsigned int *)&(x))
#define OIDHash(key,sc) (((p(key)[0]) ^ (p(key)[1] << 1) ^ (p(key)[2])) & (sc->size - 1))

#define ObjectHash(key,sc) (((int)(key) ^ ((int)(key)>>3)) & (sc->size - 1))
#else
static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };

#define p(x) ((unsigned int *)&(x))
#define OIDHash(key,sc) (((p(key)[0]) ^ (p(key)[1] << 1) ^ (p(key)[2])) % (sc->size))
#define ObjectHash(key,sc) (((int)(key) ^ (int)((key)>>3)) % (sc->size))
#endif

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

/* Return a new, empty OTable */
OTable OTableCreateN(int size)
{
  register int i;
  register OTable sc;

  sc = (OTable) vmMalloc(sizeof(OTableRecord));
  sc->size = chooseSize(size);
  sc->count = 0;
  sc->table = (OTableTEPtr) vmMalloc((unsigned) sc->size * sizeof(OTableTE));
  sc->olookup = (indexType *) vmMalloc((unsigned) sc->size * sizeof(indexType));
  sc->oidlookup = (indexType *) vmMalloc((unsigned) sc->size * sizeof(indexType));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].value = (Object)JNIL;
    sc->table[i].ochain = i + 1;
    sc->olookup[i] = 0;
    sc->oidlookup[i] = 0;
  }
  sc->table[0].ochain = sc->table[0].oidchain = 0;
  sc->free = 1;
  CHECKOUTHASHTABLE(sc);
  return sc;
}

OTable OTableCreate(void)
{
  return OTableCreateN(2);
}

void OTableDestroy(OTable sc)
{
  vmFree((char *)sc->table);
  vmFree((char *)sc->olookup);
  vmFree((char *)sc->oidlookup);
  vmFree((char *)sc);
}

/*
 * Insert the key, value pair in sc.  Neither the key nor the value may exist.
 */
static void IOTableInsert(OTable sc, OID a, Object value)
{
  register int index;
  register OTableTEPtr ne;
  register indexType ohash, oidhash;

  assert(!ISNIL(value));
  if (sc->count >= sc->size - 1) ExpandHashTable(sc);

  index = sc->free;
  assert(index);
  ne = &sc->table[index];
  sc->free = ne->ochain;
  ne->key = a;
  ne->value = value;

  ohash = ObjectHash(value, sc);
  oidhash = OIDHash(a, sc);
  ne->ochain = sc->olookup[ohash];
  sc->olookup[ohash] = index;
  ne->oidchain = sc->oidlookup[oidhash];
  sc->oidlookup[oidhash] = index;
  sc->count++;
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(OTable sc)
{
  register OTable newsc;
  register OTableTE *oe, *limit;

  newsc = OTableCreateN(sc->size+1);
  limit = &sc->table[sc->size];
  for (oe = &sc->table[0]; oe < limit; oe++) {
    if (ISNIL(oe->value)) continue;
    IOTableInsert(newsc, oe->key, oe->value);
  }
  vmFree((char *)sc->table);
  *sc = *newsc;
  vmFree((char *)newsc);
  CHECKOUTHASHTABLE(sc);
}

/* Return the value associated with key in collection sc, or JNIL */
static OTableTEPtr LookupByOID(OTable sc, OID a)
{
  register int index = OIDHash(a, sc);
  register OTableTEPtr e;

  CHECKOUTHASHTABLE(sc);
  index = sc->oidlookup[index];
  while (index) {
    e = &sc->table[index];
    if (sameOID(e->key, a)) {
      return e;
    } else {
      index = e->oidchain;
    }
  }
  return 0;
}

Object OTableLookupByOID(OTable sc, OID a)
{
  OTableTEPtr e = LookupByOID(sc, a);
  return (e ? (e->value) : ((Object)JNIL));
}
  

static OTableTEPtr LookupByObject(OTable sc, Object a)
{
  register int index = ObjectHash(a, sc);
  register OTableTEPtr e;

  CHECKOUTHASHTABLE(sc);
  index = sc->olookup[index];
  while (index) {
    e = &sc->table[index];
    if (e->value == a) {
      return e;
    } else {
      index = e->ochain;
    }
  }
  return 0;
}

/* Return the oid associated with object in collection sc, or nooid */
OID OTableLookupByObject(OTable sc, Object a)
{
  OTableTEPtr e = LookupByObject(sc, a);
  return (e ? (e->key) : (nooid));
}
  
void OTableInsert(OTable sc, OID a, Object value)
{
  IOTableInsert(sc, a, value);
  CHECKOUTHASHTABLE(sc);
}

/* Remove the entry, if it is there */
static void RemoveFromOIDChain(OTable sc, OID a, Object o)
{
  int index = OIDHash(a, sc);
  indexType *prev;
  OTableTEPtr e;

  prev = &sc->oidlookup[index];
  index = *prev;
  while (index) {
    e = &sc->table[index];
    if (e->value == o) {
      *prev = e->oidchain;
      return;
    } else {
      prev = &e->oidchain;
      index = e->oidchain;
    }
  }
  assert(0);
}

/* Remove the entry, if it is there */
static OTableTEPtr RemoveFromOChain(OTable sc, Object o)
{
  int index = ObjectHash(o, sc);
  indexType *prev;
  OTableTEPtr e;

  prev = &sc->olookup[index];
  index = *prev;
  while (index) {
    e = &sc->table[index];
    if (e->value == o) {
      *prev = e->ochain;
      return e;
    } else {
      prev = &e->ochain;
      index = e->ochain;
    }
  }
  assert(0);
  return 0;
}

static void Delete(OTable sc, OTableTEPtr e)
{
  assert(e);
  RemoveFromOIDChain(sc, e->key, e->value);
  (void)RemoveFromOChain(sc, e->value);
  e->value = (Object)JNIL;
  e->key = nooid;
  e->ochain = sc->free;
  e->oidchain = 0;
  sc->free = e - sc->table;
  sc->count --;
}

void OTableDeleteByOID(OTable sc, OID a)
{
  Object value;
  OTableTEPtr e = LookupByOID(sc, a);
  if (!e) {
    TRACE(oid, 2, ("Can't delete object %#x from otable", a));
    return;
  }
  value = e->value;
  Delete(sc, e);
}

void OTableDeleteByObject(OTable sc, Object a)
{
  OID oid;
  OTableTEPtr e = LookupByObject(sc, a);
  if (!e) {
    TRACE(oid, 2, ("Can't delete object %#x from otable", a));
    return;
  }
  oid = e->key;
  Delete(sc, e);
}

void OTableUpdateValue(OTable sc, Object oldv, Object newv)
{
  indexType ohash;
  OTableTEPtr e = RemoveFromOChain(sc, oldv);
  e->value = newv;
  ohash = ObjectHash(newv, sc);
  e->ochain = sc->olookup[ohash];
  sc->olookup[ohash] = e - sc->table;
}

/* DEBUGGING: Print the sc */
#define PrintOID(o) printf("%08x.%04x.%04x.%08x", \
			   o.ipaddress, o.port, o.epoch, o.Seq)

void OTablePrint(OTable sc)
{
  int index;
  register OTableTEPtr e;

  printf("Dump of sc @ 0x%05x, %d entr%s\n", 
	 (int)sc, sc->count, sc->count == 1 ? "y" : "ies");
  printf("Index\tKey\t\t\t\t\tValue   oidchain  objchain\n");
  for (index = 0; index < sc->size; index++) {
    e = &sc->table[index];
    if (isNoOID(e->key) && ISNIL(e->value)) continue;
    printf("%3d\t", index);
    PrintOID(e->key);
    printf("\t%08x    %d       %d\n", (unsigned int)e->value, e->oidchain, e->ochain);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
void CheckOutHashTable(OTable sc)
{
  register int i;
  register OTableTEPtr e;
  register int count;
  int problemFound = 0;
  count = 0;

  for (i = 0; i < sc->size; i++) {
    e = &sc->table[i];
    if (ISNIL(e->value)) continue;
    count++;
    if (OTableLookupByOID(sc, e->key) != e->value) {
      problemFound ++;
      fprintf(stderr, "Sc problem: Can't find (");
      PrintOID(e->key);
      fprintf(stderr, ") -> %#x\n", (unsigned int)e->value);
      fprintf(stderr, "  Hashes to index %d\n", OIDHash(e->key, sc));
    }
    if (!sameOID(OTableLookupByObject(sc, e->value), e->key)) {
      problemFound ++;
      fprintf(stderr, "Sc problem: Can't find (%#x) -> ", (unsigned int)e->value);
      PrintOID(e->key);
      fprintf(stderr, "\n");
      fprintf(stderr, "  Hashes to index %d\n", ObjectHash(e->value, sc));
    }
  }  
  if (count != sc->count) {
    fprintf(stderr, "Sc problem: Should have %d entries, but found %d.\n", 
	    sc->count, count);
    problemFound ++;
  }
  if (problemFound) {
    OTablePrint(sc);
    abort();
  }
}
#endif
