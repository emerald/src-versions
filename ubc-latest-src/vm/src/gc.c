/*
 * The Emerald garbage collector - a generational copying collector
 *
 * The new generation is divided into two semispaces, but the boundary
 * between them is flexible.  Assume the new space is of size N, normally
 * divided into two N/2 byte semispaces.  We set the boundary based on the
 * number of objects that survived the previous garbage collection.  Suppose
 * that S bytes of objects survived.  Then we know that next time those
 * objects will be promoted into the old generation (if they are still
 * alive), so we can safely allocate half of the remaining space (N-S)/2
 * since at the next collection all of the S bytes of objects that are now
 * of age two will be promoted and the age 1 survivors of the collection are
 * guaranteed to fit into the free (N-S)/2 bytes of free space.
 *
 * The old generation is a single space copying collector, because we can't
 * afford to waste the space of having a semispace completely empty almost
 * all of the time.  However, we want to compact all the live objects into
 * the front of the old generation so that we don't have to deal with a free
 * list for allocation.  However, the concrete type objects that describe
 * the format of all the other objects are stored in the old generation, so
 * no live object can be overwritten until it has been safely copied to a
 * new location and all references to it have been update to the new
 * location.  The first time that this invariant is true is at the end of
 * the collection.  Therefore, we collect in the following manner:
 *
 * 1.  Mark all reachable objects.  At the same time, keep a histogram of
 *     all of the sizes of reachable objects (and their total size).
 * 2.  Find the line (called the boundary) between live objects and dead
 *     objects after the collection.  This process is described in detail in
 *     the header comment to the function findBoundary.
 * 3.  Copy each live object after the boundary into the hole that was found
 *     for it before the boundary.
 * 4.  Fixup all references to moved objects.
 *
 * Note that the presence of a number of data structures in the run time
 * that contain pointers to objects seriously complicates the problem.
 * Every such reference must be considered a root of the garbage
 * collection.  In addition, the presence of the object table
 * (ObjectTable) makes life even worse because
 * every object that has ever been allocated an OID is referenced from these
 * tables, and therefore can't be collected.  We currently handle the object
 * table specially during old generation collection, not marking from the
 * pointers that it holds to replicated or stub objects so that they can be
 * collected locally since the lack of a local reference to these objects
 * means that they are not useful.
 *
 * This collector makes use of a number of functions defined in misc.c, most
 * notably the sizeOf collection and doToExternalRoots.
 *
 * The distributed collector is in distgc.c, and contains yet another copy
 * of a function very much like the three traversal functions that are in
 * this file.  Any time one of these functions is modified, care should be
 * taken that the other similar functions are also modified.
 */

#include "system.h"

#include "types.h"
#include "builtins.h"
#include "globals.h"
#include "gc.h"
#include "assert.h"
#include "trace.h"
#include "iixsc.h"
#include "iisc.h"
#include "squeue.h"
#include "vm_i.h"
#include "move.h"

/*
 * This garbage collector implements both a copying collector for the newest
 * generation as well as a copying, compacting collector in the old
 * generation.  The biggest thing left to do is to allow the size of the old
 * generation to grow as required.  The right way to do this is to create an
 * array of old_start and old_end pointers, and allow the old generation to
 * be broken into multiple segments.  This would require the following
 * changes: 
 *      . nextGen would need to move to the next segment when the segment
 *        boundary was hit
 *      . Whenever we go through the entire old generation we would have to
 *        do it to each segment.
 *      . We would have to also keep track of the end of each segment, to
 *        account for the internal fragmentation at the end, so we don't
 *        expect another object in the little hole that is left.
 *	  Alternatively we could put a little object in the hole, like we 
 *	  already do in the old generation hole filler.  Check out the 
 *	  function recordSize.
 */
 
Object *rem_set;
int remNum;
static word *toSpace, *new_start, *fromSpace, *new_end, *new_lb, *new_ub;
static word *nextGen, *old_start, *old_end;
static int allocatingForward = 1;
int old_size;
static int guaranteeInterGcInterval;
static Object boundary;
int p_old_size = 2 * 1024 * 1024,
    p_guaranteeInterGcInterval = 0, 
    p_bytesPerGeneration = 128 * 1024, 
    p_copyCount = 2;
static int remember_msize;
int stack_top;

static int wordsLeftInThisGeneration, wordsToBePromotedNextGC;
static int wordsPerGeneration;
int bytesPerGeneration, copyCount;
int inhibit_gc;
int move_stack_size = 0;
static int total_gc_time, old_gc_time;
static int nGCs, nOGCs;
int nDGCs, nDGCremoved;


static word *survivors_start, *survivors_end;

static inline int ageOf(Object o)
{
  return (survivors_start <= (word *)o && (word *)o < survivors_end) + 1;
}
 
static inline int moved(Object o)
{
  return o->flags & 1;
}

static inline Object forwardingPtr(Object o)
{
  return (Object)(o->flags & ~1);
}

static inline void forward(Object o, Object new)
{
  OID oid;
  TRACE(memory, 5, ("Forwarding %#x to %#x", o, new));
  new->flags = o->flags;
  o->flags = (unsigned int)new | 1;
  oid = OIDOf(o);
  if ((HASOID(new->flags) && 1) != !isNoOID(oid)) {
    TRACE(memory, 0, ("Object %#x has oid %s, HASOID == %s", o, OIDString(oid),
		      HASOID(new->flags) ? "true" : "false"));
    if (isNoOID(oid)) {
      CLEARHASOID(new->flags);
    } else {
      SETHASOID(new->flags);
    }
  }
  if (HASOID(new->flags)) UpdateObjectLocation(o, new);
}

extern int sizeOf (Object o), sizeOfX(Object o, Object new, ConcreteType ct);

inline int in_old (Object p)
{
  return (word *)p >= old_start && (word *)p < old_end;
}

/*
 * The definition of this function is critical to the correct operation of
 * the garbage collector, because we have to be able to tell the difference
 * between objects in the from and to half of new space when copying.  
 *
 * In normal operation (during allocation) this function is set to say that
 * anything in the new region is considered new, but during copying, we set
 * it up so that only things in the fromSpace are considered new, as objects
 * that have already been copied to toSpace can (indeed, must) be ignored.
 *
 * Check out the setting of new_lb and new_ub in swap and in synchBounds.
 */
inline int in_new (Object p)
{
  return ((word *)p >= new_start) && ((word *)p < new_end);
}

inline int in_from (Object p)
{
  return ((word *)p >= new_lb) && ((word *)p < new_ub);
}

Object get_new_addr_in_new (int psize)
{
  word *new_addr;

  if (allocatingForward) {
    toSpace -= psize;
    new_addr = toSpace;
    assert(toSpace >= fromSpace);
  } else {
    new_addr = toSpace;
    toSpace += psize;
    assert(toSpace <= fromSpace);
  }
  return (Object) new_addr;
}

Object get_new_addr_in_old (int psize)
{
  word *new_addr;

  new_addr = nextGen;
  nextGen += psize;
#ifdef GCPARANOID
  if (nextGen > old_end) {
    TRACE(memory, 0, ("nextGen overflow botch"));
    abort();
  }
#endif
  return (Object) new_addr;
}

void gc_stats (int *tg, int *og, int *n, int *no, int *nd, int *ndr)
{
  *tg = total_gc_time;
  *og = old_gc_time;
  *n = nGCs;
  *no = nOGCs;
  *nd = nDGCs;
  *ndr = nDGCremoved;
}

#ifndef NDEBUG
static void checkOut(word *from, word *to)
{
  Object o;
  for (o = (Object) from;
       (word *)o < to;
       o = (Object) ((word *)o + sizeOf(o))) {
    ConcreteType ct = CODEPTR(o->flags);
    TRACE(memory, 9, ("0x%08x is a %s%.*s with size %d", (int)o, 
	   !RESDNT(o->flags) ? "Stub " : "",
	   ct->d.name->d.items, (char *)ct->d.name->d.data, sizeOf(o)));
  }
}
#else
#  define checkOut(a, b)
#endif

static inline int liveWords(void)
{
  return allocatingForward ? fromSpace - new_start : new_end - fromSpace;
}

static inline void nilOut(word *from, word *to)
{
#ifdef GCPARANOID
  while (from < to) *from++ = (word)JNIL;
#endif
}

static void swap (void)
{
  fromSpace = toSpace;
  new_lb = new_start;
  new_ub = new_end;

  if (allocatingForward) {
    toSpace = new_start;
    nilOut(toSpace, fromSpace);
    survivors_start = fromSpace;
    survivors_end = new_end;
  } else {
    toSpace = new_end;
    nilOut(fromSpace, toSpace);
    survivors_start = new_start;
    survivors_end = fromSpace;
  }
  IFTRACE(memory, 9) {
    if (allocatingForward) {
      checkOut(fromSpace, new_end);
    } else {
      checkOut(new_start, fromSpace);
    }
  }
  allocatingForward = !allocatingForward;
}

static void synchBounds (void)
{
  if (allocatingForward) {
    new_lb = new_start;
    new_ub = fromSpace;
  } else {
    new_lb = fromSpace;
    new_ub = new_end;
  }
  IFTRACE(memory, 9) checkOut(new_lb, new_ub);
}

void push_ms (Object p)
{
  if (stack_top >= move_stack_size) {
    int new_move_stack_size;
    Object *new_move_stack;
    if (move_stack_size == 0) {
      new_move_stack_size = INITIAL_MOVE_STACK_SIZE;
      new_move_stack = (Object *)vmMalloc(new_move_stack_size * sizeof(Object));
    } else {
      new_move_stack_size = move_stack_size + INITIAL_MOVE_STACK_SIZE;
      new_move_stack = (Object *)vmRealloc((char *)move_stack, new_move_stack_size * sizeof(Object));
    }
    TRACE(memory, 3, ("Growing move_stack from %d to %d words", 
	   move_stack_size, new_move_stack_size));
    if (new_move_stack == NULL) {
      TRACE(memory, 0, ("Move stack overflow!"));
      exit(1);
    } else {
      move_stack_size = new_move_stack_size;
      move_stack = new_move_stack;
    }
  }
  move_stack[stack_top++] = p;
}

/*  Records objects that may have pointers pointing to objects in new */
/*  generation */

void new_rem_set (Object elem)
{
  if (!REMSET(elem->flags)) {
    if (remNum >= remember_msize) {
      remember_msize += REM_INCR;
      rem_set = rem_set ? 
	(Object *) vmRealloc (rem_set, remember_msize * sizeof (word)) :
	(Object *) vmMalloc (remember_msize * sizeof (word));
      assert(rem_set);
    }
    rem_set[remNum++] = elem;
    SETREMSET(elem->flags); 
  }
}

Object checkAndFindNew_new(Object p)
{
  if (ISNIL(p)) return p;
  if (in_from(p)) {
    if (moved(p)) {
      TRACE(memory, 8, ("The %.*s at 0x%08x has moved to 0x%08x", 
			CODEPTR(forwardingPtr(p)->flags)->d.name->d.items,
			CODEPTR(forwardingPtr(p)->flags)->d.name->d.data,
			p, forwardingPtr(p)));
      return forwardingPtr(p);
    } else {
      int promotion = ageOf(p) >= copyCount;
      int size = sizeOf(p);
      Object newplace = promotion ?
	(Object) get_new_addr_in_old(size): 
	(Object) get_new_addr_in_new(size);
      /*
       * Book-keeping - count the number of words that are guaranteed to be
       * promoted next time.
       */
      if (ageOf(p) == copyCount - 1) {
	wordsToBePromotedNextGC += size;
      }

      TRACE(memory, 8, ("New Forwarding 0x%08x to 0x%08x, a %.*s", p, newplace,
			CODEPTR(p->flags)->d.name->d.items,
			CODEPTR(p->flags)->d.name->d.data));
      forward(p, newplace);
      push_ms(p);
      return newplace;
    }
  } else if (wasGCMalloced(p)) {
    TRACE(memory, 10, ("The %.*s at 0x%08x is old", 
		       CODEPTR(p->flags)->d.name->d.items,
		       CODEPTR(p->flags)->d.name->d.data,
		       p));
    return p;
  } else {
    TRACE(memory, 10, ("The thing at 0x%08x was not gcmalloced"));
    return p;
  }
}

int varContainsPointer(ConcreteType ct)
{
  return !ISNIL(ct) && HASODP(ct->d.instanceFlags);
}

/**************************************************************************
 * move_fields copies p into another address pointed by new_addr          
 * This assumes:
 *      new_p has had its age and flags field set (which means that we can
 *          use it to find the concrete type).
 *      p can be either the old object, now a forwarding pointer, or the
 *          real object 
 *
 * move_fields returns true (1) if the object contains any objects that get
 * moved and are still in the new generation.
 *************************************************************************/
static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}

int move_fields (Object p, Object new_p, Object (*checkAndFindNew)(Object))
{
  word *p_ptr, *n_ptr;
  Template temp;
  char *brands;
  char c;
  int count;
  int star;
  ConcreteType ct, nct;
  Object old, new;
  int answer = 0;

  p_ptr = (word *)p + 1;
  n_ptr = (word *)new_p + 1;

  ct = CODEPTR(new_p->flags);
  nct = (ConcreteType) checkAndFindNew((Object)ct);
  if (nct != ct && in_new((Object)nct)) answer = 1;
  SETCODEPTR(new_p->flags, nct);

  if (!RESDNT(new_p->flags)) {
    /*
     * This is a stub, so all we need to do is copy the pointer to the remote 
     * location (which is not garbage collectable).  A stub has 
     * a firstThing and a pointer in the next field, and must be maintained.
     */
    TRACE(memory, 5, ("Moving the fields of %#x, a stub for a %.*s to %#x",
		      p, ct->d.name->d.items, ct->d.name->d.data, new_p));
    ((Object *)new_p)[1] = ((Object *)p)[1];
    /*
     * If the object is a vector, and it is not zero length, then we have to
     * copy its size, too.
     */
    if (ct->d.instanceSize < 0 && !VZEROL(p->flags)) {
      ((Object *)new_p)[2] = ((Object *)p)[2];
    }
    return answer;
  }
  temp = ct->d.template;
  TRACE(memory, 7, ("Moving the fields of %#x, a %.*s to %#x",
		    p, ct->d.name->d.items, ct->d.name->d.data, new_p));
  /* nothing following the first thing of object p */
  if (ISNIL(temp)) return answer;

  brands = (char *) temp->d.data;
  while (1) {
    switch (*brands++) {
    case '%':
      count = 0;
      star = 0;
      while (misdigit (c = *brands++)) {
	count = count * 10 + c - '0';
      }
      if (!count) count = 1;
      if (c == '*') {
	*n_ptr++ = count = *p_ptr++;
	star = 1;
	c = *brands++;
      }
      switch (c) {
      case 'm':
	while (count--) {
	  *n_ptr++ = *p_ptr++;
	  *n_ptr++ = *p_ptr++;
	}
	break;
      case 'x':
      case 'X':
	while (count--) {
	  old = (Object) *p_ptr++;
	  new = checkAndFindNew(old);
	  *n_ptr++ = (word)new;
	  if (old != new && in_new(new)) answer = 1;
	}
	break;
      case 'v':
      case 'V':
	while (count--) {
#ifdef USEABCONS
	  AbCon abcon = (AbCon)p_ptr[1];
	  ct = ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
#else
	  ct = (ConcreteType) p_ptr[1];
#endif
	  if (varContainsPointer(ct)) {
	    old = (Object) *p_ptr++;
	    new = checkAndFindNew(old);
	    assert(ISNIL(new) || CODEPTR(new->flags) == ct ||
		   (moved((Object)ct) && CODEPTR(new->flags) == (ConcreteType)forwardingPtr((Object)ct)));
	    *n_ptr++ = (word)new;
	    if (old != new && in_new(new)) answer = 1;
	  } else {
	    *n_ptr++ = *p_ptr++;
	  }
#ifdef USEABCONS
	  *n_ptr++ = (word)abcon;
#else
	  nct = (ConcreteType)checkAndFindNew((Object)ct);
	  *n_ptr++ = (word)nct;
	  if (ct != nct && in_new((Object)nct)) answer = 1;
#endif
	  p_ptr++;
	}
	break;
      case 'l':
      case 'L':
	count /= 4;
	TRACE(memory, 5, ("Literals at %#x, now %#x", p, new_p));
	while (count --) {
	  *n_ptr++ = *p_ptr++;
	  *n_ptr++ = *p_ptr++;
	  *n_ptr++ = *p_ptr++;
	  old = (Object) *p_ptr++;
	  new = checkAndFindNew(old);
	  *n_ptr++ = (word)new;
	  TRACE(memory, 6, ("Literal: %#x -> %#x", old, new));
	  if (old != new && in_new(new)) answer = 1;
	}
	break;
      case 'q':
	TRACE(memory, 5, ("An squeue in a condition at %#x, now %#x", p, new_p));
	assert(count == 1);
	*n_ptr++ = *p_ptr++;
	break;
      case 'd':
      case 'D':
      case 'f':
      case 'F':
	while (count--) {
	  *n_ptr++ = *p_ptr++;
	}
	break;
      case 'c':
      case 'C':
      case 'b':
      case 'B':
	if (star) count = (count + 3) / 4;
	while (count--) {
	  *n_ptr++ = *p_ptr++;
	}
	break;
      default:
	TRACE(memory, 0, ("cannot figure out brand"));
	break;
      }
      break;
    case '\0':
      return answer;
    default:
      TRACE(memory, 0, ("what is '%c' doing in a template?\n", brands[-1]));
      break;
    }
  }
  return answer;
}

void flushStack(void)
{
  Object p, new_p;

  while (stack_top != 0) {
    p = move_stack[--stack_top];
    assert(moved(p));
    new_p = forwardingPtr(p);
    if (move_fields (p, new_p, checkAndFindNew_new) && ageOf(p) >= copyCount) {
      new_rem_set(new_p);
    }
  }
}

void move_variable(Object *p_ptr, ConcreteType *ct_ptr)
{
  ConcreteType ct;
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)*ct_ptr;
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
  ct = *ct_ptr;
#endif
  if (varContainsPointer(ct)) {
    *p_ptr = checkAndFindNew_new(*p_ptr);
  }
  assert (!in_new ((Object)ct));
  flushStack();
}

/* move_variables moves the variables between p and (p + count) */
void move_variables (int count, word *p_ptr)
{
  ConcreteType ct;
  while (count--) {
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)p_ptr[1];
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
    ct = (ConcreteType) p_ptr[1];
#endif
    if (varContainsPointer(ct)) {
      *p_ptr = (word)checkAndFindNew_new((Object) *p_ptr);
    }
    assert (!in_new ((Object)ct));
    p_ptr += 2;
  }
  flushStack();
}

/* move_pointers moves the pointers between p and (p + count) */
void move_pointers (int count, Object *p_ptr)
{
  while (count-- > 0) {
    *p_ptr = checkAndFindNew_new(*p_ptr);
  }
  flushStack();
}

/*
 * Move all the objects in the object p.
 *
 * This function returns (Object)-1 if the object p contains no objects
 * which reside in the new generation, and p otherwise.
 */
Object tl_move (Object p, Object (*checkAndFindNew)(Object))
{
  word *p_ptr;
  Template temp;
  char *brands, c;
  int count, star;
  ConcreteType ct, nct;
  Object old, new, answer = (Object) -1;

  p_ptr = (word *)p + 1;
  ct = CODEPTR(p->flags);
  nct = (ConcreteType) checkAndFindNew((Object)ct);
  temp = ct->d.template;
  if (nct != ct) SETCODEPTR(p->flags, nct);

  TRACE(memory, 7, ("Top level move of %#x, a %.*s",
		    p, ct->d.name->d.items, ct->d.name->d.data));

  if (!RESDNT(p->flags)) {
    /*
     * This is a stub.  A stub has a firstThing and a pointer in the
     * next field, and must be maintained.
     */
    /* Do nothing, as the pointer in field 1 cannot be to the heap */
    TRACE(memory, 8, ("It is a stub"));
    goto done;
  }

  /* nothing following the first thing of object p */
  if (ISNIL(temp)) goto done;

  brands = (char *) temp->d.data;
  while (1) {
    switch (*brands++) {
    case '%':
      count = 0;
      star = 0;
      while (misdigit (c = *brands++)) {
	count = count * 10 + c - '0';
      }
      if (!count) count = 1;
      if (c == '*') {
	count = *p_ptr++;
	star = 1;
	c = *brands++;
      }
      switch (c) {
      case 'm':
	p_ptr += count * 2;
	break;
      case 'x':
      case 'X':
	while (count--) {
	  old = (Object) *p_ptr;
	  new = checkAndFindNew(old);
	  if (old != new) {
	    answer = p;
	    *p_ptr = (word)new;
	  }
	  p_ptr++;
	}
	break;
      case 'v':
      case 'V':
	while (count--) {
#ifdef USEABCONS
	  AbCon abcon = (AbCon)p_ptr[1];
	  ct = ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
#else
	  ct = (ConcreteType) p_ptr[1];
#endif
	  if (varContainsPointer(ct)) {
	    old = (Object) *p_ptr;
	    new = checkAndFindNew(old);
	    assert(ISNIL(new) || CODEPTR(new->flags) == ct ||
		   (moved((Object)ct) && CODEPTR(new->flags) == (ConcreteType)forwardingPtr((Object)ct)));
	    if (old != new) {
	      answer = p;
	      *p_ptr = (word)new;
	    }
	  }
	  p_ptr++;
#ifdef USEABCONS
	  p_ptr++;
#else
	  nct = (ConcreteType)checkAndFindNew((Object) ct);
	  *p_ptr++ = (word)nct;
#endif
	}
	break;
      case 'l':
      case 'L':
	count /= 4;
	TRACE(memory, 5, ("Literals at %#x", p));
	while (count--) {
	  p_ptr += 3;
	  old = (Object) *p_ptr;
	  new = checkAndFindNew(old);
	  if (old != new) {
	    answer = p;
	    *p_ptr = (word)new;
	  }
	  TRACE(memory, 6, ("Literal: %#x -> %#x", old, new));
	  p_ptr++;
	}
	break;
      case 'q':
	assert(count == 1);
	{
	  Object st;
	  TRACE(memory, 5, ("Updating squeue of condition at %#x", p));
	  assert(count == 1);
	  SQueueForEach((SQueue)*p_ptr, st) {
	    old = st;
	    new = checkAndFindNew(old);
	    if (old != new) {
	      ((SQueue)*p_ptr)->table[SQueuexx_index] = (struct State *)new;
	      answer = p;
	    }
	  } SQueueNext();
	  p_ptr ++;
	}
	break;
      case 'd':
      case 'D':
      case 'f':
      case 'F':
	p_ptr += count;
	break;
      case 'c':
      case 'C':
      case 'b':
      case 'B':
	if (star) count = (count + 3) / 4;
	p_ptr += count;
	break;
      default:
	TRACE(memory, 0, ("cannot figure out brand"));
	break;
      }
      break;
    case '\0':
      goto done;
    default:
      TRACE(memory, 0, ("what is '%c' doing in a template?", brands[-1]));
      break;
    }
  }
done:
  flushStack();
  return answer;
}

void moveFromRoots1 (void)
{
  int limit = remNum, i;
  Object o, new_o;

  TRACE(memory, 5, ("Checking the remembered set"));
  for (i = 0; i < limit; i++) {
    o = rem_set[i];
    TRACE(memory, 7, ("Doing the %.*s at 0x%08x", 
		      CODEPTR(o->flags)->d.name->d.items,
		      CODEPTR(o->flags)->d.name->d.data,
		      o));
    new_o = tl_move (o, checkAndFindNew_new);
    if (new_o == (Object)-1) {
      CLEARREMSET((o)->flags);
      rem_set[i] = new_o;
    } else {
      assert(new_o == o);
    }
  }
}

static void (*_gc_b) (void), (*_gc_d) (void), (*_gc_a) (void), (*_gc_e) (void);

extern void doToExternalRoots(void (*pointers_f)(int, Object *), 
			      void (*variable_f)(Object *, ConcreteType *),
			      void (*varibles_f)(int, word *),
			      int destructive,
			      int doFromObjectTable);

void ch_rem_set (void)
{
  int i, j = 0;

  for (i = 0; i < remNum; i++) {
    if (rem_set[i] != (Object) -1) {
      rem_set[j++] = rem_set[i];
    }
  }
  remNum = j;
}

static int total_stores, total_interesting_stores;
extern void gcollect_old(void);

static int needDistGC(void)
{
  /*
   * Think about starting a distGC if the fraction of free space is small
   * (how small?) and the number of objects with OIDs is large (how
   * large?).  The current settings of these two parameters is entirely a
   * guess.
   */
#define DISTGCPERCENTTHRESHOLD 25
#define DISTGCGLOBALOBJECTTHRESHOLD 10000
  if (!inDistGC()) {
    int freepercent = (old_end - nextGen) * 100 / (old_end - old_start);
    if (freepercent < DISTGCPERCENTTHRESHOLD) {
      TRACE(distgc, 2, ("Starting distgc, free memory = %d", freepercent));
      return 1;
    } else if (OTableSize(ObjectTable) > DISTGCGLOBALOBJECTTHRESHOLD) {
      TRACE(distgc, 2, ("Starting distgc, objects with oids = %d",
			OTableSize(ObjectTable)));
      return 1;
    }
  }
  return 0;
}    

void gcollect(void)
{
  int start_time;
  int done_time;

  assert(!inhibit_gc);
  nGCs++;
  TRACE(memory, 2, ("Starting garbage collection #%d, remsetsize = %d", 
		    nGCs, remNum));
  IFTRACE(memory, 7) {
    showAllProcesses(0, 1);
  }

  start_time = currentCpuTime();

  wordsToBePromotedNextGC = 0;
  synchBounds();
  if (_gc_b) _gc_b();

  /* Move objects in the remember set which records the objects that may 
     have pointers to objects in new generation - note that the
     pointers in this set are all in the old generation */

  moveFromRoots1();
  ch_rem_set();
  doToExternalRoots(move_pointers, move_variable, move_variables, 1, 1);
  swap();

  wordsLeftInThisGeneration = 
    guaranteeInterGcInterval ? 
      bytesPerGeneration / sizeof(word) :
      (new_end - new_start + wordsToBePromotedNextGC) / (copyCount == 1?1:2)
	- liveWords();

  if (copyCount == 1) {
    assert(wordsToBePromotedNextGC == 0);
    assert(liveWords() == 0);
    assert(wordsLeftInThisGeneration == new_end - new_start);
    wordsToBePromotedNextGC = wordsLeftInThisGeneration;
  }
  if (old_end - nextGen <  wordsToBePromotedNextGC) {
    gcollect_old();
  }

  done_time = currentCpuTime();
  total_gc_time += (done_time - start_time);

  TRACE(memory, 3, ("Old = %d words, new = %d words, promo = %d words", 
		    ((unsigned int)nextGen - (unsigned int)old_start) / sizeof(int),
		    (allocatingForward ? 
		     (unsigned int)fromSpace - (unsigned int)new_start :
		     (unsigned int)new_end - (unsigned int)fromSpace) / sizeof(int),
		    wordsToBePromotedNextGC));
  TRACE(memory, 4, ("Total stores so far = %d, %d interesting", 
		    total_stores, total_interesting_stores));
  if  (old_end - nextGen < wordsToBePromotedNextGC) {
    TRACE(memory, 0, ("old_end = %#x, next_gen = %#x, diff = %d, promo = %d\n",
		      old_end, nextGen, old_end - nextGen,
		      wordsToBePromotedNextGC));
    fprintf(stderr, "Out of memory.  Try including the flag -O%dk on the command line!\n", old_size/1024 + 256);
    abort();
  }

  fflush(stdout);
}

void stoCheck (Object intoObj, Object storedObj)
{
  total_stores++;
  if ((in_old (intoObj)) && (in_new (storedObj))) {
    total_interesting_stores ++;
    new_rem_set (intoObj);
  }
}

void anticipateGC(int bytes)
{
  if (!inhibit_gc) {
    if (old_end - nextGen - wordsToBePromotedNextGC < BYTES_TO_WORDS(bytes))
      gcollect();

    /*
     * Since the call to gcollect can sometimes call gcollect_old, then we
     * only need to call it again if it is really necessary.
     */
    if (old_end - nextGen - wordsToBePromotedNextGC < BYTES_TO_WORDS(bytes))
      gcollect_old();
  }
  inhibit_gc++;
}

void ensureSpace(int bytes)
{
  assert(!inhibit_gc);
  while (wordsLeftInThisGeneration * 4 < bytes) {
    gcollect();
  }

  if (old_end - nextGen - wordsToBePromotedNextGC < BYTES_TO_WORDS(bytes))
    gcollect();

  /*
   * Since the call to gcollect can sometimes call gcollect_old, then we
   * only need to call it again if it is really necessary.
   */
  if (old_end - nextGen - wordsToBePromotedNextGC < BYTES_TO_WORDS(bytes))
    gcollect_old();
}

/* allocate lb bytes of data in the old generation */
void *gc_malloc_old (int lb, int remember)
{
  register word *op, *lp;
  register int lw;

  lw = BYTES_TO_WORDS (lb + sizeof(word) - 1);

  if (old_end - nextGen - wordsToBePromotedNextGC < lw) {
    if (inhibit_gc) {
      TRACE(memory, 0, ("old_end = %#x, next_gen = %#x, diff = %d, promo = %d\n",
			old_end, nextGen, old_end - nextGen,
			wordsToBePromotedNextGC));
      fprintf(stderr, "Out of memory.  Try including the flag -O%dk on the command line!\n", old_size/1024 + 256);
      abort();
    } else {
      gcollect();
      gcollect_old();
      if (old_end - nextGen -wordsToBePromotedNextGC < lw) {
	TRACE(memory, 0, ("old_end = %#x, next_gen = %#x, diff = %d, promo = %d\n",
			  old_end, nextGen, old_end - nextGen,
			  wordsToBePromotedNextGC));
	fprintf(stderr, "Out of memory.  Try including the flag -O%dk on the command line!\n", old_size/1024 + 256);
	abort();
      }
    }
  }
  op = nextGen;
  nextGen += lw;

  lp = op + lw;
  while (--lp > op) *lp = JNIL;
  *op = 0;
  TRACE(memory, 10, ("Allocate old %d bytes returns %x", lb, op));

  if (remember) new_rem_set((Object)op);
  return op;
}

/* allocate lb bytes of data in the new generation */
void *gc_malloc(int lb)
{
  register word *op, *lp;
  register int lw;

  lw = BYTES_TO_WORDS (lb + (sizeof (word)) - 1);

  if (inhibit_gc || lw > wordsPerGeneration) return gc_malloc_old (lb, 0);

  while (wordsLeftInThisGeneration < lw) {
    gcollect();
  }
  wordsLeftInThisGeneration -= lw;

  if (allocatingForward) {
    op = fromSpace;
    fromSpace += lw;
  } else {
    fromSpace -= lw;
    op = fromSpace;
  }

  lp = op + lw;
  while (--lp > op) *lp = JNIL;
  *op = 0;
  TRACE(memory, 10, ("Allocate %d bytes returns %x", lb, op));
  return op;
}

int inHeap(unsigned int x)
{
    return ((old_start <= (word *)x && (word *)x < old_end) ||
	    (new_lb <= (word *)x && (word *)x < new_ub));
}

void gc_init (void (*b)(void), void (*d)(void), void (*a)(void), void (*e)(void))
{
  _gc_b = b;
  _gc_d = d;
  _gc_a = a;
  _gc_e = e;

  if (fromSpace == NULL) {
    int nbytes;
    copyCount = p_copyCount;
    bytesPerGeneration = p_bytesPerGeneration;
    old_size = p_old_size;
    guaranteeInterGcInterval = p_guaranteeInterGcInterval;
    if (copyCount > 2) {
      fprintf(stderr, "Copy counts of > 2 are not supported: %d\n", copyCount);
      copyCount = 2;
    }
    nbytes = copyCount * (copyCount == 1?1:2) * bytesPerGeneration;

    fromSpace = new_start = (word *) vmMalloc (nbytes);
    toSpace = new_end = &fromSpace[nbytes / sizeof(word)];
    nextGen = old_start = (word *) vmMalloc (old_size);
    old_end = old_start + (old_size / sizeof(word));
    new_lb = new_start;
    new_ub = new_end;
    codeptrextra = (unsigned int)old_start & ALLBITS;
      
    wordsPerGeneration = bytesPerGeneration / sizeof(word);
    wordsLeftInThisGeneration = 
      guaranteeInterGcInterval ? 
	bytesPerGeneration / sizeof(word) :
	(new_end - new_start + wordsToBePromotedNextGC) / (copyCount==1?1:2)
	  - liveWords();
	TRACE(memory, 1, ("old = [%#x - %#x], new = [%#x - %#x]",
					  old_start, old_end, new_start, new_end));
  }
}


/*
 * Here is the garbage collector for the old generation.  We need to call
 * this when, after completion of a regular collection the number of bytes
 * available in the old generation is less than generationSize.  Upon
 * completion of collecting the old generation, the number of bytes
 * available there must be at least generationSize, or we have run out of
 * space. 
 *
 * The old generation collector is a two phase process.  First we mark all
 * of the objects that are accessible from the roots, which are:
 *      the new generation
 *      the external roots
 *
 * Then we go through the old generation and compact everything into the
 * first chunk of the storage that is available for the old generation.  This
 * is somewhat tricky:
 *      Concrete types are in the old generation, and we can't invalidate
 *          them or risk being very confused.
 *      We will be moving objects, but can't create the stub new object
 *          until we know where all the accessible objects are.
 *
 * So, we will not overwrite existing live objects.  Instead, we will fill
 * in the holes between existing live objects near the front of the old
 * generation space with live objects from near the end of that space.  The
 * trick is to find the boundary.
 */

void clearRememberedBits(void)
{
  Object *rem_start, *rem_end, *root_pointer, o;

  rem_start = &rem_set[0];
  rem_end = &rem_set[remNum];
  TRACE(memory, 5, ("Clearing the remembered set"));
  for (root_pointer = rem_start; root_pointer != rem_end; root_pointer++) {
    o = *root_pointer;
    CLEARREMSET(o->flags);
  }
}

void setRememberedBits(void)
{
  Object *rem_start, *rem_end, *root_pointer, o;

  rem_start = &rem_set[0];
  rem_end = &rem_set[remNum];
  TRACE(memory, 5, ("Reestablishing the remembered set"));
  for (root_pointer = rem_start; root_pointer != rem_end; root_pointer++) {
    o = *root_pointer;
    if (o < boundary) {
      SETREMSET(o->flags);
    } else if (moved(o)) {
      *root_pointer = forwardingPtr(o);
      SETREMSET((*root_pointer)->flags);
    } else {
      assert(0);
    }
  }
}

static IIXSc liveSizes;
static IIXSc freeLists;
static int  liveObjectsLeft;
static int  wordsNeeded, wordsWasted;

#define marked(o) (REMSET(o->flags))
#define setMark(o) (SETREMSET(o->flags))
#define clearMark(o) (CLEARREMSET(o->flags))

void purgeObjectTable(void)
{
  OID oid;
  Object o;
  int purged = 0, statespurged = 0;
  OTableForEach(ObjectTable, oid, o) {
    if (!wasGCMalloced(o)) {
      if (marked(o)) {
	/*
	 * This is a state we are still using somewhere.
	 */
      } else {
	/*
	 * We need to find a way to clean up these states.
	 */
	if (RESDNT(o->flags)) {
	  TRACE(memory, 0, ("Why is there an unmarked local state %#x?", o));
	} else {
	  TRACE(memory, 5, ("Purged state %s -> %#x", OIDString(oid), o));
	  OIDRemove(oid, o);
	  statespurged ++;
	  vmFree((char *)o);
	}
      }
    } else if (in_old(o) && !marked(o)) {
      TRACE(memory, 5, ("GC removing OID %s from %#x a %s %.*s", OIDString(oid),
			o,
			RESDNT(o->flags) ? "resident" : "remote",
			CODEPTR(o->flags)->d.name->d.items,
			CODEPTR(o->flags)->d.name->d.data));
      OIDRemove(oid, o);
      purged ++;
    } else {
      TRACE(memory, 5, ("Didn't purge object %s -> %#x, flags %#x", OIDString(oid), o, o->flags));
    }
  } OTableNext();
  TRACE(memory, 3, ("Purged %d objects, %d states, leaving %d OT roots",
		      purged, statespurged, OTableSize(ObjectTable)));
}

#ifndef NDEBUG
void   checkOutObjectTable(void)
{
  OID oid;
  Object o;
  int count = 0;

  OTableForEach(ObjectTable, oid, o) {
    if ((word *)boundary <= (word *)o && (word *)o < old_end) {
      TRACE(memory, 0, ("An object in the vacated oidtoobjecttable has an oid"));
      TRACE(memory, 0, ("OID = %s, o = %#x", OIDString(oid), (unsigned int) o));
      count ++;
    }
  } OTableNext();
  if (count) abort();
}
#endif

void purgeRememberedSet(void)
{
  Object *rem_start, *rem_end, *root_pointer, o;

  rem_start = &rem_set[0];
  rem_end = &rem_set[remNum];
  TRACE(memory, 5, ("Reestablishing the remembered set, pass 1"));
  for (root_pointer = rem_start; root_pointer != rem_end; root_pointer++) {
    o = *root_pointer;
    if (!marked(o)) {
      *root_pointer = (Object) -1;
    }
  }
  ch_rem_set();
}

void mark(Object p)
{
  if (ISNIL(p) || marked(p)) {
    /* do nothing */
  } else {
    TRACE(memory, 9, ("Marking %x", p));
    if (!wasGCMalloced(p)) {
      setMark(p);
    } else if (in_old(p)) {
      setMark(p);
      wordsNeeded += sizeOf(p);
      IIXScBump(liveSizes, sizeOf(p));
      liveObjectsLeft ++;
      push_ms(p);
    }
  }
}

void mark_fields(Object p);

void flushMarkStack(void)
{
  Object p;

  while (stack_top != 0) {
    p = move_stack[--stack_top];
    assert(marked(p));
    mark_fields(p);
  }
}
  
void markAnSQueue(SQueue s)
{
  Object st;
  SQueueForEach(s, st) {
    mark(st);
  } SQueueNext();
}

void mark_fields(Object p)
{
  word *p_ptr;
  Template temp;
  char *brands, c;
  int count, star;
  ConcreteType ct;
  Object old;

  p_ptr = (word *)p + 1;
  ct = CODEPTR(p->flags);
  mark((Object)ct);
  temp = ct->d.template;

  /* nothing following the first thing of object p */
  if (ISNIL(temp)) return;

  if (!RESDNT(p->flags)) {
    /*
     * This is a stub, so we don't need to do anything.
     */
    TRACE(memory, 5, ("Marking the fields of %#x, a stub for a %.*s",
		      p, ct->d.name->d.items, ct->d.name->d.data));
    return;
  }

  brands = (char *) temp->d.data;
  while (1) {
    switch (*brands++) {
    case '%':
      count = 0;
      star = 0;
      while (misdigit (c = *brands++)) {
	count = count * 10 + c - '0';
      }
      if (!count) count = 1;
      if (c == '*') {
	count = *p_ptr++;
	star = 1;
	c = *brands++;
      }
      switch (c) {
      case 'm':
	markAnSQueue(((monitor *)p_ptr)->waiting);
	p_ptr += count * 2;
	break;
      case 'x':
      case 'X':
	while (count--) {
	  old = (Object) *p_ptr;
	  mark(old);
	  p_ptr++;
	}
	break;
      case 'v':
      case 'V':
	while (count--) {
#ifdef USEABCONS
	  AbCon abcon = (AbCon)p_ptr[1];
	  ct = ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
#else
	  ct = (ConcreteType) p_ptr[1];
#endif
	  if (varContainsPointer(ct)) {
	    old = (Object) *p_ptr;
	    assert(ISNIL(old) || CODEPTR(old->flags) == ct);
	    mark(old);
	  }
	  mark((Object)ct);
	  p_ptr += 2;
	}
	break;
      case 'l':
      case 'L':
	TRACE(memory, 5, ("Marking literals at %#x", p));
	count /= 4;
	while (count --) {
	  p_ptr += 3;
	  old = (Object) *p_ptr;
	  mark(old);
	  TRACE(memory, 6, ("Literal: %#x", old));
	  p_ptr++;
	}
	break;
      case 'q':
	{
	  TRACE(memory, 5, ("Marking squeue of condition at %#x", p));
	  assert(count == 1);
	  markAnSQueue((SQueue)*p_ptr);
	  p_ptr ++;
	}
	break;
      case 'd':
      case 'D':
      case 'f':
      case 'F':
	p_ptr += count;
	break;
      case 'c':
      case 'C':
      case 'b':
      case 'B':
	if (star) count = (count + 3) / 4;
	p_ptr += count;
	break;
      default:
	TRACE(memory, 0, ("cannot figure out brand"));
	break;
      }
      break;
    case '\0':
      return;
    default:
      TRACE(memory, 0, ("what is '%c' doing in a template?", brands[-1]));
      break;
    }
  }
}

void doToNewGeneration(void (*f)(Object), void (*cleanup)(void))
{
  Object o, lasto = 0, lastlasto = 0;
  word *from, *to;

  if (allocatingForward) {
    from = new_start;
    to =   fromSpace;
  } else {
    from = fromSpace;
    to   = new_end;
  }

  for (o = (Object) (from);
       (word *)o < to;
       o = (Object) ((word *)o + sizeOf(o))) {
    f(o);
    if (cleanup) cleanup();
    lastlasto = lasto;
    lasto = o;
  }
}

void mark_variable(Object *p_ptr, ConcreteType *ct_ptr)
{
  ConcreteType ct;
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)*ct_ptr;
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
  ct = *ct_ptr;
#endif

  if (varContainsPointer(ct)) {
    mark(*p_ptr);
  }
  mark((Object) ct);
  flushMarkStack();
}

void mark_variables(int count, word *p_ptr)
{
  ConcreteType ct;
  while (count--) {
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)p_ptr[1];
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
    ct = (ConcreteType) p_ptr[1];
#endif
    if (varContainsPointer(ct)) {
      mark((Object) *p_ptr);
    }
    mark((Object) ct);
    p_ptr += 2;
  }
  flushMarkStack();
}

void mark_pointers(int count, Object *p_ptr)
{
  while (count-- > 0) {
    mark(*p_ptr);
  }
  flushMarkStack();
}

void recordSize(Object o, int size)
{
  o->flags = RESDNTBIT;
  if (size == 1) {
    SETCODEPTR(o->flags, BuiltinInstCT(ANYI));
  } else {
    SETCODEPTR(o->flags, BuiltinInstCT(VECTOROFINTI));
    ((Vector)o)->d.items = size - 2;
  }
}

#ifdef CHECK_GC_VERY_CAREFULLY
markAsOnFreeList(Object hole, int size)
{
  int i;
  word *ptr, value;
  
  ptr = (word *)hole + 1;
  value = (word)hole | (size << 22 | 0x40000000);
  for (i = 0; i < size - 2; i++) 
    ptr[i] = value;
}
  
checkAsOnFreeList(Object hole, int size)
{
  int i;
  word *ptr, value;
  
  ptr = (word *)hole + 1;
  value = (word)hole | (size << 22 | 0x40000000);
  for (i = 0; i < size - 2; i++) 
    assert(ptr[i] == value);
}
  
markHoleEmpty(Object hole)
{
  int i, size;
  word *ptr, value;
  
  size = *((word *)hole - 1);
  ptr = (word *)hole + 1;
  value = (word)hole | (size << 22 | 0x80000000);
  for (i = 0; i < size - 2; i++) 
    ptr[i] = value;
}

checkOutHole(Object hole)
{
  int i, size;
  word *ptr, value;
  
  size = *((word *)hole - 1);
  ptr = (word *)hole + 1;
  value = (word)hole | (size << 22 | 0x80000000);
  for (i = 0; i < size - 2; i++) 
    assert(ptr[i] == value);
}
static int freeListLength(Object o)
{
  int count = 0;

  while (!IIXScIsNIL(o)) {
    count ++;
    o = (Object)o->flags;
  }
  return count;
}

static void isEmptyFreeList(int size, int value, void *a)
{
  assert(freeListLength((Object)value) == 0);
}

static void isEmptySize(int size, int value, void *a)
{
  return value == 0;
}

void checkThingsOut(void)
{
  IIXScMap(freeLists, isEmptyFreeList, 0);
  IIXScMap(liveSizes, isEmptySize, 0);
}

void checkOutLiveSizes(void)
{
  IIXScMap(liveSizes, isEmptySize, 0);
}
#define markAsOnFreeList(X, Y) markAsOnFreeList(X, Y)
#define checkAsOnFreeList(X, Y) checkAsOnFreeList(X, Y)
#define markHoleEmpty(X) markHoleEmpty(X)
#define checkOutHole(X) checkOutHole(X)
#define checkThingsOut() checkThingsOut()
#define checkOutLiveSizes() checkOutLiveSizes()
#else
#define markAsOnFreeList(X, Y) 
#define checkAsOnFreeList(X, Y) 
#define markHoleEmpty(X) 
#define checkOutHole(X) 
#define checkThingsOut()
#define checkOutLiveSizes()
#endif

void fillUp(Object *freeChunkp, int *sizep)
{
  int try, success = 1;
  Object freeChunk = *freeChunkp;
  int size = *sizep;
  Object rest;
  while (size > 0 && success) {
    success = 0;
    try = IIXScSelectSmaller(liveSizes, size);
    if (try > 0) {
      assert(try <= size);
      rest = (Object)((word *)freeChunk + try);
      markAsOnFreeList(freeChunk, try);
      freeChunk->flags = (Bits32)IIXScLookup(freeLists, try);
      IIXScInsert(freeLists, try, (int)freeChunk);
      liveObjectsLeft--;
      size -= try;
      freeChunk = rest;
      success = 1;
    }
  }
  if (size > 0) {
    TRACE(memory, 7, ("Wasting %d words at 0x%x", size, freeChunk));
    wordsWasted += size;
    /* Fix the CT of the leftover thing */
    recordSize(freeChunk, size);
  }
  *freeChunkp = freeChunk;
  *sizep = size;
}

static Object boundary;

Object checkAndFindNew_old(Object o)
{
  Object new;
  if (in_old(o)) {
    if (o < boundary) {
      new = o;
    } else if (moved(o)) {
      new = forwardingPtr(o);
    } else {
      int size = sizeOf(o);
      new = (Object)IIXScLookup(freeLists, size);
      assert(!IIXScIsNIL(new));
      IIXScInsert(freeLists, size, new->flags);
      forward(o, new);
    }
  } else {
    new = o;
  }
  return new;
}

/*
 * Find the boundary which will be the end of the old generation after
 * compaction.  The characterization of this boundary is that there are
 * sufficient holes of the right sizes before the boundary that we can find
 * places for all of the live objects after the boundary.
 *
 * After a lot of trial and error, and even a little bit of thoughtful
 * design, Jim Thornton and I (Norm) came up with the following strategy:
 *      a.  During the mark phase, keep track of the total number of live
 *          objects, their total size, as well as the distribution of their
 *          sizes.
 *      b.  Set an initial guess for the boundary, which is just the start
 *          of the space plus the number of live bytes.
 *      c.  Sweep though memory up to this initial guess, coalescing all the
 *          free space into holes, and putting each free chunk on a list
 *          (linked by the flags field of the object), with the size of the
 *          free space stored in the age field of the object.  In addition,
 *          for each live object encountered, decrement the number of live
 *          objects as well as subtracting about this objects contribution
 *          to the size distribution.
 *      d.  Upon reaching the initial guess, go through the list of free
 *          chunks, and allocate them to the live objects that have not yet
 *          been reached by the sweep.  As a new home is found for each live
 *          object, adjust the size distribution and decrement the number of
 *          live objects left.  The allocation strategy is documented in the
 *          function fillUp, and is best fit.
 *      e.  Continue the sweep until the number of live objects reaches 0.
 *          For each hole encountered, immediately attempt to allocate it to
 *          the live objects as yet unallocated.  For each live object
 *          encountered, attempt to adjust the size distribution.  If
 *          decrementing the count for this size of objects results in a
 *          number < 0, then we have one too many free chunks on the free
 *          lists for objects of this size, so pick one off the free list
 *          and attempt to fill it up with other objects.  Once this is
 *          done, decrement the count of live objects left.
 *
 * When the number of live objects reaches 0, we have found the appropriate
 * stopping point.  At this point the free list contains an entry for every
 * live object that we have not yet encountered on the sweep.  
 */
void findBoundary(void)
{
  Object o, hole = 0, guess, holes = 0, lasto;
#if !defined(NDEBUG)
  Object to = (Object)nextGen;
#endif
  int holeSize = 0, size, left;
#define RECORDHOLESIZE(hole, size) IIScInsert(holeSizes, (int)hole, size)
#define GETHOLESIZE(hole) IIScLookup(holeSizes, (int)hole)
#define FORGETHOLESIZE(hole) 
  IISc holeSizes = IIScCreate();

  /*
   * Set the initial guess - step b.
   */
  guess = (Object)(old_start + wordsNeeded);
  
  /*
   * Step c.
   */
  for (o = (Object) old_start; o < guess; o = (Object) ((word *)o+size)) {
    assert(o < to);
    size = sizeOf(o);
    TRACE(memory, 5, ("%#x a %s %d word %.*s", o, 
		      marked(o) ? "live" : "dead", size,
		      CODEPTR(o->flags)->d.name->d.items,
		      CODEPTR(o->flags)->d.name->d.data));
    if (marked(o)) {
      if (hole) {
	TRACE(memory, 7, ("Found a hole of size %d at %x",
			  holeSize, hole));
	RECORDHOLESIZE(hole, holeSize);
	hole->flags = (Bits32)holes;
	markHoleEmpty(hole);
	holes = hole;
	hole = 0;
	holeSize = 0;
      }
      left = IIXScBumpBy(liveSizes, size, -1);
      assert(left >= 0);
      liveObjectsLeft--;
    } else {
      if (!hole) hole = o;
      holeSize += size;
    }
    lasto = o;
  }
  /*
   * Step d.
   */
  IIXScCompact(liveSizes);
  if (hole) {
    hole->flags = 0;
    markHoleEmpty(hole);
    fillUp(&hole, &holeSize);
  }
  while (holes) {
    hole = holes;
    holes = (Object)hole->flags;
    checkOutHole(hole);
    holeSize = GETHOLESIZE(hole);
    FORGETHOLESIZE(hole);
    fillUp(&hole, &holeSize);
  }
  IIScDestroy(holeSizes);

  TRACE(memory, 3, ("First guess at boundary is 0x%x", (word *)o));
  /*
   * Step e.
   */
  hole = 0;
  holeSize = 0;
  for ( ; liveObjectsLeft > 0; o = (Object) ((word *)o + size)) {
    assert(o < to);
    size = sizeOf(o);
    TRACE(memory, 5, ("%#x a %s %d word %.*s", o, 
		      marked(o) ? "live" : "dead", size,
		      CODEPTR(o->flags)->d.name->d.items,
		      CODEPTR(o->flags)->d.name->d.data));
    if (marked(o)) {
      if (hole) {
	TRACE(memory, 5, ("Found a hole of size %d at 0x%x to 0x%x",
			  holeSize, (word *)hole, 
			  (word *)hole + holeSize));
	fillUp(&hole, &holeSize);
	/* Check to see if you can free the rest of the hole */
	if (liveObjectsLeft == 0 && (word *)hole + holeSize == (word *)o) {
	  TRACE(memory, 3, ("Resetting the boundary to 0x%x", 
			    (word *)hole));
	  wordsWasted -= holeSize;
	  o = hole;
	  break;
	}
	hole = 0;
	holeSize = 0;
      }
      if (IIXScBumpBy(liveSizes, size, -1) < 0) {
	Object freeChunk = (Object)IIXScLookup(freeLists, size);
	int tSize = size;
	assert(!IIXScIsNIL(freeChunk));
	TRACE(memory, 9, ("Re-allocating a free chunk of size %d at 0x%x",
			  size, freeChunk));
	IIXScInsert(freeLists, size, freeChunk->flags);
	IIXScBump(liveSizes, size);
	checkAsOnFreeList(freeChunk, size);
	fillUp(&freeChunk, &tSize);
      } else {
	liveObjectsLeft--;
      }
    } else {
      if (!hole) hole = o;
      holeSize += size;
    }
    lasto = o;
  }
  /*
   * Found the boundary
   */
  boundary = o;
  TRACE(memory, 3, ("Found the boundary at 0x%x",
		    (word *)boundary));
  TRACE(memory, 3, ("Old space was 0x%x - 0x%x, %d words", old_start, nextGen,
		    nextGen - old_start));
  TRACE(memory, 3, ("Words needed = %d", wordsNeeded));
  TRACE(memory, 3, ("Words wasted = %d", wordsWasted));
  TRACE(memory, 3, ("Words reclaimed = %d, of %d possible", 
		    nextGen - ((word *)o),
		    (nextGen - old_start) - wordsNeeded));
}

/* 
 * Finish the sweep.  We merely have to move each live object into one of the
 * holes that was pre-reserved for objects of its size.
 */
void moveThemPuppies(void)
{
  Object o, new, to = (Object)nextGen, lasto;
  int size;

  for (o = boundary; o < to; o = (Object) ((word *)o + size)) {
    if (moved(o)) {
      /* just move the fields */
      new = forwardingPtr(o);
      size = sizeOfX(o, new, CODEPTR(new->flags));
      TRACE(memory, 5, ("Moving the fields of 0x%x to 0x%x", o, new));
      checkAsOnFreeList(new, size);
      (void)move_fields(o, new, checkAndFindNew_old);
      clearMark(new);
    } else {
      size = sizeOf(o);
      if (marked(o)) {
	new = (Object)IIXScLookup(freeLists, size);
	assert(!IIXScIsNIL(new));
	TRACE(memory, 5, ("Finding a new location for 0x%x at 0x%x", o, new));
	IIXScInsert(freeLists, size, new->flags);
	checkAsOnFreeList(new, size);
	forward(o, new);
	TRACE(memory, 5, ("Moving the fields of 0x%x to 0x%x", o, new));
	(void)move_fields(o, new, checkAndFindNew_old);
	clearMark(new);
      } else {
	TRACE(memory, 9, ("Object at 0x%x is not reachable", o));
	/* do nothing, the object isn't reachable */
      }
    }
    lasto = o;
  }
  TRACE(memory, 4, ("Done moving them puppies"));
}

Object followForwardingOld(Object o)
{
  Object new;
  if (in_old(o)) {
    if (o < boundary) {
      new = o;
    } else {
      assert(moved(o));
      new = forwardingPtr(o);
    }
  } else {
    new = o;
  }
  return new;
}

void forward_old(Object o)
{
  tl_move(o, followForwardingOld);
}

void funky_forward_old(Object o)
{
  if (marked(o)) {
    tl_move(o, followForwardingOld);
    clearMark(o);
  }
}

void oldm_variable (Object *p_ptr, ConcreteType *ct_ptr)
{
  ConcreteType ct;
#ifdef USEABCONS
  {
    AbCon abcon = (AbCon)*ct_ptr;
    ct = ISNIL(abcon) ? (ConcreteType) JNIL : abcon->d.con;
  }
#else
  ct = *ct_ptr;
#endif

  if (varContainsPointer(ct)) {
    *p_ptr = followForwardingOld(*p_ptr);
  }
#ifndef USEABCONS
  *ct_ptr = (ConcreteType)followForwardingOld((Object)ct);
#endif
}

/* move_variables moves the variables between p and (p + count) */
void oldm_variables (int count, word *p_ptr)
{
  ConcreteType ct;
  while (count--) {
    ct = (ConcreteType) p_ptr[1];
    if (varContainsPointer(ct)) {
      *p_ptr = (word)followForwardingOld((Object) *p_ptr);
    }
    p_ptr++;
#ifndef USEABCONS
    *p_ptr = (word)followForwardingOld((Object)ct);
#endif
    p_ptr++;
  }
}

/* move_pointers moves the pointers between p and (p + count) */
void oldm_pointers (int count, Object *p_ptr)
{
  while (count-- > 0) {
    *p_ptr = followForwardingOld(*p_ptr);
    p_ptr++;
  }
}

void doToOldGeneration(void (*f)(Object), word *limit)
{
  Object o, lasto, secondlasto;
  word *from, *to;
  int size;

  from = old_start;
  to = limit ? limit : nextGen;

  for (o = (Object) (from);
       (word *)o < to;
       o = (Object) ((word *)o + (size = sizeOf(o)))) {
    f(o);
    secondlasto = lasto;
    lasto = o;
  }
}

void markCT(Object o)
{
  Object ct = (Object)CODEPTR(o->flags);
  mark_pointers(1, &ct);
}

void gcollect_old(void)
{
  int start_time;
  int done_time;
 
  nOGCs++;
  TRACE(memory, 2, ("Starting old garbage collection #%d", nOGCs));
  start_time = currentCpuTime();

  liveObjectsLeft = 0;
  wordsNeeded = 0;
  wordsWasted = 0;
  liveSizes = IIXScCreate();
  freeLists = IIXScCreate();
  checkThingsOut();
  clearRememberedBits();

  /*
   * We have to hang on to even all cts mentioned by objects both alive and dead.
   */
  doToOldGeneration(markCT, 0);

  doToNewGeneration(mark_fields, flushMarkStack);
  doToExternalRoots(mark_pointers, mark_variable, mark_variables, 0, 1);

  purgeObjectTable();
  purgeRememberedSet();
  findBoundary();
  checkOutLiveSizes();
  
  moveThemPuppies();
  checkThingsOut();
  doToNewGeneration(forward_old, 0);
  doToExternalRoots(oldm_pointers, oldm_variable, oldm_variables, 1, 1);
#ifndef NDEBUG
  checkOutObjectTable();
#endif
  doToOldGeneration(funky_forward_old, (word *)boundary);
  setRememberedBits();
  nextGen = (word *)boundary;
  nilOut(nextGen, old_end);
  IIXScDestroy(liveSizes);
  IIXScDestroy(freeLists);
  done_time = currentCpuTime();
  old_gc_time += (done_time - start_time);
  if (needDistGC()) {
    startDistGC();
  }
}

void becomeStub(Object o, ConcreteType ct, void *stub)
{
  extern void forgetIsFixedHere(Object o);
  int sizeofo = sizeOfX(o, o, ct);
  assert(sizeofo >= 2);
  if (ct->d.instanceSize < 0) {
    /* This is a vector, so we have to remember it's size */
    setVectorSize(o, sizeofo);
    TRACE(rinvoke, 9, ("Vector %x became a stub of %d words", o, sizeofo));
  }
  freeze(o, RRemote);
  CLEARRESDNT(o->flags);
  forgetIsFixedHere(o);
  *((Object *)(o) + 1) = (Object)stub;
}

Object createStub(ConcreteType ct, void *stub, OID oid)
{
  Object o;
  regRoot(ct);
  if (ct->d.instanceSize >= 0) {
    o = (Object)gc_malloc(sizeofObject + ct->d.instanceSize);
  } else {
    o = (Object)gc_malloc(sizeofObject + 4);
    setVectorSize(o, 2);
    TRACE(rinvoke, 0, ("Created a stub for a vector with the wrong size"));
  }
  unregRoot();
  SETCODEPTR(o->flags, ct);
  OIDInsert(oid, o);
  if (inDistGC()) {
    SETDISTGC(o->flags);
    newGrey(o);
  }
  freeze(o, RRemote);

  *(void **)o->d = stub; 
  return o;
}

int wasGCMalloced(void *paddr)
{
  word *addr = paddr;
  return (old_start <= addr && addr < old_end) ||
    (new_start <= addr && addr < new_end);
}
