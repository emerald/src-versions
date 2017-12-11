/* 
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

#define E_NEEDS_NTOH
#include "system.h"

#include "globals.h"
#include "jvisc.h"
#include "assert.h"

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

extern unsigned vecintHash(String);

#define Hash(key, sc) (HASH(key) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc) 
#endif

/* Return a new, empty JVISc */
JVISc JVIScCreate(void)
{
  register int i;
  register JVISc sc;

  sc = (JVISc) vmMalloc(sizeof(JVIScRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (JVIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(JVIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = NULL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void JVIScDestroy(JVISc sc)
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(JVISc sc)
{
  register JVIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register DomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (JVIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(JVIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = NULL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == NULL) continue;
    index = Hash(key, sc);
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

/* Return the value associated with key in collection sc, or -1 */
RangeType JVIScLookup(JVISc sc, DomainType  key)
{
  register int index = Hash(key, sc);
  register JVIScTEPtr e;

  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {               /* we did not find it */
      return -1;
    } else if (COMPARE(e->key, key)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void JVIScInsert(JVISc sc,  DomainType key, RangeType value)
{
  register int index;
  register JVIScTEPtr e;

  if (sc->count >= sc->maxCount) ExpandHashTable(sc);
  index = Hash(key, sc);
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
void JVIScDelete(JVISc sc, DomainType key)
{
  register int index = Hash(key, sc);
  register RangeType value;
  register JVIScTEPtr e;

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
	JVIScInsert(sc, key, value);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
void JVIScPrint(JVISc sc)
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
    printf("%3d\t%08x 0x%08x\n", index, (int)key, value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(sc)
register JVISc sc;
{
  register int i;
  register JVIScTEPtr realElement, e;
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
	JVIScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    JVIScPrint(sc);
  }
}
#endif
/* Vector hashing function, from Red Dragon Book */

unsigned vecintHash(String keyp)
{
  register unsigned char *key = keyp->d.data;
  register unsigned h = 0, g;
  int len, i;
  if (HOSTED(keyp)) {
    len = keyp->d.items;
  } else {
    len = ntohl(keyp->d.items);
  }
  for (i=0; i<len; i++, key++) {
    h =  (h << 4) + (*key);
    if ((g = h & 0xf0000000)) {
      h = h ^ (g >> 24);
      h = h ^ g;
    }
  }
  return h;
}

/*
 * vector comparison routine.  ASSUMES
 * (a) vectors have same firstthing
 * (b) vectors have same length
 * These are done outside the call in order to avoid procedure calls most times
 */
int veccmp(v1,v2)
Vector v1, v2;
{
  register int i,len = ntohl(v1->d.items), diff;
  register unsigned char *s1 = v1->d.data, *s2 = v2->d.data;
  if ((unsigned)len != ntohl(v2->d.items))
    return len - ntohl(v2->d.items);
  for(i=0; i<len; i++)
    if ((diff = *s1++ - *s2++)) return diff;
  return 0;
}
