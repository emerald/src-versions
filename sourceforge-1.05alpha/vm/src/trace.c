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

/* comment me!
 */

#define E_NEEDS_VARARGS
#define E_NEEDS_STRING
#include "system.h"

#include "assert.h"
#include "trace.h"
#include "misc.h"

int
  traceallocate,
  traceassign,
  traceatctsort,
  tracebuiltins,
  tracecall,
  traceccalls,
  tracecheckpoint,
  traceconform,
  traceconformfailure,
  tracecopy,
  tracectinfo,
  tracedbm,
  tracedebug,
  tracedebuginfo,
  tracedelay,
  tracedoto,
  traceemit,
  traceemitmove,
  traceenvironment,
  tracefindct,
  tracefold,
  tracegraph,
  tracehandler,
  tracehelp,
  traceimports,
  traceindex,
  traceinitiallies,
  traceinterpret,
  traceinvoccache,
  tracekernel,
  traceknowct,
  traceknowlocal,
  traceknowmanifest,
  tracegenerate,
  tracelinenumber,
  tracelocals,
  tracemanifest,
  tracemap,
  tracematchat,
  tracememory,
  tracemessage,
  traceoid,
  tracepasses,
  traceprimitive,
  traceprocess,
  tracerelocation,
  tracescc,
  tracesys,
  tracetempl,
  tracetempreg,
  tracetempstack,
  tracetrans,
  tracetypecheck,
  tracestreams,
  tracerinvoke,
  tracegaggle,
  tracedistgc,
  tracelocate,
  tracedist,
  traceunavailable,
  tracefailure = 1
;

typedef struct {
  char *name;
  int  *flag;
} flagTable, *flagTablePtr;

flagTable table [] = {
  { "help", &tracehelp },
  { "index", &traceindex },
  { "templ", &tracetempl },
  { "trans", &tracetrans },
  { "map", &tracemap },
  { "passes", &tracepasses },
  { "interpret", &traceinterpret },
  { "call", &tracecall },
  { "fold", &tracefold },
  { "sys", &tracesys },
  { "memory", &tracememory },
  { "process", &traceprocess },
  { "initiallies", &traceinitiallies },
  { "checkpoint", &tracecheckpoint },
  { "ctinfo", &tracectinfo },
  { "debug", &tracedebug },
  { "conform", &traceconform },
  { "relocation", &tracerelocation },
  { "oid", &traceoid },
  { "ccalls", &traceccalls },
  { "streams", &tracestreams },
  { "rinvoke", &tracerinvoke },
  { "gaggle", &tracegaggle },
  { "distgc", &tracedistgc },
  { "locate", &tracelocate },
  { "dist", &tracedist },
  { "unavailable", &traceunavailable },
  { "failure", &tracefailure },
  { NULL, 0 },
};

static FILE *tracefile;
static char *tracebuffer, *tracebufferpointer;
static int tracebuffersize;

static void updatetracebufferpointer(void)
{
  while (*tracebufferpointer) tracebufferpointer++;
  if (tracebufferpointer >= tracebuffer + tracebuffersize) {
    memmove(tracebuffer, tracebuffer + tracebuffersize, tracebufferpointer - (tracebuffer + tracebuffersize));
    tracebufferpointer -= tracebuffersize;
  }
}

void toLower(char *s)
{
  register char c;
  while ((c = *s)) {
    if (c >= 'A' && c <= 'Z') *s += ('a' - 'A');
    s++;
  }
}

char *find(char *s, char c)
{
  register char theC;
  while ((theC = *s) && theC != c) s++;
  return(theC == c ? s : NULL);
}

void setTrace(char *name, int value)
{
  register flagTablePtr tp;
  for (tp = &table[0]; tp->name; tp++) {
    if (!strcmp(name, tp->name)) {
      *tp->flag = value;
      break;
    }
  }
  if (tp->name == NULL) {
    ftrace("Unknown trace name \"%s\"", name);
  }
}

int parseTraceFlag(char *f)
{
  char *comma, *equals;
  int value;

  if (f[0] == '-' && f[1] == 'T') f += 2;
  toLower(f);
  while (f && *f) {
    comma = find(f, ',');
    if (comma != NULL) *comma = '\0';
    equals = find(f, '=');
    if (equals == NULL) equals = find(f, '-');
    if (equals == NULL) {
      value = 1;
    } else {
      value = mstrtol(equals+1, 0, 0);
      if (value <= 0) value = 1;
      *equals = '\0';
    }
    setTrace(f, value);
    f = (comma == NULL ? NULL : comma + 1);
  }
  return(1);
}

void SetTraceFile(char *filename)
{
  FILE *f;
  if ((f = fopen(filename, "wb"))) {
    tracefile = f;
  } else {
    ftrace("Can't open the trace file \"%s\" for writing", filename);
  }
}

void SetTraceBufferSize(int size)
{
  tracebuffersize = size;
  tracebuffer = malloc(tracebuffersize + 256);
  memset(tracebuffer, 0, tracebuffersize);
  tracebufferpointer = tracebuffer;
}

void TraceFin(void)
{
  char *head;
  if (tracebuffer) {
    for (head = tracebufferpointer; head < tracebuffer + tracebuffersize && *head == '\0'; head++) ;
    if (head < tracebuffer + tracebuffersize) {
      fwrite(head, 1, tracebuffer + tracebuffersize - head, tracefile);
    }
    fwrite(tracebuffer, 1, tracebufferpointer - tracebuffer, tracefile);
    fflush(tracefile);
    free(tracebuffer);
    tracebuffer = tracebufferpointer = 0;
    tracebuffersize = 0;
  }
}

#define USEDIFFS
#ifdef USEDIFFS
static struct timeval original;
#endif
void TraceInit(void)
{
#ifdef USEDIFFS
  gettimeofday(&original, 0);
#endif
  tracefile = stdout;
}

void traceTS(int level)
{
#ifdef USEDIFFS
  extern struct timeval TimeMinus(struct timeval, struct timeval);
#endif
  struct timeval print, now;

  gettimeofday(&now, 0);
#ifdef USEDIFFS
  print = TimeMinus(now, original);
#else
  print = now;
#endif
  if (tracebufferpointer) {
    sprintf(tracebufferpointer, "%5d.%06d: ", (int)print.tv_sec%100000, (int)print.tv_usec);
    updatetracebufferpointer();
  } else {
    fprintf(tracefile, "%5d.%06d: ", (int)print.tv_sec%100000, (int)print.tv_usec);
  }
  while (--level > 0) {
    if (tracebufferpointer) {
      tracebufferpointer[0] = ' ';
      tracebufferpointer[1] = '\0';
      updatetracebufferpointer();
    } else {
      putc(' ', tracefile);
    }
  }
}
  
/*VARARGS2*/
#ifdef STDARG_WORKS
void ftrace(char *format, ...)
#else
void ftrace(char *format, int a, int b, int c, int d, int e, int f)
#endif
{
#ifdef STDARG_WORKS
  va_list ap;
  va_start(ap, format);
  if (tracebufferpointer) {
    vsprintf(tracebufferpointer, format, ap);
    updatetracebufferpointer();
  } else {
    vfprintf(tracefile, format, ap);
  }
  va_end(ap);
#else
  if (tracebufferpointer) {
    sprintf(tracebufferpointer, format, a, b, c, d, e, f);
    updatetracebufferpointer();
  } else {
    printf(format, a, b, c, d, e, f);
  }
#endif
  if (tracebufferpointer) {
    tracebufferpointer[0] = '\n';
    tracebufferpointer[1] = '\0';
    updatetracebufferpointer();
  } else {
    putc('\n', tracefile);
    fflush(tracefile);
  }
}
