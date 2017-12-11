/*
 * miscellaneous Jekyllries
 */

#define E_NEEDS_FILE
#define E_NEEDS_STAT
#define E_NEEDS_STRING
#define E_NEEDS_NTOH
#include "system.h"

#include "vm_exp.h"
#include "iset.h"
#include "iisc.h"
#include "ooisc.h"
#include "oisc.h"
#include "trace.h"
#include "types.h"
#include "misc.h"
#include "assert.h"
#include "gaggle.h"
#include "locate.h"

typedef int (*ccallFunction)();

typedef struct CCallDescriptor {
  ccallFunction ccFunction;
  char* ccName;
  char* ccArgTemplate;
} CCallDescriptor;

#include "globals.h"
#include "read.h"

#define OPOIDTABLESIZE 101

extern void die(void);

int	stackSize = STACKSIZE;
void   *extraRoots[10];
int     extraRootsSP;
static char *OpNames = NULL;
static char **OpIDsToNames;

extern int debug(State *, char *);

#undef isalnum
#undef isxdigit
#undef isdigit
#undef isspace
#undef islower

static int isalnum(int c)
{
  return (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') ||
	  ('A' <= c && c <= 'Z'));
}

static int isxdigit(int c)
{
  return (('0' <= c && c <= '9') || ('a' <= c && c <= 'f') ||
	  ('A' <= c && c <= 'F'));
}

static int isdigit(int c)
{
  return ('0' <= c && c <= '9');
}

static int islower(int c)
{
  return ('a' <= c && c <= 'z');
}

static int isspace(int c)
{
  return (c == ' ' || c == '\t' || c == '\n' || c == '\r');
}

#define DIGIT(x)	(isdigit(x) ? (x) - '0' : \
			islower(x) ? (x) + 10 - 'a' : (x) + 10 - 'A')
#define MBASE	('z' - 'a' + 1 + 10)

int mstrtol(const char *str, char **ptr, int base)
{
	register int val;
	register int c;
	int xx, neg = 0;

	if (ptr != (char **)0)
		*ptr = (char *)str; /* in case no number is formed */
	if (base < 0 || base > MBASE)
		return (0); /* base is invalid -- should be a fatal error */
	if (!isalnum(c = *str)) {
		while (isspace(c))
			c = *++str;
		switch (c) {
		case '-':
			neg++;
		case '+': /* fall-through */
			c = *++str;
		}
	}
	if (base == 0) {
		if (c != '0')
			base = 10;
		else if (str[1] == 'x' || str[1] == 'X')
			base = 16;
		else
			base = 8;
	}
	/*
	 * for any base > 10, the digits incrementally following
	 *	9 are assumed to be "abc...z" or "ABC...Z"
	 */
	if (!isalnum(c) || (xx = DIGIT(c)) >= base)
		return (0); /* no number formed */
	if (base == 16 && c == '0' && isxdigit(str[2]) &&
	    (str[1] == 'x' || str[1] == 'X'))
		c = *(str += 2); /* skip over leading "0x" or "0X" */
	for (val = -DIGIT(c); isalnum(c = *++str) && (xx = DIGIT(c)) < base; )
		/* accumulate neg avoids surprises near MAXLONG */
		val = base * val - xx;
	if (ptr != (char **)0)
		*ptr = (char *)str;
	return (neg ? val : -val);
}

static char blanks[] = "                                                  ";
extern int arDepth(u32, u32);

void obsolete(char *name, State *state)
{
  ftrace("Attempt to use obsolete bytecode %s", name);
  debug(state, "Obsolete bytecode");
}

void docall(int op, int sp, int fp, ConcreteType ct, Object oop, int sb)
{
  printf("%.*sCall of %.*s.%s o = %#x, a = <%#x, %#x> sp=%#x\n",
	 2 * arDepth(fp, sb),
	 blanks,
	 ct->d.name->d.items,
	 ct->d.name->d.data,
	 OperationName(op), (Bits32)oop, *(int *)(sp - 8),
	 *(int *)(sp - 4),
	 sp);
}

void docallct(OpVectorElement ove, int sp, int fp, ConcreteType ct, Object oop, int sb)
{
  printf("%.*sCall of %.*s.%.*s o = %#x, a = <%#x, %#x> sp=%#x\n",
	 2 * arDepth(fp, sb),
	 blanks,
	 ct->d.name->d.items,
	 (char *)ct->d.name->d.data,
	 ove->d.name->d.items, (char *)ove->d.name->d.data,
	 (Bits32)oop, *(int *)(sp - 8),
	 *(int *)(sp - 4),
	 sp);
}

void doret(int fp, int sb, int pc, ConcreteType ct)
{
  int opid = -3;
  unsigned char *pcc = (unsigned char *)pc;
  char *name = "";
  int namelen = 99;

  /* Find the opid.  There are 2 call instructions and padding (with ':') so */
  /* we have to do some work here to figure out how we were called. */
  if (pc == -1 || pc == -2) {
    opid = pc;
  } else {
    if (pcc[-3] == CALLOIDS || (pcc[-3] == ':' && pcc[-4] == CALLOIDS)) {
      opid = ((unsigned short *)pc)[-1];
    } else if (pcc[-5] == CALLOID ||
	       (pcc[-5] == ':' && pcc[-6] == CALLOID) ||
	       (pcc[-5] == ':' && pcc[-6] == ':' && pcc[-7] == CALLOID) ||
	       (pcc[-5] == ':' && pcc[-6] == ':' && pcc[-7] == ':' && pcc[-8] == CALLOID)) {
      opid = ((unsigned int *)pc)[-1];
    } else if (pcc[-1] == CALLSTAR) {
      name = ".* invoke";
    } else if (pcc[-2] == CALLCTB) {
      int which = pcc[-1];
      opid = -3;
      name = (char *)ct->d.opVector->d.data[which]->d.name->d.data;
      namelen = ct->d.opVector->d.data[which]->d.name->d.items;
    } else if (pcc[-3] == CALLS || (pcc[-3] == ':' && pcc[-4] == CALLS)) {
      opid = -3;
      name = "some calls"; 
    } else {
      printf("%.*sCan't figure out the call instruction\n", 2 * arDepth(fp, sb), blanks);
      opid = 0;
    }
  }

  printf("%.*sReturn %.*s\n", 2 * arDepth(fp, sb), blanks,
	 opid == -3 ? namelen : 99,
	 opid == -3 ? name : OperationName(opid));
}

#ifdef WIN32
#define stat _stat
#define fstat _fstat
#define read _read
#define open _open
#define close _close
#endif

void OpoidsInit(void)
{
  char OpoidFile[1024];
  char *ReadHead, *root;
  int  fd, i;
  int  NumberOfOps;
  struct stat buf;

  if (OpNames == NULL) { 
    root = getenv("EMERALDROOT");
    if (!root)
      root = EMERALDROOT;
    strcpy(OpoidFile, root);
    strcat(OpoidFile, "/lib/opoid");
    fd = open(OpoidFile, O_RDONLY | O_BINARY, 0);
    if (fstat(fd, &buf) < 0)
      FatalError("OpoidsInit :");
    OpNames = (char *) vmMalloc(buf.st_size + 1);
    read(fd, OpNames, buf.st_size);

    NumberOfOps = 0;
    for (ReadHead = OpNames; ReadHead < OpNames + buf.st_size; ReadHead++) {
      NumberOfOps++;
      while (*ReadHead != '\n' && ReadHead < OpNames + buf.st_size)
	ReadHead++;
      if( ReadHead < OpNames + buf.st_size) *ReadHead = '\0';
    }

    OpIDsToNames = vmCalloc(NumberOfOps, sizeof(char *));
    ReadHead = OpNames;

    for (i = 0; i < NumberOfOps; i++) {
      OpIDsToNames[i] = ReadHead;
      while (*ReadHead)
	ReadHead++;
      ReadHead++;
    }

    close(fd);
  }

  return;
}

char *OperationName(int OpID)
{
  if (OpID == -1) {
    return "initially";
  } else if (OpID == -2) {
    return "process";
  } else if (OpID == -3) {
    return "recovery";
  } else if (OpID < 2000) {
    if (OpNames == NULL) OpoidsInit();
    return OpIDsToNames[OpID];
  } else {
    return "*unknown*";
  }
}

#ifdef PROFILEINVOKES

/*
 *  This stuff is wrong - it uses the pre-merger types.  However, since
 *  Mark didn't change it in his version, I'm leaving it the way it is,
 *  at least for now. - david carlton
 */
typedef struct ProfileEntry {
  unsigned int ncalls;
  unsigned int nrecursivecalls;
  unsigned int nbytecodes;
  unsigned int childbytecodes;
  IISc callers, callees;
  OpVectorElement ove;
  unsigned marked:1;
  unsigned onStack:1;
  unsigned isCycle:1;
  unsigned number:29;
  unsigned lowLink;
  struct ProfileEntry *cycle;
} ProfileEntry;

IISc invokeprofile, /* ove -> ProfileEntry */
  opvectorentry2ct; /* ove -> ct */
unsigned int *currentOPECount;
unsigned int *opestack[800];
int opesp = 0;

void profileBump(pc, ove, ct)
unsigned int pc;
OpVectorElement ove;
ConcreteType ct;
{
  ProfileEntry *p = (ProfileEntry *)IIScLookup(invokeprofile, ove);
  if ((int)p == IIScNIL) {
    p = (ProfileEntry *)vmMalloc(sizeof(ProfileEntry));
    p->marked = p->onStack = p->isCycle = 0;
    p->ncalls = 0;
    p->nrecursivecalls = 0;
    p->nbytecodes = 0;
    p->childbytecodes = 0;
    p->callers = IIScCreate();
    p->callees = IIScCreate();
    p->ove = ove;
    p->cycle = NULL;
    IIScInsert(invokeprofile, (int)ove, (int)p);
    IIScInsert(opvectorentry2ct,(int)ove,(int)ct);
  }
  p->ncalls ++;
  opestack[opesp++] = currentOPECount;
  currentOPECount = &p->nbytecodes;
  IIScBump(p->callers, pc);
}

profileRet()
{
  currentOPECount = opestack[--opesp];
}

ProfileEntry **pes;

static int comparepeaddr(a, b)
ProfileEntry **a, **b;
{
  return (*a)->ove->d.code->d.data - (*b)->ove->d.code->d.data;
}

static int comparepeweight(a, b)
ProfileEntry **a, **b;
{
  return ((*b)->nbytecodes +(*b)->childbytecodes) -
    ((*a)->nbytecodes + (*a)->childbytecodes);
}

static int comparepeself(a, b)
ProfileEntry **a, **b;
{
  return ((*b)->nbytecodes) - ((*a)->nbytecodes);
}

buildCodeVector()
{
  OpVectorElement ove;
  ConcreteType ct;
  int i = 0;

  pes = (ProfileEntry **)
    vmMalloc(IIScSize(opvectorentry2ct) * sizeof(ProfileEntry *) + 30);
  IIScForEach(opvectorentry2ct, ove, ct) {
    pes[i++] = (ProfileEntry *)IIScLookup(invokeprofile, ove);
  } IIScNext();
  qsort(pes, i, sizeof(ProfileEntry *), comparepeaddr);
}

OpVectorElement findCaller(pc)
unsigned char *pc;
{
  int low = 0, hi = IIScSize(opvectorentry2ct), mid;
  OpVectorElement ove;
  while (low < hi) {
    mid = (hi + low) / 2;
    ove = pes[mid]->ove;
    if (pc > ove->d.code->d.data) {
      if (pc <= &ove->d.code->d.data[ove->d.code->d.items]) {
	low = mid;
	break;
      } else {
	low = mid + 1;
      }
    } else {
      hi = mid - 1;
    }
  }
  ove = pes[low]->ove;
  if (ove->d.code->d.data <= pc && pc <= &ove->d.code->d.data[ove->d.code->d.items]) {
    return ove;
  } else {
    return NULL;
  }
}

static void pad(n)
{
  while (n-- > 0) putchar(' ');
}

printove(ove, width)
OpVectorElement ove;
int width;
{
  ConcreteType ct;
  ct = (ConcreteType) IIScLookup(opvectorentry2ct, ove);
  printf("%.*s.%.*s", ct->d.name->d.items, ct->d.name->d.data,
	 width == 0 ? ove->d.name->d.items :
	 max(0, min(width - ct->d.name->d.items - 1, ove->d.name->d.items)), ove->d.name->d.data);
  pad(width - ct->d.name->d.items - ove->d.name->d.items - 1);
}

printpe(p, width)
ProfileEntry *p;
int width;
{
  if (p->isCycle) {
    printf("Cycle %3d", (int)p->ove);
    pad(width - 9);
  } else {
    if (p->cycle != NULL) {
      printf("<%2d> ", p->cycle->ove);
      width -= 5;
    }
    printove(p->ove, width);
  }
}

IISc roots;

buildProfileGraph()
{
  IISc old;
  OpVectorElement e, caller;
  ProfileEntry *p, *callerp;
  unsigned int fromwhere, count, howmany;
  roots = IIScCreate();

  IIScForEach(invokeprofile, e, p) {
    old = p->callers;
    p->callers = IIScCreate();
    IIScForEach(old, fromwhere, howmany) {
      caller = findCaller(fromwhere);
      if (caller != NULL) {
	callerp = (ProfileEntry *)IIScLookup(invokeprofile, caller);
	assert(callerp != (ProfileEntry *)IIScNIL);
	count = IIScLookup(p->callers, callerp);
	if (count == IIScNIL) count = 0;
	if (callerp == p) {
	  p->nrecursivecalls += howmany;
	  p->ncalls -= howmany;
	} else {
	  IIScInsert(p->callers, callerp, howmany + count);
	  IIScInsert(callerp->callees, p, howmany + count);
	}
      }
    } IIScNext();
    IIScDestroy(old);
    if (IIScSize(p->callers) == 0) {
      IIScInsert(roots, p, 1);
    }
  } IIScNext();
}

static int scccount = 0;
static ProfileEntry **sccstack;
static int sccsp;
/* static NodePtr SCComponent = NULL; */

void propagate1(p)
ProfileEntry *p;
{
  ProfileEntry *calleep;
  unsigned int howmany;
  double fraction;
  IIScForEach(p->callees, calleep, howmany) {
    fraction = (double)howmany / (double) calleep->ncalls;
    p->childbytecodes +=
      fraction * (calleep->nbytecodes + calleep->childbytecodes) + 0.5;
    if (calleep->cycle != NULL) {
      fraction = (double)howmany / (double) calleep->cycle->ncalls;
      p->childbytecodes +=
	fraction * (calleep->cycle->nbytecodes) + 0.5;
    }
  } IIScNext();
}

void propagateN(start, end)
int start, end;
{
  int i;
  ProfileEntry *p, *calleep, *cycle;
  unsigned int howmany, count;
  double fraction;
  static int serial = 0;

  cycle = (ProfileEntry *)vmMalloc(sizeof(ProfileEntry));
  cycle->ncalls = 0;
  cycle->nrecursivecalls = 0;
  cycle->childbytecodes = 0;
  cycle->nbytecodes = 0;
  cycle->callers = IIScCreate();
  cycle->callees = IIScCreate();
  cycle->isCycle = 1;
  cycle->ove = (OpVectorElement) ++serial;
  cycle->onStack = 1;
  cycle->marked = 1;
  cycle->cycle = NULL;
  pes[IIScSize(invokeprofile)] = cycle;
  IIScInsert(invokeprofile, cycle->ove, cycle);

  /* Propagate the costs for the non-cycle callees to their parent nodes */
  for (i = start; i <= end; i++) {
    p = sccstack[i];
    p->cycle = cycle;
    IIScForEach(p->callees, calleep, howmany) {
      fraction = (double)howmany / (double) calleep->ncalls;
      if (calleep->onStack) {
	/* Something in this same cycle */
      } else {
	p->childbytecodes +=
	  fraction * (calleep->nbytecodes + calleep->childbytecodes) + 0.5;
	if (calleep->cycle != NULL) {
	  fraction = (double)howmany / (double) calleep->cycle->ncalls;
	  p->childbytecodes +=
	    fraction * (calleep->cycle->nbytecodes) + 0.5;
	}
      }
    } IIScNext();
  }

  /* Propagate the cycle costs to the cycle node */
  for (i = start; i <= end; i++) {
    p = sccstack[i];
    cycle->ncalls += p->ncalls;
    IIScForEach(p->callees, calleep, howmany) {
      fraction = (double)howmany / (double) calleep->ncalls;
      if (calleep->onStack) {
	cycle->nbytecodes +=
	  fraction * (calleep->nbytecodes + calleep->childbytecodes) + 0.5;
	count = IIScLookup(cycle->callees, calleep);
	if (count == IIScNIL) count = 0;
	IIScInsert(cycle->callees, calleep, count + howmany);
	cycle->ncalls -= howmany;
	cycle->nrecursivecalls += howmany;
      }
    } IIScNext();
  }
}

void doSCs(v)
register ProfileEntry *v;
{
  unsigned int howmany;
  ProfileEntry *w, *x;
  v->marked = 1;
  v->number = scccount++;
  v->lowLink = v->number;
  sccstack[++sccsp] = v;
  v->onStack = 1;
  IIScForEach(v->callees, w, howmany) {
    if (! w->marked) {
      doSCs(w);
      v->lowLink = min(v->lowLink, w->lowLink);
    } else {
      if (w->number < v->number && w->onStack) {
	v->lowLink = min(w->number, v->lowLink);
      }
    }
  } IIScNext();
  if (v->lowLink == v->number) {
    int start, end;
    start = end = sccsp;
    while (start >= 0) {
      x = sccstack[start];
      assert(x->onStack);
      if (x == v) break;
      start--;
    }
    if (start == end) {
      propagate1(sccstack[start]);
    } else {
      propagateN(start, end);
    }
    while (start <= end) {
      x = sccstack[end--];
      x->onStack = 0;
    }
    sccsp = start - 1;
  }
}

propagateProfileInfo()
{
  int x;
  ProfileEntry *p;
  sccstack = (ProfileEntry **)
    vmMalloc(IIScSize(invokeprofile) * sizeof(ProfileEntry *));
  sccsp = -1;
  IIScForEach(roots, p, x) {
    assert(!p->marked);
    doSCs(p);
  } IIScNext();
  gc_free(sccstack);
}

printOneGuy(indent, p, n, c, d, q, newline, base)
int indent, newline;
ProfileEntry *p, *q, *base;
unsigned int n, d;
char c;
{
  int i;
  double fraction;
  pad(indent);
  printpe(p, 28-indent);
  if (n && d  && n != d) {
    fraction = (double)n / d;
  } else {
    fraction = 1.0;
  }
  if (n) printf("%6d", n); else pad(6);
  if (d) printf("%c%-6d" , c, d); else pad(7);

  if (c == '+') {
    printf("%9d  %9d", q->nbytecodes, q->childbytecodes);
  } else {
    printf("%9d  ", (int)(fraction * q->nbytecodes + 0.5));
    {
      double children = fraction * q->childbytecodes;
      if (!base->isCycle && q->cycle != NULL && q->cycle != base->cycle) {
	fraction = (double)n / q->cycle->ncalls;
	children += fraction * q->cycle->nbytecodes;
      }
      printf("%9d", (int)(children + 0.5));
    }
  }
  if (newline) putchar('\n');
}

outputProfileInfo()
{
  int i, limit = IIScSize(invokeprofile);
  static char *separator = "----------------------------------------\n";
  ProfileEntry *p, *q;
  unsigned int howmany;
  extern int totalbytecodes;
  int mytotalbytecodes = 0;
  qsort(pes, limit, sizeof(ProfileEntry *), comparepeself);
  for (i = 0; i < limit; i++) {
    p = pes[i];
    if (!p->isCycle) mytotalbytecodes += p->nbytecodes;
  }
  printf("Accounted for byte codes = %d\n", mytotalbytecodes);
  printf(separator);
  printf("Flat profile\n");
  printf(separator);
  for (i = 0; i < limit; i++) {
    p = pes[i];
    if (p->isCycle) continue;
    printf("%5.1f ", (double)p->nbytecodes / totalbytecodes * 100);
    printpe(p, 28);
    printf("  %10d %13d\n", p->ncalls, p->nbytecodes);
  }

  qsort(pes, limit, sizeof(ProfileEntry *), comparepeweight);
  printf(separator);
  printf("Propagated profile\n");
  printf(separator);
  for (i = 0; i < limit; i++) {
    p = pes[i];
    if (IIScSize(p->callers) == 0 && !p->isCycle) {
      pad(10);
      printf("<spontaneous>\n");
    } else {
      IIScForEach(p->callers, q, howmany) {
	pad(6); printOneGuy(4, q, howmany, '/', p->ncalls, p, 1, p);
      } IIScNext();
    }
    printf("%5.1f ", (double)(p->nbytecodes + p->childbytecodes) / totalbytecodes * 100);
    printOneGuy(0, p, p->ncalls, '+', p->nrecursivecalls, p, 0, p);
    printf(" = %9d\n", p->nbytecodes + p->childbytecodes);
    IIScForEach(p->callees, q, howmany) {
      pad(6); printOneGuy(4, q, howmany, '/', q->ncalls, q, 1, p);
    } IIScNext();
    printf(separator);
  }
}

outputInvokeProfile()
{
  OpVectorElement e;
  ConcreteType ct;
  unsigned int howmany;
  ProfileEntry *p, *callerp;
  printf("Jekyll Invocation Profile:\n");
  buildCodeVector();
  buildProfileGraph();
  propagateProfileInfo();
  outputProfileInfo();
}
#endif /* PROFILEINVOKES */

void setBits(Vector v, int off, int len, u32 val)
{
  u32 m = -1L, temp;
  int wordoff = off >> 5;
  off = off & 31;
  temp = ((int *)v->d.data)[wordoff];
  m = m << (32 - len);
  m = m >> (off & 31);
  temp = (temp & ~m) | (m & (val << (32 - (off & 31) - len)));
  ((int *)v->d.data)[wordoff] = temp;
}

void ntohBits(Vector v, int off, int len)
{
  int wordoff;

  if (len == 32) {
    u32 temp;
    wordoff = off >> 5;
    temp = *((u32 *)v->d.data + wordoff);
    temp = ntohl(temp);
    *((u32 *)v->d.data + wordoff) = temp;
  } else if (len == 16) {
    u16 temp;
    wordoff = off >> 4;
    temp = *((u16 *)v->d.data + wordoff);
    temp = ntohs(temp);
    *((u16 *)v->d.data + wordoff) = temp;
  }
}

String timeToDate(int secs)
{
#ifdef STRFTIME
  char buf[30];
  struct tm *tm;
  int len;

  tm = localtime(&secs);
  len = strftime(buf, 30, "%c", tm);
#else
  char *buf;
  buf = ctime((time_t *)&secs);
  if (buf[strlen(buf) - 1] == '\n') buf[strlen(buf) - 1] = '\0';
#endif
  return CreateString(buf);
}

void loadNGo(String s)
{
  char *name;

  name = vmMalloc(s->d.items + 1);
  strncpy(name, (char*)s->d.data, s->d.items);
  name[s->d.items] = '\0';
  DoCheckpointFromFile(name);
  vmFree(name);
}

/*
 * attempt a New C Call.  If an error occurs (probably caused by a
 * bogus argument string) call debug with an appropriate string.
 *
 * If the ccall needs to block, return 1.
 */
int doNCCall(state)
State *state;
{
  u32 moduleindex, funcindex;
  int sl, i, fail = 0, block = 0;
  s32 args[CCALL_MAXARGS];
  f32 f;
  /* the return value is in args[0], arguments in rest */
  CCallDescriptor ccd;
  char buf[80];
  extern CCallDescriptor *ccalltable[];

#define pc state->pc
#define sp state->sp
#define fp state->fp
#define op state->op
#define sb state->sb 		/* Stack base */
#define cp state->cp 		/* Concrete type */

  IFETCH1(moduleindex);
  IFETCH1(funcindex);

  if (!ccalltable[moduleindex]) {
    sprintf(buf, "Call of unselected ccall module %d", moduleindex);
    return debug(state, buf);
  }

  ccd = ccalltable[moduleindex][funcindex];
  sl = strlen(ccd.ccArgTemplate);
  if (sl <1 || sl > CCALL_MAXARGS) {
    sprintf(buf, "Invalid number of args to ccall function %s", ccd.ccName);
    return debug(state, buf);
  }

  /* for each of the argument description letters, pop
     an argument and convert it to C style. */
  for (i=sl-1; i>0; i--) {
    switch (ccd.ccArgTemplate[i]) {
    case 'x': /* exception flag */
      args[i] = (s32) &fail;
      break;
    case 'X': /* blocking flag */
      block = (int)state;
      args[i] = (s32) &block;
      assert(ccd.ccArgTemplate[0] == 'v');
      break;
    case 'b' :
    case 'i' :
    case 'p' :
    case 'c' :
      POP(s32, args[i]);
      break;
    case 'S':
    case 's':
      /* manufacture a C string from an Emerald one */
      {
      String string;
      char* c_string;
      POP(String, string);
      c_string = vmMalloc(string->d.items + 1);
      strncpy(c_string,(char*)string->d.data,string->d.items);
      c_string[string->d.items] = '\0';
      args[i] = (s32)c_string;
      }
      break;
    case 'f':
      POP(f32, f);
      *(float *)&args[i] = f;
      break;
    default :
      sprintf(buf, "Unknown argtype to ccall function %s", ccd.ccName);
      return debug(state, buf);
    }
  }

  /* Tracing! */
  IFTRACE(ccalls, 1) {
    printf("CCall: %s(", ccd.ccName);
    for (i=1; i<sl; i++) {
      if (i>1) printf(", ");
      switch (ccd.ccArgTemplate[i]) {
      case 'b' :
        printf("%s", args[i] ? "true" : "false");
        break;
      case 'i' :
        printf("%d", args[i]);
        break;
      case 'p' :
        printf("0x%x", args[i]);
        break;
      case 'c':
	printf( "0x%02X", args[i] );
      case 's' :
      case 'S':
        printf("\"%s\"", (char *)args[i]);
        break;
      case 'f':
	printf("\"%g\"", *(float*)&args[i]);
	break;
      case 'x':
	printf( "(fail)" );
	break;
      case 'X':
	printf( "(block)" );
	break;
      }
    }
    printf(")\n");
  }

  /*
   * Call the function with the appropriate number of arguments of course,
   * pushing extras doesn't hurt.  Note though, that the call needs to pass
   * CCALL_MAXARGS-1 arguments.
   */
  args[0] = ccd.ccFunction(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);

  /* Tracing! */
  IFTRACE(ccalls, 1) {
	printf("CCall: %s() returned ", ccd.ccName);
    switch (ccd.ccArgTemplate[0])
    {
    case 'v': break;
    case 'b': printf("%s", args[0] ? "true" : "false"); break;
    case 'c': printf( "0x%02X", args[0] ); break;
    case 'i': printf("%d", args[0]); break;
    case 'p': printf("0x%x", args[0]); break;
    case 'f': printf("%g", *(float *)&args[0]); break;
    case 's':
    case 'S': printf("\"%s\"", (char *)args[0]); break;
    }
    printf("\n");
  }

  /* free the arg strings */
  for (i=sl-1; i>0; i--) {
    if (ccd.ccArgTemplate[i] == 'S') 
      vmFree( (void*)args[i] );
  }
  /*
   * If we blocked, we don't have a result.
   */
  if (block) return 1;

  /* store the result */
  switch (ccd.ccArgTemplate[0]) {
  case 'v':
    break;
  case 'c':
  case 'b':
  case 'i':
  case 'p':
    PUSH( s32, ( fail ? JNIL : args[0] ) );
    break;
  case 's': case 'S':
    if( ! fail ) {
      if (args[0]) {
	PUSH( String, CreateString((char*)args[0]));
	if( ccd.ccArgTemplate[0] == 'S' ) vmFree( (void*)args[0] );
      } else {
	PUSH( s32, JNIL ); 
      }
    } else { PUSH( s32, JNIL ); }
    break;
  case 'f':
    PUSH( f32, ( fail ? JNIL : *(float *)&args[0] ) );
    break;
  default:
    sprintf(buf, "Unknown return type from CCALL %s", ccd.ccName);
    return debug(state, buf);
  }

  if( fail ) {
    sprintf( buf, "Exception raised in CCALL %s", ccd.ccName );
    return debug( state, buf );
  }

  return 0;

#undef pc
#undef sp
#undef fp
#undef op
#undef sb
#undef cp
}

extern void move_pointers(int n, Object *p);
extern void move_variables(int n, u32 *p);
extern void move_variable(Object *data, ConcreteType *ct);

static void findLocals(Template t, u32 base, u32 sp,
 		       void (*pointers_f)(int, Object *), void (*variables_f)(int, u32 *))
{
  char *brands;
  int *p = (int *)base, *limit = (int *)sp;
  int count, nelements, size, totalsize, vector;
  char c;

  if (!ISNIL(t)) {
    brands = (char *)t->d.data;
    while(*brands != '\0') {
      vector = 0;
      switch (*brands++) {
      case '%':
	count = 0;
	nelements = 1;
	while (isdigit(c = *brands++)) {
	  count = count * 10 + c-'0';
	}
	if (!count) count = 1;
	if (c == '*') {
	  vector = 1;
	  nelements = *p;
	  p++;
	  c = *brands++;
	}
	while (count--) {
	  switch(c) {
	  case 'm':
	    /* do nothing, no object pointers here */
	    size = 8;
	    break;
	  case 'X':
	  case 'x':
	    pointers_f(nelements, (Object *)&p[0]);
	    size = 4;
	    break;
	  case 'D':
	  case 'd':
	    size = 4;
	    break;
	  case 'F':
	  case 'f':
	    size = 4;
	    break;
	  case 'C':
	  case 'c':
	    size = 1;
	    break;
	  case 'B':
	  case 'b':
	    size = 1;
	    break;
	  case 'V':
	  case 'v':
	    variables_f(nelements, (u32 *)&p[0]);
	    size = 8;
	    break;
	  case 'l':
	  case 'L':
	  case 'q':
	    TRACE(memory, 0, ("Brand %c can't appear in an activation record", c));
	    assert(0);
	    size = 4;
	    break;
	  default:
	    TRACE(memory, 0, ("can't figure brand %c", c));
	    size = 4;
	  }
	  totalsize = nelements * size;
	  totalsize = (totalsize + 3) & ~3;
	  p = (int *) ((int)p + totalsize);
	}
	break;
      default:
	TRACE(memory, 0, ("What is '%c' doing in a template?", brands[-1]));
	break;
      }
    }
  }
  assert(p <= limit);
  if (p < limit) {
    if ((limit - p) % 2) {
      pointers_f(1, (Object *)p);
      p++;
    }
    variables_f((limit - p) / 2, (u32 *)p);
  }
}

static int lunwind(State *state, ConcreteType **cppp, Object **oppp)
{
  if (state->fp < state->sb + 16) {
    return 0;
  } else {
    int *fpint = (int *)state->fp;
    u32 newfp = fpint[-2];
    if (state->fp > newfp && newfp >= state->sb) {
      state->sp = state->fp - 16;
      state->pc = fpint[-1];
      state->fp = newfp;
      state->op = (Object)fpint[-3];
      *oppp = (Object *)&fpint[-3];
      state->cp = (ConcreteType) fpint[-4];
      *cppp = (ConcreteType *)&fpint[-4];
      if (!state->pc) return lunwind(state, cppp, oppp);
      return 1;
    } else {
      return 0;
    }
  }
}

static void dealWithPC(u32 *pcp,
		       OpVectorElement ove,
		       void (*pointers_f)(int, Object *))
{
  Code code = ove->d.code;
  pointers_f(1, (Object *)&code);
  /* This test is not guaranteed to work, as the ove might have already been */
  /* adjusted to reflect the new location of the code string.  If so, we */
  /* can't ever find the old one! TODO! */

  if (code != ove->d.code) {
    /* The code object has moved, and code is now a pointer to the new */
    /* place.  We need to adjust the saved pc in the activation record. */
    u32 newpc, offset;
    offset = *pcp - (u32)ove->d.code;
    newpc = (u32)code + offset;
    /* Put newpc in the right place */
    *pcp = newpc;
  }
}

static int isAllNil(unsigned int *x, int size)
{
  int i;
  size /= 4;
  for (i = 0; i < size; ++i) {
    if (!ISNIL(x[i])) return 0;
  }
  return 1;
}

static void findRootsInStack(State *state, void (*pointers_f)(int, Object *),
			     void (*variable_f)(Object *, ConcreteType *), void (*variables_f)(int, u32 *))
{
  OpVectorElement theOp;
  Template theTemplate;
  State lstate;
  Object *opp = &state->op;
  ConcreteType *cpp = &state->cp;
  u32 *pointertoPC = &state->pc;

  lstate = *state;

  if (state->ep && state->et && ISNOTNIL(state->ep)) variable_f(&state->ep, &state->et);
  pointers_f(1, (Object *)&state->opp);
  do {
    if (lstate.pc) {
      if (HASODP((*cpp)->d.instanceFlags)) pointers_f(1, opp);
      pointers_f(1, (Object *)cpp);
      theOp = findOpVectorElement(lstate.cp, lstate.pc);
      TRACE(memory, 4, ("Moving activation record %.*s.%.*s",
			lstate.cp->d.name->d.items, lstate.cp->d.name->d.data, 
			theOp->d.name->d.items, theOp->d.name->d.data));
      theTemplate = theOp->d.template;
      /*
       * We have to be careful:  newly created threads have a state but
       * don't yet have any stuff on them.
       */
      if (lstate.sp > lstate.sb) {
	if (!ISNIL(theTemplate)) {
	  TRACE(memory, 4, ("  Template: \"%.*s\"", 
			    theTemplate->d.items, theTemplate->d.data));
	}
	if (lstate.sp > lstate.fp) {
	  unsigned int base = lstate.fp ? lstate.fp : lstate.sb;
	  IFTRACE(memory, 1) {
	    if (base + sizeFromTemplate(theTemplate) < lstate.sp) {
	      /*
	       * There is memory left over here that I don't have a template
	       * for, let's at least document it.
	       */
	      TRACE(memory, 1,
		    ("%d bytes of undescribed stack at line %d in %.*s.%.*s",
		     lstate.sp - base - sizeFromTemplate(theTemplate),
		     findLineNumber(lstate.pc, theOp->d.code, theTemplate),
		     lstate.cp->d.name->d.items, lstate.cp->d.name->d.data, 
		     theOp->d.name->d.items, theOp->d.name->d.data));
	      if (!isAllNil(base + sizeFromTemplate(theTemplate),
			    lstate.sp - base - sizeFromTemplate(theTemplate))) {
		TRACE(memory, 1, ("Backtrace of process"));
		showProcess(state, 1);
	      }
	    }
	  }
	  findLocals(theTemplate, base, lstate.sp, pointers_f, variables_f);
	} else {
	  /* We must have suspended this guy before executing any
	     instructions, or there aren't any data items. */
	  /* assert(lstate.pc == (u32)theOp->d.code->d.data); */
	}
      }
      /* This needs to be a call with &state->pc for the first time around */
      /* this loop, and wherever the pc is stored in the stack for all the */
      /* later times.  pointertoPC takes care of this. */
      dealWithPC(pointertoPC, theOp, pointers_f);
      pointertoPC = &((u32 *)lstate.fp)[-1];
    }
  } while (lunwind(&lstate, &cpp, &opp));
  if (lstate.fp > lstate.sb + 16) {
    TRACE(memory, 4, ("Bottom of the stack, state.fp = %#x, state.sb = %#x",
		      lstate.fp, lstate.sb));
    variables_f((lstate.fp - lstate.sb - 16) / (2 * sizeof(u32)), (u32 *)lstate.sb);
  }
}

extern ISet allProcesses;
extern IISc processes, tobeinitialized, fixedMap;
#ifdef USEABCONS
extern OOISc abConMap;
#endif
extern OISc outstandingLocates;

void doAnIISc(void (*pointers_f)(int, Object *), IISc *scp, int destructive)
{
  if ((int)*scp) {
    Object o;
    int value;

    if (destructive) {
      IISc oldsc = *scp;
      *scp = IIScCreateN(IIScSize(oldsc));
      IIScForEach(oldsc, o, value) {
	pointers_f(1, &o);
	IIScInsert(*scp, (int)o, value);
      } IIScNext();
      IIScDestroy(oldsc);
    } else {
      IIScForEach(*scp, o, value) {
	pointers_f(1, &o);
      } IIScNext();
    }
  }
}

void doAnISet(void (*pointers_f)(int, Object *), ISet *scp, int destructive)
{
  if ((int)*scp) {
    Object o;

    if (destructive) {
      ISet oldsc = *scp;
      *scp = ISetCreateN(ISetSize(oldsc));
      ISetForEach(oldsc, o) {
	pointers_f(1, &o);
	ISetInsert(*scp, (int)o);
      } ISetNext();
      ISetDestroy(oldsc);
    } else {
      ISetForEach(*scp, o) {
	pointers_f(1, &o);
      } ISetNext();
    }
  }
}

static void foundone(char *msg, State *state)
{
  ftrace("Found state %x in %s", (unsigned)state, msg);
  abort();
}

void tryToFindState(State *state)
{
  OID oid;
  State *statep;
  Object o;

  ISetForEach(allProcesses, statep) {
    if (state == statep) foundone("allProcesses", state);
  } ISetNext();

  if (processes) {
    IIScForEach(processes, statep, o) {
      if (state == statep) foundone("processes", state);
    } IIScNext();
  }

  if (tobeinitialized) {
    IIScForEach(tobeinitialized, statep, o) {
      if (state == statep) foundone("tobeinitialized", state);
    } IIScNext();
  }

  if (outstandingLocates) {
    struct locationRecord *s;
    OIScForEach(outstandingLocates, oid, s) {
      o = OIDFetch(oid);
      if (state == (State *)o) foundone("outstandingLocates", state);
      if (s->waitingStates) {
	ISetForEach(s->waitingStates, statep) {
	  if (state == statep) foundone("outstandingLocates->waitingStates", state);
	} ISetNext();
      }
    } OIScNext();
  }
}

void doToExternalRoots(void (*pointers_f)(int, Object *), 
		       void (*variable_f)(Object *, ConcreteType *),
		       void (*variables_f)(int, Bits32 *),
		       int destructive,
		       int doFromObjectTable)
{
  State *statep;
  OID oid;
  Object o;
  int i, j;
#ifdef USEABCONS
  AbCon abcon;
#endif

  TRACE(memory, 7, ("Moving from relocation map"));
  if (relocationMap) {
    ISet s;
    Relocation *r;
    OID oid;
    OIScForEach(relocationMap, oid, s) {
      ISetForEach(s, r) {
	pointers_f(1, &r->o);
      } ISetNext();
    } OIScNext();
  }
#ifdef USEABCONS
  TRACE(memory, 7, ("Moving from abcon map"));
  if (abConMap) OOIScForEach(abConMap, oid, oid, abcon) {
    pointers_f(1, (Object *)&abcon->d.ab);
    pointers_f(1, (Object *)&abcon->d.con);
  } OOIScNext();
#endif

  TRACE(memory, 7, ("Moving from allprocesses"));
  ISetForEach(allProcesses, statep) {
    pointers_f(1, (Object *)&allProcesses->table[ISetxx_index].key);
    findRootsInStack(statep, pointers_f, variable_f, variables_f);
    if (!destructive) {
      o = OIDFetch(statep->nsoid);
      pointers_f(1, &o);
      o = OIDFetch(statep->psoid);
      pointers_f(1, &o);
    }
  } ISetNext();

  TRACE(memory, 7, ("Moving from processes"));
  doAnIISc(pointers_f, &processes, destructive);

  TRACE(memory, 7, ("Moving from fixedMap"));
  doAnIISc(pointers_f, &fixedMap, destructive);

  TRACE(memory, 7, ("Moving from tobeinitialized"));
  doAnIISc(pointers_f, &tobeinitialized, destructive);

  TRACE(memory, 7, ("Moving from allfrozen"));
  doAnIISc(pointers_f, &allfrozen, destructive);

  if (outstandingLocates && !destructive) {
    void *s;
    TRACE(memory, 7, ("Moving from outstanding locates"));
    OIScForEach(outstandingLocates, oid, s) {
      /*
       * I want to hang onto any stub for an object that I am currently
       * trying to locate, as some state may be depending on this.
       */
      o = OIDFetch(oid);
      if (!ISNIL(o)) pointers_f(1, &o);
    } OIScNext();
  }
    
  if (doFromObjectTable) {
    int roots = 0;
    TRACE(memory, 7, ("Moving from object table"));
    OTableForEach(ObjectTable, oid, o) {
      /*
       * OK, this is a truly awful hack, but I really need to change the entry
       * in the table, and this is the only efficient way.
       */
      if (destructive || (RESDNT(o->flags) && wasGCMalloced(o) && ((!ISIMUT(CODEPTR(o->flags)->d.instanceFlags) || (isBuiltinOID(oid)))))) {
	pointers_f(1, (Object *)&ObjectTable->table[OTablexx_index].value);
	roots ++;
      }
    } OTableNext();
    if (!destructive)
      TRACE(memory, 3, ("Marked from %d of %d Object table roots",
			roots, OTableSize(ObjectTable)));
  }

#ifdef DISTRIBUTED
  /*
   * While the gaggle table is keyed by oid not pointer, we want to keep
   * around gaggle info so we can send it to other nodes.  We'll treat
   * everything referenced by the oid in the gaggle table as reachable.
   */
  {
    OID moid;
    int index;
    extern OISc gaggleTable;

    OIScForEach(gaggleTable, moid, index){
      int    size  = get_gsize(moid);
      int    i;

      for (i = 0 ; i < size; i++){  
	OID          ooid    = get_gelement(moid, i);
	Object       gmember = OIDFetch(ooid);
	pointers_f(1, &gmember);
      }
    } OIScNext();
  }    
  {
    noderecord **nd;
    for (nd = &allnodes->p; *nd; nd = &(*nd)->p) {
      Object node = OIDFetch((*nd)->node);
      Object inctm = OIDFetch((*nd)->inctm);
      if (ISNIL(node)) {
	TRACE(memory, 4, ("Mark roots: can't fetch the node for %s", OIDString((*nd)->node)));
      } else {
	pointers_f(1, &node);
      }
      if (ISNIL(inctm)) {
	TRACE(memory, 4, ("Mark roots: can't fetch the inctm for %s", OIDString((*nd)->inctm)));
      } else {
	pointers_f(1, &inctm);
      }
    }
  }
#endif    
  {
    extern Object StdInStream, StdOutStream;
    extern String SysName, TrueString, FalseString;
    extern Object rootdir, rootdirg, node, inctm, upcallStub, locsrv, debugger;

    pointers_f(1, &StdInStream);
    pointers_f(1, &StdOutStream);
    pointers_f(1, (Object *)&SysName);
    pointers_f(1, (Object *)&TrueString);
    pointers_f(1, (Object *)&FalseString);
    pointers_f(1, &rootdir);
    pointers_f(1, &rootdirg);
    pointers_f(1, &locsrv);
    pointers_f(1, &debugger);
    pointers_f(1, &node);
    pointers_f(1, &inctm);
    pointers_f(1, &upcallStub);
  }

  TRACE(memory, 7, ("Moving from builtin global arrays"));
  for (i = 0; i < NUMBUILTINS; i++) {
    for (j = 0; j < NUMTAGS; j++) {
      if (BuiltinGlobalArray[i][j]) pointers_f(1, &BuiltinGlobalArray[i][j]);
    }
  }
  
  /*
   * Take care of distributed gc structures.
   */
  {
    extern ISet remotegreys, interestingblacks;
    if (remotegreys) doAnISet(pointers_f, &remotegreys, destructive);
    if (interestingblacks) doAnISet(pointers_f, &interestingblacks, destructive);
  }

  /*
   * Take care of the explicitly registered extra roots
   */
  TRACE(memory, 7, ("Moving from extra roots"));
  for (i = 0; i < extraRootsSP; i++) {
    pointers_f(1, (Object *)extraRoots[i]);
  }
}

inline int sizeOfX(Object o, Object new, ConcreteType ct)
{
  int size;

  assert(HASODP(ct->d.instanceFlags));
  if (ct->d.instanceSize >= 0) {
    size = ct->d.instanceSize;
  } else if (RESDNT(new->flags)) {
    int count = ((Vector)o)->d.items;
    count *= -ct->d.instanceSize;
    size = ROUNDUP(count) + sizeof(u32);
  } else {
    size = getVectorSize(o);
    size = (size - 1) * sizeof(u32);
  }
  return (size + sizeof(u32)) / sizeof(u32);
}

int sizeOf(Object o)
{
  return sizeOfX(o, o, CODEPTR(o->flags));
}

int VecLength(Vector o)
{
  if (ISNIL(o)) return 0;
  return o->d.items;
}

/*
 * Search the queue of waiting states for one that is attempting an
 * invocation of an operation in the given type.   Remove the first one
 * found and return it, or return NULL.
 */
State *findAcceptable(SQueue waiting, AbstractType acceptable)
{
  State *s;
  OpVectorElement ove;
  ATOpVectorElement ave;
  int i;
  TRACE(process, 3, ("Trying to find an acceptable operation"));
  SQueueForEach(waiting, s) {
    TRACE(process, 4, ("Looking at state #%x", s));
    ove = s->opp;
    assert(ove && !ISNIL(ove));
    TRACE(process, 5, ("State #%x is operation %.*s[%d] %d",
		       s, ove->d.name->d.items, ove->d.name->d.data,
		       ove->d.nargs, ove->d.id));
    if (acceptable->d.ops->d.items == 0) {
      /*
       * This is Any. accept the op.
       */
      int res = SQueueYank(waiting, s);
      if (!res) assert(0);
      TRACE(process, 4, ("Found an acceptable operation"));
      return s;
    } else {
      for (i = 0; i < acceptable->d.ops->d.items; i++) {
	ave = acceptable->d.ops->d.data[i];
	TRACE(process, 6, ("AT Operation %d is %.*s[%d] %d",
			   i, ave->d.name->d.items, ave->d.name->d.data,
			   VecLength((Vector)ave->d.arguments),
			   ave->d.id));
	if (ave->d.id == ove->d.id) {
	  /*
	   * Found this op in the AT, accept the op.
	   */
	  int res = SQueueYank(waiting, s);
	  if (!res) assert(0);
	  TRACE(process, 4, ("Found an acceptable operation"));
	  return s;
	}
      }
    }
  } SQueueNext();
  TRACE(process, 4, ("Failed to find an acceptable operation"));
  return NULL;
}

#if defined(WIN32)
static struct _timeb xx_start;

int gettimeofday(struct timeval *tvp, void *p)
{
	struct _timeb tb;
	_ftime(&tb);
	tvp->tv_sec = tb.time;
	tvp->tv_usec = tb.millitm * 1000;
	return 0;
}

int getuid()
{
	return 5001;
}

void start_times(void)
{
  _ftime(&xx_start);
}
 
struct _timeb xx_now;

currentCpuTime()
{
  _ftime(&xx_now);
  if (xx_now.millitm < xx_start.millitm) {
    xx_now.time -= (xx_start.time + 1);
    xx_now.millitm = xx_now.millitm + 1000 - xx_start.millitm;
  } else {
    xx_now.time -= xx_start.time;
    xx_now.millitm -= xx_now.millitm;
  }
  return xx_now.time * 100 + xx_now.millitm / 10;
}
#else
#define FTIME(x) (((x).tms_utime + (x).tms_stime) * 100 / getclocktick())

static int getclocktick(void)
{
#if defined(_SC_CLK_TCK)
  return sysconf(_SC_CLK_TCK);
#endif
#if defined(linux)
  return 100;
#else
  return 60;
#endif
}

void start_times(void)
{
}
 
int currentCpuTime()
{
  struct tms time_buf;
  int t;
  times (&time_buf);
  t = FTIME(time_buf);
  return t;
}
#endif

#if defined(hp700)
int srandom(unsigned int seed)
{
  srand48(seed);
  return 1;
}
int random(void)
{
  return lrand48();
}
#endif
#if defined(WIN32)
int srandom(unsigned int seed)
{
  srand(seed);
  return 1;
}
int random(void)
{
  return rand();
}
#endif
#if defined(sparc) && defined(sun) && !defined(__svr4__)
#undef memmove
memmove(void *res, void *src, int len)
{
  bcopy(src, res, len);
}
#endif
