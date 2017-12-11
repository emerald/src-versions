/*
 * The Emerald Distributed Programming Language
 * 
 * Copyright (C) 2004 Emerald Authors & Contributors
 * 
 * This file is part of the Emerald Distributed Programming Language.
 *
 * The Emerald Distributed Programming Language is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 *  The Emerald Distributed Programming Language is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the Emerald Distributed Programming Language; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

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
