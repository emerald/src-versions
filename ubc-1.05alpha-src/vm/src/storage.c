/*
 * storage.c - storage allocation functions, used only for debugging storage
 * leaks and overruns and such.
 */
#define E_NEEDS_STRING
#include "system.h"

#include "dist.h"
#include "types.h"
#include "trace.h"
#include "read.h"
#include "write.h"
#include "assert.h"
#include "misc.h"
#include "vm_exp.h"

#if defined(MALLOCPARANOID)
#if 1
/* static FILE *junk; */
#define PMEXTRA 0
#define MAXBLOCKS 1024
#define TRWINDOW 1024
static int trindex = 0;
typedef struct {
  char command;
  int size;
  void *buf1, *buf2;
} trrec;
trrec trbuf[TRWINDOW];
#define lassert(b) if (!(b)) { printf("lassert failure at %s, %d\n", __FILE__, __LINE__); trdump(); fflush(stdout); abort(); }
void trdump(void);

static void trm(char c, int size, void *buf1, void *buf2)
{
  trbuf[trindex].command = c;
  trbuf[trindex].size = size;
  trbuf[trindex].buf1 = buf1;
  trbuf[trindex].buf2 = buf2;
  trindex = (trindex + 1) % TRWINDOW;
#if 0
  if (trindex == 0) trdump();
#endif
#if 0
  if (c == 'M') {
    int i = (trindex - 2 + TRWINDOW) % TRWINDOW;
    while (i != trindex) {
      if (trbuf[i].command == 'R' && trbuf[i].buf2 == buf1) break;
      if (trbuf[i].buf1 == buf1) {
	lassert(trbuf[i].command == 'F');
	break;
      }
      i = (i - 1 + TRWINDOW) % TRWINDOW;
    }
  }
#endif
}

void trdump(void)
{
  int i, j;
  for (i = 0; i < TRWINDOW; i++) {
    j = (trindex + i) % TRWINDOW;
    if (!trbuf[j].command) continue;
    printf("[%4d] %c %d ", j, trbuf[j].command, trbuf[j].size);
    if (trbuf[j].command == 'R')
      printf(" %x", (unsigned int)trbuf[j].buf2);
    printf(" -> %x\n", (unsigned int)trbuf[j].buf1);
  }
  fflush(stdout);
}

static unsigned *allblocks[MAXBLOCKS];

static void setupOne(unsigned *t, int b)
{
  int i;
  t[0] = 0xaaaabbbb;
  t[1] = 0xbbbbcccc;
  t[2] = b;
  t[3] = (unsigned)t;
  t[((b + 3)>>2) + 4] = 0xccccdddd;
  t[((b + 3)>>2) + 5] = 0xddddeeee;
  t[((b + 3)>>2) + 6] = 0xeeeeffff;
  t[((b + 3)>>2) + 7] = 0xffffaaaa;
  for (i = 0; i < PMEXTRA; i++) {
    t[((b + 3)>>2) + 8 + i] = 0xffffaaaa + i;
  }
}

static void checkOne(unsigned *t)
{
  int a, i;
  lassert(t[0] == 0xaaaabbbb);
  lassert(t[1] == 0xbbbbcccc);
  a = t[2];
  lassert(t[3] == (unsigned)t);
  lassert(t[((a + 3)>>2) + 4] == 0xccccdddd);
  lassert(t[((a + 3)>>2) + 5] == 0xddddeeee);
  lassert(t[((a + 3)>>2) + 6] == 0xeeeeffff);
  lassert(t[((a + 3)>>2) + 7] == 0xffffaaaa);
  for (i = 0; i < PMEXTRA; i++) {
    lassert(t[((a + 3)>>2) + 8 + i] == 0xffffaaaa + i);
  }
}

void checkAll(void)
{
  int i;
  return;
  for (i = 0; i < MAXBLOCKS; i++) {
    if (allblocks[i] != NULL) {
      checkOne(allblocks[i]);
    }
  }
}

void rememberOne(unsigned *t)
{
  int i;
  return;
  for (i = 0; i < MAXBLOCKS; i++) {
    if (allblocks[i] == 0) {
      allblocks[i] = t;
      return;
    }
  }
  assert(0);
}

void forgetOne(unsigned *t)
{
  int i;
  return;
  for (i = 0; i < MAXBLOCKS; i++) {
    if (allblocks[i] == t) {
      allblocks[i] = NULL;
      return;
    }
  }
  assert(0);
}
  
void *vmMalloc(int a)
{
  unsigned *t = (unsigned *)malloc(((a + 3)&~3) + (8 + PMEXTRA) * sizeof(int));

  /*  if (!junk) junk = fopen("junk", "w");*/
  setupOne(t, a);
#ifdef MALLOCREALLYPARANOID
  rememberOne(t);
#endif
  trm('M', a, &t[4], 0);
  /*  fprintf(junk, "M %d -> %#x\n", a, &t[4]); fflush(junk); */
#ifdef MALLOCREALLYPARANOID
  checkAll();
#endif
  return (void *)&t[4];
}

void *vmRealloc(void *old, int b)
{
  int a;
  unsigned *t = (unsigned *)old - 4;
  a = t[2];
  checkOne(t);
#ifdef MALLOCREALLYPARANOID
  forgetOne(t);
#endif
  t = (unsigned *)realloc(t, ((b + 3)&~3) + (8 + PMEXTRA) * sizeof(int));
  setupOne(t, b);
#ifdef MALLOCREALLYPARANOID
  rememberOne(t);
#endif
  trm('R', b, &t[4], old);
  /*  fprintf(junk, "R %#x[%d] %d -> %#x\n", old, a, b, &t[4]); fflush(junk); */
#ifdef MALLOCREALLYPARANOID
  checkAll();
#endif
  return (void *)&t[4];
}

void *vmCalloc(int a, int b)
{
  void *t = vmMalloc(a * b);
  memset(t, 0, a * b);
  return t;
}

void vmFree(void *old)
{
  int a;
  unsigned *t = (unsigned *)old - 4;
  if (!old) return;
#ifdef MALLOCREALLYPARANOID
  checkAll();
#endif
  checkOne(t);
  a = t[2];
#ifdef MALLOCREALLYPARANOID
  forgetOne(t);
#endif
  trm('F', a, old, 0);
  /*  fprintf(junk, "F %#x[%d]\n", old, a); fflush(junk); */
  memset(t, 0, ((a + 3)&~3) + (8 + PMEXTRA) * sizeof(int));
  free(t);
}
#else
static int nmallocs, nfrees, nbigmallocs;
void *vmMalloc(int a)
{
  if (a > 40000) {
    nbigmallocs ++;
  }
  nmallocs++;
  return malloc(a);
}

void *vmRealloc(void *old, int b)
{
  if (b > 40000) {
    nbigmallocs++;
  }
  return realloc(old, b);
}
void *vmCalloc(int a, int b)
{
  if (a * b > 40000) {
    nbigmallocs ++;
  }
  nmallocs++;
  return malloc(a * b);
}

void vmFree(void *old)
{
  if (old) nfrees++;
  free(old);
}
#endif
#endif

#ifdef WIN32MALLOCDEBUG
_CrtMemState onceinitialized;
#endif

void InitStorage(void)
{
#ifdef WIN32MALLOCDEBUG
  // Send all reports to STDOUT

#define  SET_CRT_DEBUG_FIELD(a) \
       _CrtSetDbgFlag((a) | _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG))

#if 0
  // Set the debug-heap flag so that freed blocks are kept on the
  // linked list, to catch any inadvertent use of freed memory
  // You only can do this if you are allocating a few blocks
  SET_CRT_DEBUG_FIELD( _CRTDBG_DELAY_FREE_MEM_DF );
#endif

  _CrtSetReportMode( _CRT_WARN, _CRTDBG_MODE_FILE );
  _CrtSetReportFile( _CRT_WARN, _CRTDBG_FILE_STDOUT );
  _CrtSetReportMode( _CRT_ERROR, _CRTDBG_MODE_FILE );
  _CrtSetReportFile( _CRT_ERROR, _CRTDBG_FILE_STDOUT );
  _CrtSetReportMode( _CRT_ASSERT, _CRTDBG_MODE_FILE );
  _CrtSetReportFile( _CRT_ASSERT, _CRTDBG_FILE_STDOUT );
#endif
}

#ifdef WIN32MALLOCDEBUG
void vmDoneInit()
{
    // Store a memory checkpoint in the memory-state structure
	_CrtMemCheckpoint( &onceinitialized );
}

void vmMallocCheck()
{
  _CrtCheckMemory();
}

void vmMallocDump()
{
  _CrtMemState temp;
  _CrtMemCheckpoint( &temp );  
  _CrtMemDumpStatistics(&temp);

  _CrtCheckMemory( );

  /* This one dumps all objects. */
  /* _CrtDumpMemoryLeaks( ); */

  /*
   * This will only dump the objects that have been allocated
   * since the node finished initializing
   */
  _CrtMemDumpAllObjectsSince( &onceinitialized );

}


void vmMallocDumpAll()
{
  _CrtMemState temp;
  _CrtMemCheckpoint( &temp );  
  _CrtMemDumpStatistics(&temp);

  _CrtCheckMemory( );

  _CrtDumpMemoryLeaks( );
}
#endif
