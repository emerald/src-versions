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

/*
 * @(#)trace.c	1.1  3/11/91
 */
#include "assert.h"
#include "trace.h"
#include <stdarg.h>

int 
		traceinit,
		traceparse,
		tracehelp;

typedef struct {
  char *name;
  int  *flag;
} flagTable, *flagTablePtr;

flagTable table [] = {
  "help", &tracehelp,
  "init", &traceinit,
  "parse", &traceparse,
  NULL, 0
};

void toLower(s)
register char *s;
{
  register char c;
  while (c = *s) {
    if (c >= 'A' && c <= 'Z') *s += ('a' - 'A');
    s++;
  }
}

char *find(s, c)
register char *s, c;
{
  register char theC;
  while ((theC = *s) && theC != c) s++;
  return(theC == c ? s : NULL);
}

parseTraceFlag(f)
register char *f;
{
  char *comma, *equals;
  register flagTablePtr tp;
  int value;

  assert(*f == '-'); f++;
  assert(*f == 'T'); f++;
  toLower(f);
  while (f && *f) {
    comma = find(f, ',');
    if (comma != NULL) *comma = '\0';
    equals = find(f, '=');
    if (equals == NULL) {
      value = 1;
    } else {
      value = atoi(equals+1);
      if (value <= 0) value = 1;
      *equals = '\0';
    }
    for (tp = &table[0]; tp->name; tp++) {
      if (!strcmp(f, tp->name)) {
	*tp->flag = value;
	break;
      }
    }
    if (tp->name == NULL) {
      fprintf(stdout, "Unknown trace name \"%s\"\n", f);
      return(0);
    }
    f = (comma == NULL ? NULL : comma + 1);
  }
  return(1);
}

void initializeTrace()
{
  register flagTablePtr tp;
  
  IFTRACE(help, 1) {
    fprintf(stdout, "Trace\t\tValue\n");
    for (tp = &table[0]; tp->name; tp++) {
      fprintf(stdout, "\"%s\" -->\t%d\n", tp->name, *tp->flag);
    }
  }
}

void trace(int level, char *format, ...)
{
  va_list ap;
  va_start(ap, format);
  while (--level > 0) putc(' ', stdout);
  vfprintf(stdout, format, ap);
  putc('\n', stdout);
}
