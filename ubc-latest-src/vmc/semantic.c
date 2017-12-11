#include "defs.h"
#include "vmcpar.h"
#include "trace.h"
#include "slist.h"

extern char *findFileName(), *replaceSuffix();
char *hfilename, *cfilename, *xfilename, *filename, *pathname;
FILE *hfile, *cfile, *xfile;
SISc linenumbers;

char *definitions;
SList state, interrupts, instructions;

static char *fn_filename(char *x)
{
  char *ans;
  for (ans = x; *x; x++) {
    if (*x == '/' && x[1]) {
      ans = x + 1;
    }
  }
  return ans;
}

void semInit(void)
{
  linenumbers = SIScCreate();
  state = SListCreate();
  interrupts = SListCreate();
  instructions = SListCreate();
}

void installDefinition(char *code)
{
  TRACE0(parse, 1, "Definition");
  definitions = code;
}

installState(name, desc, type)
char *name, *desc, *type;
{
  TRACE3(parse, 1, "State: %s %s %s", name, desc, type);
  SListInsert(state, name);
  SListInsert(state, desc);
  SListInsert(state, type);
}

installInterrupt(name, code)
char *name, *code;
{
  TRACE1(parse, 1, "Interrupt: %s", name);
  SListInsert(interrupts, name);
  SListInsert(interrupts, code);
}

installInstruction(name, param, code, lineno)
char *name, *param, *code;
{
  TRACE1(parse, 1, "Instruction: %s", name);
  SIScInsert(linenumbers, name, lineno);
  SListInsert(instructions, name);
  SListInsert(instructions, param);
  SListInsert(instructions, code);
}

static char *mydefinitions1 = "\
#define UFETCH1(where,ptr,inc) { \\\n\
  where = *((unsigned char*)(ptr)); \\\n\
  if (inc) (ptr) = (int)(ptr) + 1; \\\n\
}\n\
#define UFETCH2(where,ptr,inc) { \\\n\
  ptr = (((int)ptr + 1) & ~0x1); \\\n\
  where = (*((unsigned short*)ptr)); \\\n\
  if (inc) (ptr) = (int)(ptr) + 2; \\\n\
  where = ntohs(where); \\\n\
}\n\
\n\
#define UFETCH4(where,ptr,inc) { \\\n\
  ptr = (((int)ptr + 3) & ~0x3); \\\n\
  where = (*((unsigned int*)ptr)); \\\n\
  if (inc) (ptr) = (int)(ptr) + 4; \\\n\
  where = ntohl(where); \\\n\
}\n\
\n";

static char *mydefinitions2 = "\
\n\
#define IFETCH1(where) UFETCH1(where, pc, 1)\n\
#define IFETCH2(where) UFETCH2(where, pc, 1)\n\
#define IFETCH4(where) UFETCH4(where, pc, 1)\n\
\n\
#define PUSH(type,value) { \\\n\
  *(type *)sp = (value); \\\n\
  sp += sizeof(type); \\\n\
}\n\
#define  POP(type,value) { \\\n\
  sp -= sizeof(type); \\\n\
  value = *(type *)sp; \\\n\
}\n\
#define  TOP(type,value) { \\\n\
  value = *(type *)(sp - sizeof(type)); \\\n\
}\n\
#define SETTOP(type,value) { \\\n\
  *(type *)(sp - sizeof(type)) = value; \\\n\
}\n\
#define FETCH(type,base,offset) \\\n\
  (*(type*)((int)(base) + (int)(offset)))\n\
#define STORE(type,base,offset,value) \\\n\
  (*(type*)((int)(base) + (int)(offset)) = (value))\n\
\n\
typedef int s32;\n\
typedef unsigned int u32;\n\
typedef unsigned short u16;\n\
typedef short s16;\n\
typedef unsigned char u8;\n\
typedef char s8;\n\
typedef float f32;\n\
\n";

static char *interprethead = "\
#include <stdlib.h>\n\
#ifndef FILE\n\
#include <stdio.h>\n\
#endif\n\
void disassemble(unsigned int ptr, int len, FILE *f);\n\
long long totalbytecodes;\n\
#ifdef PROFILEINTERPRET\n\
int bc_freq[NINSTRUCTIONS];\n\
#endif\n\
int traceinterpret = 0;\n\
\n\
int interpret(State *state)\n\
{\n\
  u32 pc;\n";

static char *interpretmid1 = "\
  long long addtototalbytecodes = 0;\n\
  unsigned char opcode;\n\
#if defined(INTERPRETERLOCALS)\n\
  INTERPRETERLOCALS\n\
#endif\n";

static char *interpretmid2 = "\
  while (1) {\n\
    TOPOFTHEINTERPRETLOOP\n\
#if defined(COUNTBYTECODES) || defined(PROFILEINTERPRET)\n\
    addtototalbytecodes++;\n\
#endif\n\
    IFETCH1(opcode);\n\
#ifdef PROFILEINTERPRET\n\
    bc_freq[opcode]++;\n\
#endif\n\
#ifndef NTRACE\n\
    if (traceinterpret >= 1) {\n\
      printf(\"Executing opcode \");\n\
      disassemble(pc-1, 1, stdout);\n\
    }\n\
#endif\n\
\n\
    switch(opcode) {\n";

static char *interprettail = "\
      default:\n\
	fprintf(stderr, \"Undefined bytecode %d\\n\", opcode);\n\
        break;\n\
    }\n\
  }\n\
}\n";

doInterpret()
{
  char *name, *param, *desc, *type, *code;
  int opcode = 0;

  fprintf(cfile, "%s", interprethead);
  SListForEachByThree(state, name, desc, type) {
    if (*name == '_') {
      fprintf(cfile, "#define %s state->%s \t\t/* %s */\n", name+1, name+1, desc);
    } else {
      fprintf(cfile, "  %s %s;\t\t/* %s */\n", type, name, desc);
    }
  } SListNext();
  fprintf(cfile, "%s", interpretmid1);
  
  fprintf(cfile, "  UNSYNCH();\n");

  fprintf(cfile, "%s", interpretmid2);
  /* do cases */
  SListForEachByThree(instructions, name, param, code) {
    fprintf(cfile, "      case %s: {%s}\n", name, code);
    fprintf(cfile, "        break;\n");
  } SListNext();
  fprintf(cfile, "%s", interprettail);
  SListForEachByThree(state, name, desc, type) {
    if (*name == '_') {
      fprintf(cfile, "#undef %s\n", name+1);
    }
  } SListNext();

}

static char *assemblehead1 = "\
\n\
#ifndef _U\n\
#define _H_NLCHAR\n\
#define _H_NLCTYPE\n\
#include <ctype.h>\n\
#endif\n\
#include \"sisc.h\"\n\
#include \"ilist.h\"\n\
\n\
static SISc lookup;\n\
\n\
static char *strsave(char *s)\n\
{\n\
  char *t = malloc(strlen(s)+1);\n\
  strcpy(t, s);\n\
  return t;\n\
}\n\
\n\
#define WRITE4(type,v) { if (pos + 4 > limit) grow(); USTORE4(v, pos, 1);}\n\
#define WRITE2(type,v) { if (pos + 2 > limit) grow(); USTORE2(v, pos, 1);}\n\
#define WRITE1(type,v) { if (pos + 1 > limit) grow(); USTORE1(v, pos, 1);}\n\
\n\
static unsigned int pos, limit, base;\n\
static int csize;\n\
\n\
typedef struct {\n\
  int defined;\n\
  union {\n\
    int val;\n\
    IList refs;\n\
  } val;\n\
} Value;\n\
\n\
void grow(void)\n\
{\n\
  int cpos;\n\
  csize = csize == 0 ? 1024 : csize * 2;\n\
  cpos = pos - base;\n\
  base = (unsigned int) (base ? realloc((char *)base, csize) : malloc(csize));\n\
  pos = base + cpos;\n\
  limit = base + csize;\n\
}\n\
\n\
#define COLLECT(c) (*b++ = c);\n\
\n\
void AddRef(Value *val, int address, int size)\n\
{\n\
  IListInsert(val->val.refs, address);\n\
  IListInsert(val->val.refs, size);\n\
}\n\
\n\
void Backpatch(Value *val, int value)\n\
{\n\
  int address, size;\n\
  unsigned int  lvalue;\n\
  unsigned short svalue;\n\
  unsigned char  bvalue;\n\
  IListForEachByTwo(val->val.refs, address, size) {\n\
    int naddress = base + address;\n\
    switch (size) {\n\
      case 1:\n\
	UFETCH1(bvalue, naddress, 0);\n\
	bvalue += value;\n\
	USTORE1(bvalue, naddress, 0);\n\
	break;\n\
      case 2:\n\
	UFETCH2(svalue, naddress, 0);\n\
	svalue += value;\n\
	USTORE2(svalue, naddress, 0);\n\
	break;\n\
      case 4:\n\
	UFETCH4(lvalue, naddress, 0);\n\
	lvalue += value;\n\
	USTORE4(lvalue, naddress, 0);\n\
	break;\n\
    }\n\
  } IListNext();\n\
  IListDestroy(val->val.refs);\n\
}\n\
\n";

static char *assemblehead2 = "\
static int doAChar(FILE *f, int *value)\n\
{\n\
  register char c = getc(f);\n\
  register int num = 0;\n\
  if (c == '\\\\') {\n\
    c = getc(f);\n\
    if ('0' <= c && c <= '7') {\n\
      /* a C octal escape */\n\
      num = c - '0';\n\
      c = getc(f);\n\
      if ('0' <= c && c <= '7') {\n\
	num *= 8;\n\
	num += c - '0';\n\
	c = getc(f);\n\
	if ('0' <= c && c <= '7') {\n\
	  num *= 8;\n\
	  num += c - '0';\n\
	  c = getc(f);\n\
	}\n\
      }\n\
    } else {\n\
      switch (c) {\n\
	case 'n':\n\
	  num = '\\n';\n\
	  break;\n\
	case 'b':\n\
	  num = '\\b';\n\
	  break;\n\
	case 't':\n\
	  num = '\\t';\n\
	  break;\n\
	case 'r':\n\
	  num = '\\r';\n\
	  break;\n\
	case 'f':\n\
	  num = '\\f';\n\
	  break;\n\
	default:\n\
	  num = c;\n\
	  break;\n\
      }\n\
      c = getc(f);\n\
    }\n\
  } else {\n\
    num = c;\n\
    c = getc(f);\n\
  }\n\
  *value = num;\n\
  return(c);\n\
}\n\
\n";

static char *assemblehead3 = "\
int assemble(char *filename, char **ans, int *len)\n\
{\n\
  FILE *f = fopen(filename, \"r\");\n\
  char buffer[1024], *b = buffer, *name;\n\
  int c, size, theval;\n\
  Value *val, value;\n\
  extern void syntaxerror(char *s, int v);\n\
  if (!f) return 0;\n\
  base = pos = limit = 0;\n\
  c = getc(f);\n\
  while (c != EOF) {\n\
    b = buffer;\n\
    if (isspace(c) || c == ',') {\n\
      c = getc(f);\n\
      continue;\n\
    } else if (c == '#') {\n\
      while ((c = getc(f)) != '\\n' && c != EOF) ;\n\
      if (c == '\\n') c = getc(f);\n\
      continue;\n\
    } else if (isalpha(c)) {\n\
      while (isalpha(c)) {\n\
	COLLECT(c);\n\
	c = getc(f);\n\
      }\n\
      COLLECT('\\0');\n\
      val = (Value *) SIScLookup(lookup, buffer);\n\
      if (c == ':') {\n\
	if (val == (Value *)-1) {\n\
	  val = (Value *) malloc(sizeof(Value));\n\
	  val->defined = 1;\n\
	  val->val.val = pos-base;\n\
	  SIScInsert(lookup, strsave(buffer), (int)val);\n\
	} else {\n\
	  /* Backpatch */\n\
	  Backpatch(val, pos-base);\n\
	  val->defined = 1;\n\
	  val->val.val = pos-base;\n\
	}\n\
	c = getc(f);\n\
	continue;\n\
      } else {\n\
	if (val == (Value *)-1) {\n\
	  val = (Value *) malloc(sizeof(Value));\n\
	  val->defined = 0;\n\
	  val->val.refs = IListCreate();\n\
	  SIScInsert(lookup, strsave(buffer), (int)val);\n\
	}\n\
	size = 1;\n\
      }\n\
    } else if (isdigit(c)) {\n\
      while (isdigit(c)) {\n\
	COLLECT(c);\n\
	c = getc(f);\n\
      }\n\
      COLLECT('\\0');\n\
      value.defined = 1;\n\
      value.val.val = atoi(buffer);\n\
      val = &value;\n\
      size = 4;\n\
    } else if (c == '\\'') {\n\
      value.defined = 1;\n\
      c = doAChar(f, &value.val.val);\n\
      if (c != '\\'') {\n\
	syntaxerror(\"*Unterminated character literal\", 0);\n\
      } else {\n\
	c = getc(f);\n\
      }\n\
      val = &value;\n\
      size = 1;\n\
    } else {\n\
      syntaxerror(\"*Illegal character \\\"%c\\\"\", c);\n\
    }\n";

static char *assemblehead4 = "\
\n\
struct ite {\n\
  char *name; char *param; int val;\n\
} IT[] = {\n";

static char *assembletail1 = "\
};\n\
\n";

static char *assembletail2 = "\
void disassemble(unsigned int ptr, int len, FILE *f)\n\
{\n\
  register struct ite *it;\n\
  register unsigned int base = ptr, limit = ptr + len;\n\
  register unsigned char opcode;\n\
  int i, arg, arg2, arg3;\n\
  short int sarg;\n\
\n\
  while (ptr < limit) {\n\
    if (len > 1) fprintf(f, \"%4d:\\t\", ptr - base);\n\
    opcode = *(unsigned char *)ptr++;\n\
    if (opcode < (sizeof IT / sizeof(struct ite))) {\n\
      it = &IT[opcode];\n\
      fprintf(f, \"%s\\t\", it->name);\n\
      if (*it->param) {\n\
	arg = 0;\n\
	if (!strcmp(it->param, \"u32\")) {\n\
	  UFETCH4(arg, ptr, 1);\n\
	  fprintf(f, \"%d (0x%08x)\", arg, arg);\n\
	} else if (!strcmp(it->param, \"u16\")) {\n\
	  UFETCH2(arg, ptr, 1);\n\
	  fprintf(f, \"%d (0x%04x)\", arg, arg);\n\
	} else if (!strcmp(it->param, \"s16\")) {\n\
	  UFETCH2(sarg, ptr, 1);\n\
	  arg = sarg;\n\
	  fprintf(f, \"%d (0x%04x)\", arg, arg);\n\
	} else if (!strcmp(it->param, \"u8\") || !strcmp(it->param, \"s8\")) {\n\
	  UFETCH1(arg, ptr, 1);\n\
	  fprintf(f, \"%d (0x%02x)\", arg, arg);\n\
	} else if (!strcmp(it->param, \"u8u8\")) {\n\
	  UFETCH1(arg, ptr, 1);\n\
	  UFETCH1(arg2, ptr, 1);\n\
	  fprintf(f, \"%d %d (0x%02x 0x%02x)\", arg, arg2, arg, arg2);\n\
	} else if (!strcmp(it->param, \"u8u16\")) {\n\
	  UFETCH1(arg, ptr, 1);\n\
	  UFETCH2(arg2, ptr, 1);\n\
	  fprintf(f, \"%d %d (0x%02x 0x%04x)\", arg, arg2, arg, arg2);\n\
	} else if (!strcmp(it->param, \"case32\")) {\n\
	  UFETCH2(arg, ptr, 2);\n\
	  UFETCH2(arg2, ptr, 2);\n\
	  fprintf(f, \"%d %d (0x%02x 0x%02x)\\n\", arg, arg2, arg, arg2);\n\
	  for (i = arg; i <= arg2; i++) {\n\
	    UFETCH2(arg3, ptr, 2);\n\
	    fprintf(f, \"\\t  %d -> %d\\n\", i, arg3 + ptr - base);\n\
	  }\n\
	  UFETCH2(arg3, ptr, 2);\n\
	  fprintf(f, \"\\t  else -> %d\", arg3 + ptr - base);\n\
	} else {\n\
	  fprintf(f, \"bad param \\\"%s\\\"\", it->param);\n\
	}\n\
	if (opcode == CALLOID || opcode == CALLOIDS) {\n\
	  fprintf(f, \" %s\", OperationName(arg));\n\
	}\n\
      }\n\
      fprintf(f, \"\\n\");\n\
    } else {\n\
      fprintf(f, \"? %d \'%c\'\\n\", opcode, opcode);\n\
    }\n\
  }\n\
}\n\
\n";

static char *assembletail3 = "\
void outputProfile(void)\n\
{\n\
#ifdef PROFILEINTERPRET\n\
  int i, j, maxindex, max;\n\
  for (i = 0; i < NINSTRUCTIONS; i++) {\n\
    maxindex = 0; max = bc_freq[maxindex];\n\
    for (j = 1; j < NINSTRUCTIONS; j++) {\n\
      if (bc_freq[j] > max) {\n\
	maxindex = j;\n\
	max = bc_freq[maxindex];\n\
      }\n\
    }\n\
    if (max <= 0) return;\n\
    printf(\"%4d: %15s %8d   %5.2f\\n\", i, IT[maxindex].name, max,\n\
      (double) max * 100 / totalbytecodes);\n\
    bc_freq[maxindex] = -1;\n\
  }\n\
#endif\n\
}\n";

doAssemble()
{
  char *name, *param, *code;
  int opcode = 0;
#if 0
  fprintf(cfile, "%s", assemblehead1);
  fprintf(cfile, "%s", assemblehead2);
  fprintf(cfile, "%s", assemblehead3);
#endif
  fprintf(cfile, "%s", assemblehead4);
  SListForEachByThree(instructions, name, param, code) {
    fprintf(cfile, "  { \"%s\", \"%s\", %d } ,\n", name, param, opcode++);
  } SListNext();
  fprintf(cfile, "%s", assembletail1);
  fprintf(cfile, "%s", assembletail2);
  fprintf(cfile, "%s", assembletail3);
}

doHFile()
{
  char *name, *desc, *type;

  fprintf(hfile, "#include \"%s\"\n", fn_filename(xfilename));
  fprintf(hfile, "%s\n", mydefinitions1);
  fprintf(hfile, "%s\n", mydefinitions2);
  fprintf(hfile, "%s\n", definitions);
  fprintf(hfile, "#define NINSTRUCTIONS %d\n", SListSize(instructions)/ 3);

  fprintf(hfile, "typedef struct State {\n");
  fprintf(hfile, "  u32 firstThing;\n");
  fprintf(hfile, "  u32 pc;\n");
  SListForEachByThree(state, name, desc, type) {
    fprintf(hfile, "  %s %s;\t\t/* %s */\n", type, 
	    *name == '_' ? name+1 : name, desc);
  } SListNext();
  fprintf(hfile, "} State;\n");
  fprintf(hfile, "#define F_SYNCH() (\\\n");
  SListForEachByThree(state, name, desc, type) {
    if (*name != '_') {
      fprintf(hfile, "  state->%s = %s,\\\n", name, name);
    }
  } SListNext();
  fprintf(hfile, "  state->pc = pc)\n");  
  fprintf(hfile, "#define F_UNSYNCH() (\\\n");
  SListForEachByThree(state, name, desc, type) {
    if (*name != '_') {
      fprintf(hfile, "  %s = state->%s,\\\n", name, name);
    }
  } SListNext();
  fprintf(hfile, "  pc = state->pc )\n");  

  fprintf(hfile, "#ifdef COUNTBYTECODES\n");
  fprintf(hfile, "#define SYNCH() (\\\n");
  fprintf(hfile, "  F_SYNCH(),\\\n");
  fprintf(hfile, "  totalbytecodes += addtototalbytecodes, \\\n");
  fprintf(hfile, "  addtototalbytecodes = 0 )\n");  
  fprintf(hfile, "#define UNSYNCH() (\\\n");
  fprintf(hfile, "  F_UNSYNCH(),\\\n");
  fprintf(hfile, "  addtototalbytecodes = 0 )\n");  
  fprintf(hfile, "#else /* COUNTBYTECODES */\n");
  fprintf(hfile, "#define SYNCH() (\\\n");
  SListForEachByThree(state, name, desc, type) {
    if (*name != '_') {
      fprintf(hfile, "  state->%s = %s,\\\n", name, name);
    }
  } SListNext();
  fprintf(hfile, "  state->pc = pc)\n");  
  fprintf(hfile, "#define UNSYNCH() (\\\n");
  SListForEachByThree(state, name, desc, type) {
    if (*name != '_') {
      fprintf(hfile, "  %s = state->%s,\\\n", name, name);
    }
  } SListNext();
  fprintf(hfile, "  pc = state->pc )\n");  
  fprintf(hfile, "#endif\n");
}

doXFile()
{
  char *name, *param, *code;
  int opcode = 0;
  SListForEachByThree(instructions, name, param, code) {
    fprintf(xfile,"#define %s %d\n", name, opcode++);
  } SListNext();
}

printQuote(s)
register char *s;
{
  register int c;
  putc('"', cfile);
  putc('{', cfile);
  while (c = *s++) {
    switch (c) {
    case '\"':
    case '\\':
      putc('\\', cfile);
      putc(c, cfile);
      break;
    case '\n':
      putc('\\', cfile);
      putc('n', cfile);
      putc('\\', cfile);
      putc(c, cfile);
      break;
    default:
      putc(c, cfile);
      break;
    }
  }
  putc('}', cfile);
  putc('"', cfile);
}

int doInstructionBodies;

doCFile()
{
  char *name, *param, *code;
  int opcode = 0;
  fprintf(cfile, "#include \"%s\"\n", fn_filename(hfilename));

  if (doInstructionBodies) {
    fprintf(cfile, "char *instructionBodies[] = {\n");
    SListForEachByThree(instructions, name, param, code) {
      putc(' ', cfile);
      putc(' ', cfile);
      printQuote(code);
      putc(',', cfile);
      putc('\n', cfile);
    } SListNext();
    fprintf(cfile, "};\n");
  }
  doInterpret();
  doAssemble();
}

semFinal()
{
  doXFile();
  doHFile();
  doCFile();
  fclose(cfile);
  fclose(hfile);
}

extern int linenumber;

yyerror(s)
char *s;
{
  printf("line %d: %s\n", linenumber, s);
}

Usage(s, t)
char *s;
char *t;
{
  if (s) {
    fprintf(stderr, s, t);
    fputc('\n', stderr);
  }
  fprintf(stderr, "Usage: vmc [-B] [-T<trace>=<value>] <filename>.desc\n");
  exit(1);
}

main(c, v)
int c;
char **v;
{
  FILE *inf;
  c--;
  v++;
  while (c && v[0][0] == '-') {
    switch (v[0][1]) {
      case 'T':
	parseTraceFlag(v[0]);
	break;
      case 'B':
	doInstructionBodies = 1;
	break;
      default:
	Usage("Invalid flag \"%s\"", v[0]);
	break;
    }
    c--;
    v++;
  }
  if (c != 1) Usage(NULL, NULL);
  if (access(v[0], 4)) Usage("Can't open input file \"%s\"", v[0]);

  freopen(v[0], "r", stdin);
  pathname = v[0];
  filename = findFileName(v[0]);
  xfilename = replaceSuffix(filename, ".d", ".h");
  hfilename = replaceSuffix(filename, ".d", "_i.h");
  cfilename = replaceSuffix(filename, ".d", ".c");
  TRACE4(init, 1, "%s %s %s %s", v[0], filename, hfilename, cfilename);
  xfile = fopen(xfilename, "w");
  hfile = fopen(hfilename, "w");
  cfile = fopen(cfilename, "w");
  if (!xfile) Usage("Can't open output file \"%s\"", xfilename);
  if (!hfile) Usage("Can't open output file \"%s\"", hfilename);
  if (!cfile) Usage("Can't open output file \"%s\"", cfilename);
  initializeTrace();
  lexInit();
  semInit();
  yyparse();
  semFinal();
  exit(0);
}
