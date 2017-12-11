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
