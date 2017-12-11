#include <stdio.h>

#define UFETCH1(where,ptr,inc) { \
  where = *((unsigned char*)(ptr)); \
  if (inc) (int)(ptr)++; \
}
#ifdef sparc
#define UFETCH2(where,ptr,inc) { \
  where = (((*((unsigned char*)(ptr))) << 8) | \
          (*((unsigned char*)((int)(ptr)+1)))); \
  if (inc) (int)(ptr) += 2; \
  where = ntohs(where); \
}

#define UFETCH4(where,ptr,inc) { \
  where = (((*((unsigned char*)(ptr))) << 24) | \
	   (*((unsigned char*)((int)(ptr)+1)) << 16) | \
	   (*((unsigned char*)((int)(ptr)+2)) << 8) | \
	   (*((unsigned char*)((int)(ptr)+3)))); \
  if (inc) (int)(ptr) += 4; \
  where = ntohl(where); \
}
#else
#define UFETCH2(where,ptr,inc) { \
  where = (*((unsigned short*)ptr)); \
  if (inc) (int)(ptr) += 2; \
  where = ntohs(where); \
}

#define UFETCH4(where,ptr,inc) { \
  where = (*((unsigned long*)ptr)); \
  if (inc) (int)(ptr) += 4; \
  where = ntohl(where); \
}
#endif



#define NINSTRUCTIONS 103
extern struct ite {
  char *name; char *param; int val;
} IT[];

#ifdef DOINSTRUCTIONBODIES
extern char *instructionBodies[];

printQuote(cfile, s)
FILE *cfile;
register char *s;
{
  register int c;
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
}

static char *header = "#define PUSH(type,value) { \\\n\
  *(type *)sp = (value); \\\n\
  sp += sizeof(type); \\\n\
}\n\
#define  POP(type,value) { \\\n\
  sp -= sizeof(type); \\\n\
  value = *(type *)sp; \\\n\
}\n\
typedef unsigned long u32;\n\
typedef long s32;\n\
";

void discompile(ptr, len, f)
register unsigned char *ptr;
int len;
FILE *f;
{
  register struct ite *it;
  register unsigned char *base = ptr, *limit = ptr + len;
  register unsigned char opcode;
  int arg, arg2;
  short int sarg;

  fprintf(f, "%s\n", header);
  fprintf(f, "junk(sp, op)\nlong sp, op;\n{\n");

  while (ptr < limit) {
    fprintf(f, "L%d:\n", ptr - base);
    opcode = *ptr++;
    if (opcode < NINSTRUCTIONS) {
      it = &IT[opcode];
      if (*it->param) {
	arg = 0;
	if (!strcmp(it->param, "u32")) {
	  UFETCH4(arg, ptr, 1);
	} else if (!strcmp(it->param, "u16")) {
	  UFETCH2(arg, ptr, 1);
	} else if (!strcmp(it->param, "s16")) {
	  UFETCH2(sarg, ptr, 1);
	  arg = sarg;
	} else if (!strcmp(it->param, "u8")) {
	  UFETCH1(arg, ptr, 1);
	} else if (!strcmp(it->param, "case32")) {
	  UFETCH2(arg, ptr, 2);
	  UFETCH2(arg2, ptr, 2);
	  ptr += (arg2 - arg + 1) * sizeof(short);
	  arg = arg << 16 + arg2;
	} else {
	  fprintf(stderr, "bad param \"%s\"", it->param);
	}
	fprintf(f, "#define IFETCH4(x) (x) = %#x\n", arg);
	fprintf(f, "#define IFETCH2(x) (x) = %#x\n", arg);
	fprintf(f, "#define IFETCH1(x) (x) = %#x\n", arg);
      }
      printQuote(f, instructionBodies[opcode]);
      putc('\n', f);
      fprintf(f, "#undef IFETCH4\n");
      fprintf(f, "#undef IFETCH2\n");
      fprintf(f, "#undef IFETCH1\n");
    } else {
      fprintf(f, "? %d '%c'\n", opcode, opcode);
    }
  }
  fprintf(f, "}\n");
}
#endif
