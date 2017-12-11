#include <stdio.h>

printcode(base, len)
char *base;
int len;
{
  char *b, *pos = base + len;
  for (b = base; b < pos; b++) {
    printf("%4d: %d %02X\n", b - base, *b, *(unsigned char *)b);
  }
}

syntaxerror(s, v)
char *s;
int v;
{
  fprintf(stderr, "syntax error: ");
  fprintf(stderr, s, v);
  fprintf(stderr, "\n");
  exit(1);
}

main()
{
  char *code;
  int len, stack[1000];
  struct {
    int pc, sp, fp, op;
  } state;
  initassemble();
  assemble("inx", &code, &len);
#ifdef DOINSTRUCTIONBODIES
  discompile(code, len, stdout);
#else
  /* printcode(code, len); */
  disassemble(code, len, stdout);
  state.pc = (int) code;
  state.sp = (int) stack;
  interpret(code, state);
#endif
  exit(0);
}
