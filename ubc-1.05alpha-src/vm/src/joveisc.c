/* comment me!
 */

#define E_NEEDS_NTOH
#include "system.h"

#include "assert.h"
#include "joveisc.h"
#include "array.h"
#include "iisc.h"

extern unsigned vecintHash(String);
extern int veccmp(Vector, Vector);

static void ExpandHashTable(register JOVEISc sc, array obA);

static inline int *INDEX2OBJ(long x, array obA)
{
  int ans = ASUB(obA, ntohl(x));
  extern IISc translateMap;
  if (ISNIL(ans)) {
    ans = IIScLookup(translateMap, ntohl(x));
    if (ans == -1) ans = JNIL;
  }
  return (int *)ans;
}
#define JSTRCMP(A,B) (((A)==(B)) || (!ISNIL(A) && !ISNIL(B) && \
  !veccmp((Vector)INDEX2OBJ((int)A, obA), (Vector)INDEX2OBJ((int)B, obA))))
#define JOVECOMPARE(A, B) (\
  (A->d.id == B->d.id) && \
  (A->d.nargs == B->d.nargs) && \
  (A->d.nress == B->d.nress) && \
  JSTRCMP(A->d.name,B->d.name) && \
  JSTRCMP(A->d.template,B->d.template) && \
  JSTRCMP(A->d.code,B->d.code) \
)

static unsigned oveintHash(OpVectorElement, array);
/*
 * Searchable Collections:
 *
 * Expanding hash tables with a key and data.
 */

static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };
#define MAXFILL(x) (((x) * 17 ) / 20)

/*
 * Turning this on will cause the package to self-check on every (modifying)
 * operation.  The package runs very slowly when this is enabled.
 */
#undef DEBUGSC

extern unsigned vecintHash(String);

#define Hash(key, sc, obA) (JOVEHASH(key, obA) % sc->size)

#ifdef DEBUGSC
static void CheckOutHashTable();
#define CHECKOUTHASHTABLE(sc) CheckOutHashTable(sc)
#else
#define CHECKOUTHASHTABLE(sc) 
#endif

/* Return a new, empty JOVEISc */
JOVEISc JOVEIScCreate(void)
{
  register int i;
  register JOVEISc sc;

  sc = (JOVEISc) vmMalloc(sizeof(JOVEIScRecord));
  sc->size = sizes[0];
  sc->maxCount = MAXFILL(sc->size);
  sc->count = 0;
  sc->table = (JOVEIScTEPtr) vmMalloc((unsigned) sc->size * sizeof(JOVEIScTE));
  for (i = 0; i < sc->size; i++) {
    sc->table[i].key = NULL;
  }
  CHECKOUTHASHTABLE(sc);
  return sc;
}

void JOVEIScDestroy(register JOVEISc sc)
{
  vmFree((char *)sc->table);
  vmFree((char *)sc);
}

/* Expand the hash table.  Each element in the table is re-hashed and entered 
 * in the new table. */
static void ExpandHashTable(register JOVEISc sc, array obA)
{
  register JOVEIScTE *nh, *oe, *ne;
  register int oldHashTableSize = sc->size, i;
  register JOVEISCDomainType key;
  int index;

  for (i = 0; sizes[i] <= oldHashTableSize; i++) ;
  sc->size = sizes[i];
  sc->maxCount = MAXFILL(sc->size);
  nh = (JOVEIScTEPtr) vmMalloc((unsigned)(sc->size * sizeof(JOVEIScTE)));
  for (i = 0; i < sc->size; i++) nh[i].key = NULL;
  for (i = 0; i < oldHashTableSize; i++) {
    oe = &sc->table[i];
    key = oe->key;
    if (key == NULL) continue;
    index = Hash((unsigned char *)key, sc, obA);
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
JOVEISCRangeType JOVEIScLookup(register JOVEISc sc, 
			       register JOVEISCDomainType key,
			       array obA)
{
  register int index = Hash(key, sc, obA);
  register JOVEIScTEPtr e;
  CHECKOUTHASHTABLE(sc);
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {               /* we did not find it */
      return -1;
    } else if (JOVECOMPARE(e->key, key)) {
      return e->value;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Insert the key, value pair in sc.  If the key already exists, change its 
 * value. */
void JOVEIScInsert(register JOVEISc sc, register JOVEISCDomainType key,
		   JOVEISCRangeType value, array obA)
{
  register int index;
  register JOVEIScTEPtr e;
  if (sc->count >= sc->maxCount) ExpandHashTable(sc, obA);
  index = Hash(key, sc, obA);
  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {               /* put it here */
      e->key = key;
      e->value = value;
      sc->count++;
      CHECKOUTHASHTABLE(sc);
      return;
    } else if (JOVECOMPARE(e->key, key)) {
      e->value = value;
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (++index >= sc->size) index = 0;
  }
}

/* Remove the entry, if it is there */
void JOVEIScDelete(register JOVEISc sc, register JOVEISCDomainType key,
		   array obA)
{
  register int index = Hash((unsigned char *)key, sc, obA);
  register JOVEISCRangeType value;
  register JOVEIScTEPtr e;

  while (1) {
    e = &sc->table[index];
    if (e->key == NULL) {               /* we did not find it */
      CHECKOUTHASHTABLE(sc);
      return;
    }
    if (JOVECOMPARE(e->key, key)) {
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
	JOVEIScInsert(sc, key, value, obA);
      }
    }
    if (++index >= sc->size) index = 0;
  }
}

/* DEBUGGING: Print the sc */
void JOVEIScPrint(register JOVEISc sc)
{
  JOVEISCDomainType key;
  JOVEISCRangeType value;
  int index;

  printf(
    "\nDump of sc @ 0x%05x, %d entr%s, current max %d\nIndex\tKey\t\tValue\n",
    (int)sc, sc->count, sc->count == 1 ? "y" : "ies",  sc->maxCount);
  for (index = 0; index < sc->size; index++) {
    key = sc->table[index].key;
    value = sc->table[index].value;
    printf("%3d\t%08x0x%08x\n", index, (unsigned int)key, value);
  }
}

#ifdef DEBUGSC
/* Make sure that the hash table is internally consistent:
 *      every key is findable, 
 *      count reflects the number of elements
 */
static void CheckOutHashTable(register JOVEISc sc)
{
  register int i;
  register JOVEIScTEPtr realElement, e;
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
	} else if (JOVECOMPARE(e->key, realElement->key)) {
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
      
      if (index == -1 || !JOVECOMPARE(e->key, realElement->key)) {
	/* FIX THIS */
	fprintf(stderr,
	  "Sc problem: Key %s, rightIndex %d, realIndex %d value 0x%x\n",
	  realElement->key, firstIndex, index, realElement->value);
	JOVEIScPrint(sc);
      }
    }
  }  
  if (count != sc->count) {
    fprintf(stderr,
      "Sc problem: Should have %d entries, but found %d.\n", sc->count,
      count);
    JOVEIScPrint(sc);
  }
}
#endif
/* Vector hashing function, from Red Dragon Book */

static unsigned oveintHash(OpVectorElement keyp, array obA)
{
  return vecintHash((String)INDEX2OBJ((int)keyp->d.code, obA));
}
