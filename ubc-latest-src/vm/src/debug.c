/* comment me!
 */
#define E_NEEDS_STRING
#define E_NEEDS_CTYPE
#define E_NEEDS_NTOH
#include "system.h"

#include "assert.h"
#include "vm_exp.h"
#include "types.h"
#include "concurr.h"
#include "trace.h"
#include "read.h"
#include "oisc.h"
#include "misc.h"
#include "remote.h"

#define samestring(x, y) (!(strcmp(x, y)))

String currentfilename, oldfilename;
int currentlinenumber, oldlinenumber;

int findLineNumber(unsigned pc, Code code, Template template)
{
  int off, targetoffset, number;
  char *ln, *limit;

  if (ISNIL(template)) return -1;
  targetoffset = pc - (unsigned int)code->d.data;
  ln = (char *)template->d.data;
  limit = ln + template->d.items;
  while (*ln++ != '#') ;
  
  number = mstrtol(ln, &ln, 10);
  off = 0;
  
  while (ln < limit) {
    if (*ln == ';') {
      ln++;
      off += mstrtol(ln, &ln, 10);
      if (off > targetoffset) return number;
      number++;
    } else if (*ln == '+') {
      ln++;
      number += mstrtol(ln, &ln, 10);
    } else if (*ln == '#') {
      ln++;
      number = mstrtol(ln, &ln, 10);
    } else {
      assert(0);
    }
  }
  return number;
}

OpVectorElement findOpVectorElement(ConcreteType cp, unsigned int pc)
{
  int i, limit = cp->d.opVector->d.items;
  OpVectorElement ope;
  Code c;

  for (i = 0; i < limit; i++) {
    ope = cp->d.opVector->d.data[i];
    if (ISNIL(ope))
      continue;
    c = ope->d.code;
    if ((u32)c->d.data <= pc
	&& pc <= (u32)&c->d.data[c->d.items]) 
      return ope;
  }
  return (OpVectorElement)JNIL;
}

int findOpVectorIndex(ConcreteType cp, unsigned int pc)
{
  int i, limit = cp->d.opVector->d.items;
  OpVectorElement ope;
  Code c;

  for (i = 0; i < limit; i++) {
    ope = cp->d.opVector->d.data[i];
    if (ISNIL(ope))
      continue;
    c = ope->d.code;
    if ((u32)c->d.data <= pc
	&& pc <= (u32)&c->d.data[c->d.items]) 
      return i;
  }
  return JNIL;
}

/*
  |			| <- fp
  -----------------------
  |      old pc         |
  -----------------------
  |      old fp         |
  -----------------------
  |      old op         |
  -----------------------
  |      old cp         |
  -----------------------
  |			|
 */

int unwind(State *state)
{
  if (state->fp < state->sb + 16) {
    return 0;
  } else {
    int *fpintp = (int *)state->fp;
    u32 newfp = fpintp[-2];
    if (state->fp > newfp && newfp >= state->sb) {
      state->sp = state->fp - 16;
      state->pc = fpintp[-1];
      state->fp = newfp;
      state->op = (Object)fpintp[-3];
      state->cp = (ConcreteType) fpintp[-4];
      if (!state->pc) return unwind(state);
      return 1;
    } else {
      return 0;
    }
  }
}

int inDebugger = 0;
int instructionsToExecute = -1;
int atABreakpoint = 0, singleStepping = 0;
extern int debugInteractively;
extern void checkDeleteWhenHit(OpVectorElement ove, int offset);

#define S_UPDATE 1
#define S_PRINT 2

static void summary(State *state, int flags)
{
  OpVectorElement theOp;
  Code theCode;
  Template theTemplate;
  int theLineNumber;

  theOp = findOpVectorElement(state->cp, state->pc);
  if (ISNIL(theOp)) {
    TRACE(debug, 0,("Can't find the operation in a %.*s at pc %#x",
	    state->cp->d.name->d.items, state->cp->d.name->d.data, state->pc));
    return;
  }
  theCode = theOp->d.code;
  theTemplate = theOp->d.template;
  theLineNumber = findLineNumber(state->pc, theCode, theTemplate);
  if (flags & S_UPDATE) {
    currentfilename = state->cp->d.filename;
    currentlinenumber = theLineNumber;
#if !defined(NOINTERACTIVEDEBUGGING)
    checkDeleteWhenHit(theOp, state->pc - (int)theCode->d.data);
#endif
  }
  if (flags & S_PRINT) {
    printf("\"%.*s\", line %d (operation %.*s)%s\n",
	    state->cp->d.filename->d.items, 
	    (char *)state->cp->d.filename->d.data, 
	    theLineNumber, theOp->d.name->d.items, 
	    (char *)theOp->d.name->d.data,
	    !RESDNT(state->op->flags) ? " non-resident" : "");
  }
}

String objectName(State *state)
{
  return state->cp->d.name;
}

String operationName(State *state)
{
  OpVectorElement theOp;

  theOp = findOpVectorElement(state->cp, state->pc);
  if (ISNIL(theOp)) {
    TRACE(debug, 0,("Can't find the operation in a %.*s at pc %#x",
	    state->cp->d.name->d.items, state->cp->d.name->d.data, state->pc));
    return (String)JNIL;
  }
  return theOp->d.name;
}

#if !defined(NOINTERACTIVEDEBUGGING)

#define MAXBREAKPOINTS 100
struct {
  OpVectorElement ove;
  int offset;
  unsigned char code;
  unsigned char deleteWhenHit;
} breakpoints[MAXBREAKPOINTS];

static void doBreakpointIterator(void *, void *);

int insertBreakpoint(OpVectorElement ove, int offset, int deleteWhenHit)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS && breakpoints[i].ove != NULL; i++) ;
  if (i == MAXBREAKPOINTS) { printf("Can't set breakpoint\n"); return 0; }
  breakpoints[i].ove = ove;
  breakpoints[i].offset = offset;
  breakpoints[i].code = ove->d.code->d.data[offset];
  breakpoints[i].deleteWhenHit = deleteWhenHit;
  return 1;
}

int deleteBreakpoint(OpVectorElement ove, int offset, int deleteWhenHit)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS && 
              !(breakpoints[i].ove == ove && breakpoints[i].offset == offset);
       i++) ;
  if (i == MAXBREAKPOINTS) { printf("Can't delete breakpoint\n"); return 0; }
  ove->d.code->d.data[offset] = breakpoints[i].code;
  breakpoints[i].ove = 0;
  breakpoints[i].offset = 0;
  return 1;
}

int isBreakpoint(OpVectorElement ove, int offset)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS && 
              !(breakpoints[i].ove == ove && breakpoints[i].offset == offset);
       i++) ;
  return (i < MAXBREAKPOINTS);
}

void checkDeleteWhenHit(OpVectorElement ove, int offset)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS && 
              !(breakpoints[i].ove == ove && breakpoints[i].offset == offset);
       i++) ;
  if (i < MAXBREAKPOINTS && breakpoints[i].deleteWhenHit) {
    deleteBreakpoint(ove, offset, 1);
  }
}

void resetBreakpoints(void)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS; i++) {
    if (breakpoints[i].ove) {
      breakpoints[i].ove->d.
	code->d.data[breakpoints[i].offset] = breakpoints[i].code;
    }
  }
}

void setBreakpoints(void)
{
  int i;
  for (i = 0; i < MAXBREAKPOINTS; i++) {
    if (breakpoints[i].ove) {
      breakpoints[i].ove->d.
	code->d.data[breakpoints[i].offset] = BREAKPT;
    }
  }
}

/*
 * Display all the information about loaded concrete types and templates in
 * a reasonable format.
 */
void displayCTs(void)
{
  OID oid;
  Object object;
  int j;
  OTableForEach(ObjectTable, oid, object) {
    if (CODEPTR(object->flags) == ctct) {
      ConcreteType ct = (ConcreteType) object;
      printf("%.*s %d", ct->d.name->d.items, (char *)ct->d.name->d.data,
	     ct->d.instanceSize);
      if (ISNIL(ct->d.template)) printf(" Nil");
      else printf(" %.*s", ct->d.template->d.items, (char *)ct->d.template->d.data);
      for (j = 0; j < ct->d.opVector->d.items; j++) {
	OpVectorElement ove;
	ove = ct->d.opVector->d.data[j];
	if (!ISNIL(ove)) {
	  printf(" %.*s", ove->d.name->d.items, (char *)ove->d.name->d.data);
	  if (ISNIL(ove->d.template)) printf(" Nil");
	  else printf(" %.*s", ove->d.template->d.items,
		      (char *)ove->d.template->d.data);
	}
      }
      printf("\n");
    }      
  } OTableNext();
}

/*
 *  Some globals (local to this file) which allow the next two functions
 *  to communicate with each other.
 */
static int dBlen, dBlineNumber, dBset, dBdeleteWhenHit;
static ConcreteType dBctct;
static char *dBfileName;

int doBreakpoint(char *fileName, int len, int lineNumber, int set, int deleteWhenHit)
{
  OID oid;
  Object object;
  dBlen = len;
  dBlineNumber = lineNumber;
  dBset = set;
  dBdeleteWhenHit = deleteWhenHit;
  dBfileName = fileName;
  dBctct = ctct;
  OTableForEach(ObjectTable, oid, object) {
    doBreakpointIterator(&oid, object);
  } OTableNext();
  return 1;
}

static void doBreakpointIterator(void *theKey, void *theItem)
{
  int j;
  String filename;
  ConcreteType ct = (ConcreteType) theItem;
  
  if (CODEPTR(ct->flags) != dBctct) return;
  filename = ct->d.filename;
  if ((filename->d.items == dBlen ||
       (filename->d.items> dBlen && 
	filename->d.data[filename->d.items - dBlen - 1] == '/'))
      && !strncmp((char *)&filename->d.data[filename->d.items - dBlen],
		  dBfileName, dBlen)) {
    /* found one */
    for (j = ct->d.opVector->d.items - 1;
	 j >= 0; j--) {
      char *ln, *limit;
      int number, off;
      OpVectorElement ove;
      ove = ct->d.opVector->d.data[j];
      if (!ISNIL(ove) && !ISNIL(ove->d.template)) {
	ln = (char *)ove->d.template->d.data;
	limit = ln + ove->d.template->d.items;
	while (*ln++ != '#') ;
	
	number = mstrtol(ln, &ln, 10);
	off = 0;
	while (ln < limit || number == dBlineNumber) {
	  if (number == dBlineNumber) {
	    printf("%s a breakpoint in op %.*s file \"%.*s\", line %d\n",
		   (dBset ? "Set" : "Deleted"), 
		   ove->d.name->d.items,
		   (char *)ove->d.name->d.data, 
		   filename->d.items, (char *)filename->d.data,
		   number);
	    (dBset ? insertBreakpoint : deleteBreakpoint)(ove, off, dBdeleteWhenHit);
	    break;
	  }
	  if (*ln == ';') {
	    ln++;
	    off += mstrtol(ln, &ln, 10);
	    number++;
	  } else if (*ln == '+') {
	    ln++;
	    number += mstrtol(ln, &ln, 10);
	  } else if (*ln == '#') {
	    ln++;
	    number = mstrtol(ln, &ln, 10);
	  } else {
	    assert(0);
	  }
	}
      }
    }
  }
}

int arDepth(u32 fp, u32 sb)
{
  int depth = 0;
  u32 newfp;
  int *fpintp;

  while (!ISNIL(fp) && fp >= sb + 16) {
    fpintp = (int *)fp;
    newfp = fpintp[-2];
    if (fp > newfp && newfp >= sb) {
      fp = newfp;
      if (fpintp[-1] != 0) depth ++;
    } else {
      break;
    }
  }
  return depth;
}

void displayD(int n, int *x, int vector)
{
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    if (ISNIL(*x)) {
      fprintf(stderr, "nil");
    } else if (*x == -1) {
      fprintf(stderr, "-1");
    } else {
      fprintf(stderr, "%d (%#x)", *x, *x);
    }
    x++;
    if (n > 0) fprintf(stderr, ", ");
  }
  if (vector) fprintf(stderr, " }");
}

void displayF(int n, int *x, int vector)
{
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    if (ISNIL(*x)) {
      fprintf(stderr, "nil");
    } else if (*x == -1) {
      fprintf(stderr, "minus 1!");
    } else {
      fprintf(stderr, "%g (%#x)", (double)*x, *x);
    }
    x++;
    if (n > 0) fprintf(stderr, ", ");
  }
  if (vector) fprintf(stderr, " }");
}

void displayC(int n, unsigned char *x, int vector)
{
  unsigned char c;
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    c = vector ? *x : *((unsigned int *)x);
    if (isprint(c)) {
      fprintf(stderr, "'%c'", c);
    } else {
      fprintf(stderr, "'\\%o'", c);
    }
    x = vector ? x+1 : (unsigned char *)((unsigned int *)x + 1);
    if (n > 0) fprintf(stderr, ", ");
  }
  if (vector) fprintf(stderr, " }");
}

void displayB(int n, unsigned char *x, int vector)
{
  unsigned char c;
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    c = vector ? *x : *((unsigned int *)x);
    fprintf(stderr, "%.04o (%#.2x)", c, c);
    x = vector ? x+1 : (unsigned char *)((unsigned int *)x + 1);
    if (n > 0) fprintf(stderr, ", ");
  }
  if (vector) fprintf(stderr, " }");
}

extern int inHeap(unsigned int x);

void displayX(int n, int *x, int vector)
{
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    if (ISNIL(*x)) {
      fprintf(stderr, "nil");
    } else if (*x == -1) {
      fprintf(stderr, "minus 1!");
    } else if (!inHeap(*x)) {
      fprintf(stderr, "non-heap pointer: %08x", *x);
    } else {
      fprintf(stderr, "<%#x, ", *x);
      ConcreteType cp = CODEPTR(((Object)*x)->flags);
      fprintf(stderr, "%#x>", (unsigned int)cp);
      fprintf(stderr, " %.*s",
	      cp->d.name->d.items, 
	      (char *)cp->d.name->d.data);
      if (cp == BuiltinInstCT(STRINGI)) {
	String s = (String) *x;
	fprintf(stderr, " (\"%.*s\")", min(32, s->d.items),
		(char *)s->d.data);
      } else if (cp == BuiltinInstCT(CONDITIONI)) {
	Object o = (Object)*x;
	condition *c = (condition *)o->d;
	fprintf(stderr, " (%d waiting)", SQueueSize(c->waiting));
      }
    }
    if (n > 0) fprintf(stderr, ", ");
    x++;
  }
  if (vector) fprintf(stderr, " }");
}

void displayAV(Object o, ConcreteType cp)
{
  if (ISNIL(o)) {
    fprintf(stderr, "nil");
  } else if (o == (Object)-1) {
    fprintf(stderr, "minus 1!");
  } else if (!inHeap((unsigned int)o)) {
    fprintf(stderr, "non-heap pointer: %08x", (unsigned int)o);
  } else if (!inHeap((unsigned int)cp)) {
    fprintf(stderr, "non-heap ct pointer: %08x", (unsigned int)cp);
  } else {
    fprintf(stderr, "<%#x, %#x>", (int)o, (int)cp);
    fprintf(stderr, " %s%.*s",
	    HASODP(cp->d.instanceFlags) ? (RESDNT(o->flags) ? "" : "remote ") : "", 
	    cp->d.name->d.items,
	    (char *)cp->d.name->d.data);
    if (cp == intct) {
      fprintf(stderr, " (%d)", (int)o);
    } else if (cp == BuiltinInstCT(CHARACTERI)) {
      if (isprint((int)o)) {
	fprintf(stderr, " ('%c')", (int)o);
      } else {
	fprintf(stderr, " ('\\%03o')", (int)o);
      }
    } else if (cp == BuiltinInstCT(REALI)) {
      fprintf(stderr, " (%g)", *(float *) &o);
    } else if (cp == BuiltinInstCT(BOOLEANI)) {
      fprintf(stderr, " (%s)", o ? "true" : "false");
    } else if (cp == BuiltinInstCT(STRINGI)) {
      String s = (String)o;
      fprintf(stderr, " (\"%.*s\")", min(32, s->d.items),
	      (char *)s->d.data);
    }
  }
}

void displayV(int n, int *x, int vector)
{
  Object o;
  ConcreteType cp;
  if (vector) fprintf(stderr, "{ ");
  while (n--) {
    o =  (Object) *x++;
#ifdef USEABCONS
    {
      AbCon abcon;
      abcon = (AbCon) *x++;
      cp = ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
    }
#else
    cp = (ConcreteType) *x++;
#endif
    displayAV(o, cp);
    if (n > 0) fprintf(stderr, ", ");
  }
  if (vector) fprintf(stderr, " }");
}

char *printName(char *name)
{
  char c;
  int len = 0;
  fprintf(stderr, "    ");
  while ((c = *name++) != '@' && c != '\0') {
    putc(c, stderr);
    len ++;
  }
  putc(':', stderr);
  while (len < 16) {
    putc(' ', stderr);
    len ++;
  }
  putc(' ', stderr);
  return name;
}

char *nextName(char *name)
{
  for (; *name; name++) ;
  name++;
  return name;
}

void dumpFromDebugInfo(char *info, u32 basepointer)
{
  char *addr, base;
  u32 off, pointer;
  while (*info && *info != '#') {
    addr = printName(info);
    base = *addr++;
    off = mstrtol(addr, &info, 10);
    info ++;
    if (base == 'A') 
      off = -(int)off + ARGOFF;
    pointer = basepointer + off;
    displayV(1, (int *)pointer, 0);
    putc('\n', stderr);
  }
}

int difind(char *name, char *info, u32 basepointer, int **addrp, char *brandp)
{
  char *addr, base;
  int off;
  u32 pointer;
  int l = strlen(name);
  while (*info && *info != '#') {
    if ((info[l] == '@' || info[l] == '\0') && !strncmp(name, info, l)) {
      addr = info + l + 1;
      base = *addr++;
      off = mstrtol(addr, &info, 10);
      if (base == 'A') 
	off = -off + ARGOFF;
      pointer = basepointer + off;
      *addrp = (int *)pointer;
      *brandp = 'v';
      return 1;
    } else {
      while (*info) info++;
      info ++;
    }
  }
  return 0;
}

static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}

void dump(Template t, u32 base)
{
  char *brands;
  char *names;
  int *p = (int *)base;
  int count, nelements, size = 0, totalsize, vector;
  char c;
  
  if (ISNIL(t)) return;
  brands = (char *)t->d.data;
  names = nextName(brands);
  while(1) {
    vector = 0;
    switch (*brands++) {
    case '%':
      count = 0;
      nelements = 1;
      while (misdigit(c = *brands++)) {
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
	printName(names);
	names = nextName(names);
	switch(c) {
	case 'm': 
	  {
	    monitor *m = (monitor *)&p[0];
	    assert(nelements == 1);
	    if (m->busy == 1) {
	      fprintf(stderr, "locked");
	    } else if (m->busy == 0) {
	      fprintf(stderr, "open");
	    } else {
	      fprintf(stderr, "jibberish");
	    }
	    fprintf(stderr, " (%d waiting)", SQueueSize(m->waiting));
	    size = 8;
	  }
	  break;
	case 'x':
	case 'X':
	  displayX(nelements, &p[0], vector);
	  size = 4;
	  break;
        case 'd':
        case 'D':
	  displayD(nelements, &p[0], vector);
	  size = 4;
	  break;
        case 'f':
        case 'F':
	  displayF(nelements, &p[0], vector);
	  size = 4;
	  break;
        case 'c':
        case 'C':
	  displayC(nelements, (unsigned char *)&p[0], vector);
	  size = 1;
	  break;
        case 'b':
        case 'B':
	  displayB(nelements, (unsigned char *)&p[0], vector);
	  size = 1;
	  break;
	case 'v':
	case 'V':
	  displayV(nelements, &p[0], vector);
	  size = 8;
	  break;
	case 'l':
	case 'L':
	  fprintf(stderr, "Can't display brand %c", c);
	  break;
	default:
	  fprintf(stderr, "can't figure brand %c", c);
	}
	putc('\n', stderr);
	totalsize = nelements * size;
	totalsize = (totalsize + 3) & ~3;
	p = (int *) ((int)p + totalsize);
      }
      break;
    case '\0':
      if ((names < (char *)&t->d.data[t->d.items])
	  && *names && (*names != '#'))
	dumpFromDebugInfo(names, base);
      return;
    default:
      fprintf(stderr, "What is '%c' doing in a template?\n", brands[-1]);
      break;
    }
  }
}
  
static void detailcommand(State *state)
{
  fprintf(stderr, "pc = %x\n", state->pc);
  fprintf(stderr, "sp = %x\n", state->sp);
  fprintf(stderr, "fp = %x\n", state->fp);
  fprintf(stderr, "op = %x\n", (u32)state->op);
  fprintf(stderr, "sb = %x\n", state->sb);
  fprintf(stderr, "cp = %x\n", (u32)state->cp);
}

static void listcommand(void)
{
  FILE *inf;
  char *fn = (char *)vmMalloc(currentfilename->d.items + 1);
  memmove(fn, currentfilename->d.data, currentfilename->d.items);
  fn[currentfilename->d.items] = '\0';
  fprintf(stderr, "%s, line %d\n", fn, currentlinenumber);
  inf = fopen(fn, "rb");
  if (inf == NULL) {
    fprintf(stderr, "Can't open %s\n", fn);
  } else {
    int toskip = currentlinenumber - 5, i, c;
    if (toskip < 0) toskip = 0;
    for (i = 0; i < toskip; i++) {
      while (getc(inf) != '\n') ;
    }
    for (i = 0; i < 10; i++) {
      if (feof(inf)) break;
      fprintf(stderr, "%s%5d: ", i == 4 ? ">" : " ", i + toskip + 1);
      while ((c = getc(inf)) != '\n' && !feof(inf)) putc(c, stderr);
      putc('\n', stderr);
    }
    fclose(inf);
  }
  vmFree(fn);
}

static void wherecommand(State *state, int verbose, int limit)
{
  OpVectorElement theOp;
  Template theTemplate;
  State lstate;
  lstate = *state;

  do {
    if (lstate.pc) {
      summary(&lstate, S_PRINT);
      theOp = findOpVectorElement(lstate.cp, lstate.pc);
      if (ISNIL(theOp)) break;
      theTemplate = theOp->d.template;
      if (verbose) {
	fprintf(stderr, "%-21s ", "  target:");
	displayAV(lstate.op, lstate.cp);
	putc('\n', stderr);
	dump(lstate.cp->d.template, (u32)lstate.op + 4);
	if (!ISNIL(theTemplate)) {
	  fprintf(stderr, "  locals:\n");
	  dump(theTemplate, lstate.fp);
	}
	{
	  unsigned int base = lstate.fp ? lstate.fp : lstate.sb;
	  base += sizeFromTemplate(theTemplate);
	  unsigned int ptr = base;
	  if (ptr < lstate.sp) {
	    /*
	     * There is memory left over here that I don't have a template
	     * for, let's at least document it.
	     */
	    while (ptr < lstate.sp) {
	      char crap[32];
	      sprintf(crap, "[extra +%3d]", ptr - base);
	      printName(crap);
	      displayX(1, (int *)ptr, 0);
	      fprintf(stderr, "\n");
	      ptr += 4;
	    }
	  }
	}
      }
    }
  } while (unwind(&lstate) && --limit > 0);
}

static int tfind(Template t, u32 base, char *name, int **addrp, char *brandp)
{
  char *brands;
  char *names;
  int *p = (int *)base;
  int count, nelements, size, totalsize, l;
  char c;
  
  if (ISNIL(t)) return 0;
  l = strlen(name);
  brands = (char *)t->d.data;
  names = nextName(brands);
  while(1) {
    switch (*brands++) {
    case '%':
      count = 0;
      nelements = 1;
      while (misdigit(c = *brands++)) {
	count = count * 10 + c-'0';
      }
      if (!count) count = 1;
      if (c == '*') {
	nelements = *p;
	p++;
	c = *brands++;
      }
      while (count--) {
	if ((names[l]== '@' || names[l]== '\0') && !strncmp(name, names, l)) {
	  /* found it, now return its address and brand */
	  *addrp = p;
	  *brandp = c;
	  return 1;
	}
	names = nextName(names);
	switch(c) {
	case 'm': 
	  size = 8;
	  break;
	case 'x':
	case 'X':
	  size = 4;
	  break;
        case 'd':
        case 'D':
	  size = 4;
	  break;
        case 'f':
        case 'F':
	  size = 4;
	  break;
        case 'c':
        case 'C':
	  size = 1;
	  break;
        case 'b':
        case 'B':
	  size = 1;
	  break;
	case 'v':
	case 'V':
	  size = 8;
	  break;
	case 'l':
	case 'L':
	  size = 4;
	  break;
	default:
	  fprintf(stderr, "can't figure brand %c", c);
	  size = 4;
	}
	totalsize = nelements * size;
	totalsize = (totalsize + 3) & ~3;
	p = (int *) ((int)p + totalsize);
      }
      break;
    case '\0':
      if ((names < (char *)&t->d.data[t->d.items])
	  && *names && (*names != '#'))
	return difind(name, names, base, addrp, brandp);
      return 0;
    default:
      fprintf(stderr, "What is '%c' doing in a template?\n", brands[-1]);
      break;
    }
  }
  return 0;
}

static int find(State *state, char *name, int **addrp, char *brandp)
{
  OpVectorElement theOp;
  Template theTemplate;
  State lstate;
  lstate = *state;

  if (samestring(name, "self")) {
    *addrp = (int *)&state->op;
    *brandp = 'x';
    return 1;
  }
  do {
    if (!lstate.pc) continue;
    theOp = findOpVectorElement(lstate.cp, lstate.pc);
    theTemplate = theOp->d.template;
    if (tfind(theTemplate, lstate.fp, name, addrp, brandp)) 
      return 1;
    if (tfind(lstate.cp->d.template, (u32)lstate.op + 4, name, addrp, brandp)) 
      return 1;
  } while (unwind(&lstate));
  return 0;
}

void printAs(int *addr, char brand)
{
  switch(brand) {
  case 'm': 
    {
      monitor *m = (monitor *)addr;
      if (m->busy == 1) {
	fprintf(stderr, "locked");
      } else if (m->busy == 0) {
	fprintf(stderr, "open");
      } else {
	fprintf(stderr, "jibberish");
      }
      fprintf(stderr, " (%d waiting)", SQueueSize(m->waiting));
    }
    break;
  case 'x':
  case 'X':
    displayX(1, addr, 0);
    break;
  case 'd':
  case 'D':
    displayD(1, addr, 0);
    break;
  case 'f':
  case 'F':
    displayF(1, addr, 0);
    break;
  case 'c':
  case 'C':
    displayC(1, (unsigned char *)addr, 0);
    break;
  case 'b':
  case 'B':
    displayB(1, (unsigned char *)addr, 0);
    break;
  case 'v':
  case 'V':
    displayV(1, addr, 0);
    break;
  case 'l':
  case 'L':
    fprintf(stderr, "can't figure brand %c", brand);
    break;
  default:
    fprintf(stderr, "can't figure brand %c", brand);
  }
  putc('\n', stderr);
}

ConcreteType figureCT(int *addr, char brand)
{
  switch (brand) {
  case 'b':
  case 'B':
  case 'm':
  case 'd':
  case 'D':
  case 'f':
  case 'F':
  case 'c':
  case 'C':
    return (ConcreteType) NULL;
    break;
  case 'x':
  case 'X':
    if (ISNIL(*addr)) return (ConcreteType) NULL;
    return CODEPTR(((Object)*addr)->flags);
    break;
  case 'v':
  case 'V':
    if (ISNIL(*addr)) return (ConcreteType) NULL;
#ifdef USEABCONS
    {
      AbCon abcon = (AbCon) addr[1];
      return ISNIL(abcon) ? (ConcreteType)JNIL : abcon->d.con;
    }
#else
    return (ConcreteType) addr[1];
#endif
    break;
  case 'l':
  case 'L':
    fprintf(stderr, "Can't figure brand %c\n", brand);
    return (ConcreteType) JNIL;
  default:
    fprintf(stderr, "Can't figure brand %c\n", brand);
    return (ConcreteType) JNIL;
  }
}

static int doSubscript(Template t, u32 base, char *name, int **addrp, char *brandp)
{
  int index = mstrtol(name, (char **)NULL, 0);
  char *brands, brand;
  if (ISNIL(t)) return 0;

  brands = (char *)t->d.data;
  if (brands[0] == '%' && brands[1] == '*') {
    brand = brands[2];
    if (index <= *(int *)base) {
      base += sizeof(u32);
      if (brand == 'x' || brand == 'd' || brand == 'f' || brand == 'l' ||
	  brand == 'X' || brand == 'D' || brand == 'F' || brand == 'L') {
	base += index * 4;
      } else if (brand == 'c' || brand == 'b' ||
		 brand == 'C' || brand == 'B') {
	fprintf(stderr, "Can't deal with vectors of char or byte\n");
	return 0;
      } else if (brand == 'v' || brand == 'V') {
	base += index * 8;
      } else {
	fprintf(stderr, "can't figure brand %c", brand);
      }      
      *addrp = (int *)base;
      *brandp = brand;
      return 1;
    }
  }
  return 0;
}

static void printInternal(State *state, char *fullname)
{
  u32 value = (u32) JNIL;
  if (!strcmp(fullname+1, "pc")) {
    value = state->pc;
  } else if (!strcmp(fullname+1, "op")) {
    value = (u32)state->op;
  } else if (!strcmp(fullname+1, "cp")) {
    value = (u32)state->cp;
  } else if (!strcmp(fullname+1, "fp")) {
    value = state->fp;
  } else if (!strcmp(fullname+1, "sp")) {
    value = state->sp;
  } else {
    printf("Can't print \"%s\"\n", fullname);
  }
  printf("%s: %#x\n", fullname, value);
}

static void findAndPrint(State *state, char *fullname)
{
  int *addr;
  char brand, d, *dp, *name = fullname;
  int first = 1, found;
  ConcreteType ct = 0;
  
  while (*name) {
    for (dp = name; *dp && *dp != '.' && *dp != '['; dp++) ;
    d = *dp;
    *dp = '\0';
    if (first) {
      found = find(state, name, &addr, &brand);
    } else {
      if (ct) {
	found = tfind(ct->d.template, *addr + 4, name, &addr, &brand);
      } else {
	found = 0;
      }
    }
    if (found) {
      TRACE(debug, 1, ("Found %s at %#x brand %c", name, addr, brand));
      ct = figureCT(addr, brand);
    } else {
      fprintf(stderr, "Can't find %s\n", fullname);
      return;
    }
    first = 0;
    *dp = d;
    while (d == '[') {
      name = dp + 1;
      for (dp = name; *dp && *dp != '.' && *dp != ']'; dp++) ;
      d = *dp;
      *dp = '\0';
      if (ct) {
	found = doSubscript(ct->d.template, *addr + 4, name, &addr, &brand);
      } else {
	found = 0;
      }
      *dp = d;
      for (dp = dp + 1; *dp && *dp != '.' && *dp != '['; dp++) ;
      d = *dp;
      *dp = '\0';
      if (found) {
	TRACE(debug, 1, ("Found %s at %#x brand %c", name - 1, addr, brand));
	ct = figureCT(addr, brand);
      } else {
	fprintf(stderr, "Can't find %s\n", fullname);
	return;
      }
      *dp = d;
    }
    name = d == '.' || d == ']' ? dp + 1 : dp;
  }
  if (first) {
    fprintf(stderr, "Can't find %s\n", fullname);
    return ;
  }
  fprintf(stderr, "%s = ", fullname);
  printAs(addr, brand);
  if (ct && RESDNT(((Object)*addr)->flags)) dump(ct->d.template, *addr + 4);
}

/*
 * Interactively debug
 */
int interact(State *state)
{
  char buffer[256], *command, *arg, *p, *arg2;
  State lstate, *tstate = state;
  int stacklevel = 0;
  lstate = *state;
  do {
    fprintf(stderr, "edb> "); fflush(stderr);
    {
      char *streamGetString( int *fail, int fd );
      int streamEos( int *fail, int fd );
      char *buf; int fail;
      fail = 0; if( streamEos( &fail, 0 ) || fail ) return 1;
      buf = streamGetString( &fail, 0 ); if( fail ) return 1;
      if( buf[0] == '\0' ) { vmFree( buf ); return 1; }
      memcpy( (void*)buffer, (void*)buf, 256 );
      vmFree( buf );
    }

    buffer[strlen(buffer) -1] = '\0';
    for (command = buffer; *command && *command == ' '; command++) ;
    for (arg = command; *arg && *arg != ' '; arg++) ;
    if (*arg) *arg++ = '\0';
    for (; *arg && *arg == ' '; arg++) ;
    for (arg2 = arg; *arg2 && *arg2 != ' '; arg2++) ;
    if (*arg2) *arg2++ = '\0';
    for (; *arg2 && *arg2 == ' '; arg2++) ;
    for (p = arg2; *p && *p != ' '; p++) ;
    if (*p) *p++ = '\0';

    if (!*command) continue;
    if (samestring(command, "where")) {
      wherecommand(tstate, 0, 9999999);
    } else if (samestring(command, "detail")) {
      detailcommand(tstate);
    } else if (samestring(command, "list") || samestring(command, "l")) {
      listcommand();
    } else if (samestring(command, "trace")) {
      extern void setTrace(const char *, int);
      setTrace(*arg ? arg : "call",
	       *arg2 ? mstrtol(arg2, (char **)NULL, 0) : 1);
    } else if (samestring(command, "dump")) {
      wherecommand(tstate, 1, 9999999);
    } else if (samestring(command, "processes")) {
      showAllProcesses(tstate, 0);
    } else if (samestring(command, "process")) {
      State *findProcess(int), *temp;
      if ((temp = findProcess(mstrtol(arg, NULL,  10))) != NULL) {
	tstate = temp;
	lstate = *tstate;
	stacklevel = 0;
	summary(&lstate, S_PRINT + S_UPDATE);
      } else {
	fprintf(stderr, "No such process (only %d exist)\n",
		ISetSize(allProcesses));
      }
    } else if (samestring(command, "quit") || samestring(command, "q")) {
      return 1;
    } else if (samestring(command, "continue") || samestring(command, "cont") ||
	       samestring(command, "c")) {
      return 0;
    } else if (samestring(command, "print") || samestring(command, "p")) {
      char *t;
      for  (t = arg; *t; t++) {
	if (isalpha(*t)) *t = tolower(*t);
      }
      if (*arg == '$') {
	printInternal(&lstate, arg);
      } else {
	findAndPrint(&lstate, arg);
      }
    } else if (samestring(command, "up")) {
      if (unwind(&lstate)) {
	stacklevel ++;
	summary(&lstate, S_PRINT + S_UPDATE);
      } else {
	fprintf(stderr, "Can't do up (at the top of the stack)\n");
      }
    } else if (samestring(command, "down")) {
      if (stacklevel == 0) {
	fprintf(stderr, "Can't go down\n");
      } else {
	int i;
	stacklevel --;
	lstate = *tstate;
	for (i = 0; i < stacklevel; i++) {
	  if (!unwind(&lstate)) {
	    fprintf(stderr, "Oops - couldn't unwind when I should have\n");
	  }
	}
	summary(&lstate, S_PRINT + S_UPDATE);
      }
    } else if (samestring(command, "look") || samestring(command, "info")) {
      wherecommand(&lstate, 1, 1);
    } else if (samestring(command, "stop") || samestring(command, "b")) {
      int res;
      if (*arg2) {
	res = doBreakpoint(arg, strlen(arg), mstrtol(arg2, NULL, 10), 1, 0);
      } else if (*arg) {
	res = doBreakpoint((char *)currentfilename->d.data,
			   currentfilename->d.items, 
			   mstrtol(arg, NULL, 10), 1, 0);
      } else {
	res = doBreakpoint((char *)currentfilename->d.data,
			   currentfilename->d.items,
			   currentlinenumber, 1, 0);
      }
      if (!res) printf("Can't set a breakpoint there.\n");
    } else if (samestring(command, "delete") || samestring(command, "d")) {
      int res;
      if (*arg2) {
	res = doBreakpoint(arg, strlen(arg), mstrtol(arg2, NULL, 10), 0, 0);
      } else if (*arg) {
	res = doBreakpoint((char *)currentfilename->d.data,
			   currentfilename->d.items,
			   mstrtol(arg, NULL, 10), 0, 0);
      } else {
	res = doBreakpoint((char *)currentfilename->d.data,
			   currentfilename->d.items,
			   currentlinenumber, 0, 0);
      }
      if (!res) printf("Can't find a breakpoint there to delete.\n");
    } else if (samestring(command, "next") || samestring(command, "n")) {
      if (!doBreakpoint((char *)currentfilename->d.data,
			currentfilename->d.items,
			currentlinenumber + 1, 1, 1)) {
	printf("Can't find the next line.\n");
      } else {
	return 0;
      }
    } else if (samestring(command, "bu")) {
      State llstate = lstate;
      if (!unwind(&llstate)) {
	fprintf(stderr, "Can't find previous activation record");
      } else {
	OpVectorElement ove = findOpVectorElement(llstate.cp, llstate.pc);
	insertBreakpoint(ove, llstate.pc -
			 (int)ove->d.code->d.data, 1);
      }
    } else if (samestring(command, "finish") || samestring(command, "f")) {
      State llstate = lstate;
      if (!unwind(&llstate)) {
	fprintf(stderr, "Can't find previous activation record");
      } else {
	OpVectorElement ove = findOpVectorElement(llstate.cp, llstate.pc);
	insertBreakpoint(ove, llstate.pc -
			 (int)ove->d.code->d.data, 1);
	return 0;
      }
    } else if (samestring(command, "step") || samestring(command, "s") ||
	       samestring(command, "Step") || samestring(command, "S")) {
      instructionsToExecute = 1;
      singleStepping = command[0] == 's' ? 1 : -1;
      oldfilename = currentfilename;
      oldlinenumber = currentlinenumber;
      return 0;
    } else {
      fprintf(stderr, "Can't \"%s\"\n", command);
    }
  } while (1);
  return 1;
}

State *findProcess(int i)
{
  State *statep;

  ISetForEach(allProcesses, statep) {
    if (i == 0) return statep;
    i--;
  } ISetNext();
  return NULL;
}

void showProcess(State *state, int levelOfDetail)
{
  wherecommand(state, levelOfDetail, 9999999);
}

void showAllProcesses(State *state, int levelOfDetail)
{
  State lstate, *statep, *nstate;
  int current = 0;

  if (state) {
    ISetForEach(allProcesses, statep) {
      if (statep == state) break;
      current ++;
    } ISetNext();

    if (ISetSize(allProcesses) > 1) fprintf(stderr, "Current process (ID: %d)\n",
					    current);
    lstate = *state;
    if (levelOfDetail > 0) {
      wherecommand(&lstate, levelOfDetail > 1, 9999999);
    } else {
      summary(&lstate, S_PRINT);
    }
  }

  current = 0;
  ISetForEach(allProcesses, statep) {
    if (statep != state) {
      fprintf(stderr, "Process %d %#x %s", current, (unsigned int)statep,
	      isReady(statep) ? "ready" : "not ready");
      if (!isNoOID(statep->nsoid)) {
	if (ISNIL(nstate = (State *)OIDFetch(statep->nsoid))) {
	  fprintf(stderr, " waiting some state");
	} else {
	  fprintf(stderr, " waiting on state %#x", (unsigned int)nstate);
	}
      }
      fprintf(stderr, "\n");
      lstate = *statep;
      if (levelOfDetail > 0) {
	wherecommand(&lstate, levelOfDetail > 1, 9999999);
      } else {
	summary(&lstate, S_PRINT);
      }
    }
    current ++;
  } ISetNext();
}
#endif

/*
 * The object is dead.  Kill it and kill any activities that may have been
 * waiting for it to do something.
 *
 * These include processes trying to invoke it because it was frozen, and
 * processes currently executing any of its operations.
 */
void breakNonMonitoredObject(Object o)
{
  State *state;
  SQueue wasready;


  if (isBroken(o)) return;
  freeze(o, RDead);
  wasready = ready;
  ready = SQueueCreate();
  while ((state = SQueueRemove(wasready))) {
    if (state->op == o) {
      if (!debug(state, "Was executing in broken object"))
	makeReady(state);
    } else {
      makeReady(state);
    }
  }
}

/*
 * The object is dead.  Kill it and kill any activities that may have been
 * waiting for it to do something.
 *
 * These include processes trying to invoke it because it was frozen, and
 * processes in its monitor entry queue and processes in any condition
 * objects that it owns.
 */
void breakMonitoredObject(Object o)
{
  monitor *m;
  State *state;

  if (isBroken(o)) return;
  freeze(o, RDead);
  m = (monitor *)o->d;
  SQueueForEach(m->waiting, state) {
    if (!debug(state, "Was waiting in monitor entry for broken object")) {
      makeReady(state);
    }
  } SQueueNext();
  SQueueDestroy(m->waiting);
  m->waiting = 0;
}

void breakObject(Object o)
{
  ConcreteType ct = CODEPTR(o->flags);
  Template t = ct->d.template;
  if (ISNIL(t) || !(t->d.data[0] == '%' && t->d.data[1] == 'm')) {
    breakNonMonitoredObject(o);
  } else {
    breakMonitoredObject(o);
  }
}
  
/*
 * If the object is monitored, and the op is an entry operation, then kill
 * the object.
 */
void maybeKillObject(Object op, ConcreteType ct, OpVectorElement ove)
{
  Template t = ct->d.template;
  if (ISNIL(t)) return;
  if (t->d.data[0] == '%' && t->d.data[1] == 'm') {
    /*
     * The object is monitored
     */
    Code c = ove->d.code;
    if (ISNIL(c)) return;
    if ((c->d.data[0] == MONENTER) ||
	(c->d.data[0] == LINKB && c->d.data[2] == MONENTER) ||
	(c->d.data[0] == LINKB && c->d.data[4] == MONENTER)) {
      /*
       * The operation is a monitor entry.  There is no direct way to see
       * this.
       */
      breakMonitoredObject(op);
    }
  }
}

int findHandler(State *state, int name, Object o)
{
  OpVectorElement theOp;
  Code theCode = 0;
  struct FHE *thefhe = 0, *fhe;
  struct FHC *fhc;
  int i, m, n, lname;
  State lstate = *state;
  u32 apc;

  while (thefhe == 0) {
    if (name == 1 && lstate.op == o) {
      TRACE(unavailable, 2, ("State.op == unavailable object %#x, ignoring this frame", o));
    } else if (isBroken(lstate.op)) {
      TRACE(call, 2, ("Skipping frame in broken object %#x", lstate.op));
    } else {
      theOp = findOpVectorElement(lstate.cp, lstate.pc);
      theCode = theOp->d.code;
      apc = lstate.pc - (u32)theCode->d.data;
      TRACE(unavailable, 2, ("Searching operation %.*s in code %.*s",
			     theOp->d.name->d.items, theOp->d.name->d.data,
			     lstate.cp->d.name->d.items, lstate.cp->d.name->d.data));
      TRACE(call, 2, ("Searching operation %.*s in code %.*s",
			     theOp->d.name->d.items, theOp->d.name->d.data,
			     lstate.cp->d.name->d.items, lstate.cp->d.name->d.data));

  
      n = theCode->d.items;
      fhc = (struct FHC *)&theCode->d.data[n - 4];
      if (fhc->h == 'h' && fhc->c == 'c') {
	m = ntohs(fhc->count);
	for (lname = name; !thefhe && lname >= 0; lname--) {
	  fhe = (struct FHE *)&theCode->d.data[n-4-m*sizeof(struct FHE)];
	  for (i = 0; i < m; i++) {
	    if (ntohl(fhe->name) == (unsigned)lname &&
		ntohs(fhe->blockStart) < apc && apc <= ntohs(fhe->blockEnd)) {
	      if (!thefhe || 
		  ntohs(thefhe->blockStart) < ntohs(fhe->blockStart) || 
		  ntohs(thefhe->blockEnd) > ntohs(fhe->blockEnd)) {
		thefhe = fhe;
	      }
	    }
	    fhe++;
	  }
	}
      }
    }
    if (thefhe) {
      *state = lstate;
      state->pc = (u32)theCode->d.data + ntohs(thefhe->handlerStart);
      if (ntohl(thefhe->name) == 1) {
	u32 varOffset = ntohs(thefhe->variableOffset);
	if (varOffset != 65535) {
	  TRACE(call, 1, ("Storing unavailable object at %x + %d", state->fp, varOffset));
	  STORE(Object, state->fp, varOffset, o);
	  STORE(ConcreteType, state->fp, varOffset + 4,
		ISNIL(o) ? (ConcreteType)JNIL : CODEPTR(o->flags));
	}
      }
      return 1;
    } else {
      maybeKillObject(lstate.op, lstate.cp, theOp);
      if (!unwind(&lstate)) return 0;
    }
  }
  return 0;
}

static inline int sameFile(void)
{
  return oldfilename->d.items == currentfilename->d.items &&
    !strncmp((char *)oldfilename->d.data, (char *)currentfilename->d.data,
	     currentfilename->d.items);
}

static inline int sameLine(void)
{
  return oldlinenumber == currentlinenumber;
}

/*
 * Return true (1) if the stack segment has been taken care of and should no
 * longer be evaluated.  A 0 return means that interpretation of this state
 * should continue.
 */
int unavailable(State *state, Object o)
{
  State lstate = *state;
#ifdef DISTRIBUTED
  extern void removeFromAllGaggles(Object);
#ifndef LEAVECORPSESINGAGGLES
  removeFromAllGaggles(o);
#endif
#endif
  if (findHandler(&lstate, 1, o)) {
    TRACE(unavailable, 1, ("Unavailable \"%x\" which is handled", o));
    TRACE(call, 1, ("Unavailable \"%x\" which is handled", o));
    TRACE(process, 1, ("Unavailable \"%x\" which is handled", o));
    *state = lstate;
    return 0;
#if !defined(NOINTERACTIVEDEBUGGING)
  } else if (debugInteractively) {
    return debug(state, "Unhandled unavailable");
#endif
  } else {
    TRACE(failure, 1, ("Unhandled unavailable \"%x\"", o));
    TRACE(unavailable, 1, ("Unhandled unavailable \"%x\"", o));
    state = processDone(state, 2);
    if (state) makeReady(state);
    return 1;
  }
}

int debug(State *state, char *m)
{
  int isFailure = (m != 0);
  atABreakpoint = 0;
  
  instructionsToExecute = 0;
  if (m) {
    if (samestring(m, "Interrupt")) {
      isFailure = 0;
    } else if (samestring(m, "Breakpoint")) {
      isFailure = 0;
      atABreakpoint = 1;
      state->pc --;
    } else if (samestring(m, "Single step")) {
      isFailure = 0;
      if (singleStepping) {
	summary(state, S_UPDATE);
	if (currentlinenumber == 0 || 
	    (singleStepping < 0 && (!sameFile() || sameLine())) ||
	    (singleStepping > 0 && (sameFile() && sameLine()))) {
	  instructionsToExecute = 1;
	  return 0;
	}
      } else {
#if !defined(NOINTERACTIVEDEBUGGING)
	setBreakpoints();
#endif
	return 0;
      }
    } else if (samestring(m, "First time")) {
      isFailure = 0;
    }
  }

  singleStepping = 0;

  if (isFailure) {
    State lstate = *state, *newstate;
    if (findHandler(&lstate, 0, (Object)JNIL)) {
      TRACE(call, 1, ("Failure \"%s\" which is handled", m));
      TRACE(process, 1, ("Failure \"%s\" which is handled", m));
      *state = lstate;
      return 0;
    } else if (!debugInteractively) {
      /*
       * The process should be killed, and the object that is currently
       * executing declared dead.
       */
      String theobjectname, theoperationname;
      theobjectname = objectName(&lstate);
      theoperationname = operationName(&lstate);
      TRACE(failure, 1, ("Unhandled failure \"%s\" in object %.*s, op %.*s", m,
			 theobjectname->d.items, theobjectname->d.data,
			 theoperationname->d.items, theoperationname->d.data));
      newstate = processDone(state, 1);
      if (newstate) makeReady(newstate);
      return 1;
#if !defined(NOINTERACTIVEDEBUGGING)
    } else {
      showAllProcesses(state, 1);
      if (m) fprintf(stderr, "Exception: %s\nRaised at: ", m);
      summary(state, S_UPDATE + S_PRINT);
      resetBreakpoints();
      inDebugger = 1;
      if (interact(state)) {
	exit(1);
      } else {
	/*
	 * The process should be killed, and the object that is currently
	 * executing declared dead.
	 */
	inDebugger = 0;
	newstate = processDone(state, 1);
	if (newstate) makeReady(newstate);
	setBreakpoints();
	return 1;
      }
#endif
    }
  }

  if (debugInteractively) {
    if (m && samestring(m, "First time")) {
      /* do nothing */
    } else {
      if (m && !samestring(m, "Single step")) {
	printf("%s\n", m);
      }
      summary(state, S_UPDATE + S_PRINT);
    }
#if !defined(NOINTERACTIVEDEBUGGING)
    resetBreakpoints();
#endif
    inDebugger = 1;
#if !defined(NOINTERACTIVEDEBUGGING)
    if (interact(state)) exit(1);
#else
    exit(1);
#endif
    inDebugger = 0;
  } else {
    if (m) printf("%s\n", m);
    showAllProcesses(state, 1);
    exit(1);
  }
  if (atABreakpoint) {
    instructionsToExecute = 1;
  } else if (instructionsToExecute != 1) {
#if !defined(NOINTERACTIVEDEBUGGING)
    setBreakpoints();
#endif
  }
  return 0;
}
