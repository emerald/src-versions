/* threads.c - threads abstractions (for MTHREADS)
 */

#pragma warning(disable: 4068)
#pragma pointer_size long
#include <stdio.h>
#include <stdlib.h>
#pragma pointer_size short
#include "threads.h"
#include "types.h"
#include "trace.h"
#include "read.h"
#include "write.h"
#include "assert.h"
#include "misc.h"
#include "vm_exp.h"

extern int nMessagesSent, nMessagesReceived, nBytesSent, nBytesReceived;
#ifdef WIN32
extern semaphore theBigLock;
#endif /* not WIN32 */

#if defined(MALLOCPARANOID)
#if 1
static FILE *junk;
#define PMEXTRA 0
#define MAXBLOCKS 1024
#define TRWINDOW 1
static int trindex = 0;
typedef struct {
  char command;
  short size;
  void *buf1, *buf2;
  unsigned NodeAddr;
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
  trbuf[trindex].NodeAddr = MTGetCurrentNodeAddr();
  trindex = (trindex + 1) % TRWINDOW;
  if (trindex == 0) trdump();
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
    printf("%08x: [%4d] %c %d ", trbuf[j].NodeAddr, j, trbuf[j].command, trbuf[j].size);
    if (trbuf[j].command == 'R')
      printf(" %x", trbuf[j].buf2);
    printf(" -> %x\n", trbuf[j].buf1);
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
  
void *vmMalloc(a)
{
  unsigned *t = (unsigned *)malloc(((a + 3)&~3) + (8 + PMEXTRA) * sizeof(int));

  /*  if (!junk) junk = fopen("junk", "w");*/
  setupOne(t, a);
  rememberOne(t);
  trm('M', a, &t[4], 0);
  /*  fprintf(junk, "M %d -> %#x\n", a, &t[4]); fflush(junk); */
  checkAll();
  return (void *)&t[4];
}

void *vmRealloc(void *old, int b)
{
  int a;
  unsigned *t = (unsigned *)old - 4;
  a = t[2];
  checkOne(t);
  forgetOne(t);
  t = (unsigned *)realloc(t, ((b + 3)&~3) + (8 + PMEXTRA) * sizeof(int));
  setupOne(t, b);
  rememberOne(t);
  trm('R', b, &t[4], old);
  /*  fprintf(junk, "R %#x[%d] %d -> %#x\n", old, a, b, &t[4]); fflush(junk); */
  checkAll();
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
  checkAll();
  checkOne(t);
  a = t[2];
  forgetOne(t);
  trm('F', a, old, 0);
  /*  fprintf(junk, "F %#x[%d]\n", old, a); fflush(junk); */
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
#ifdef MTHREADS

#ifdef WIN32MALLOCDEBUG
_CrtMemState onceinitialized;
#endif

int
vmInitThreads()
{
  extern Node MyNode;
  extern OID MyBaseOID;
  int port;
  char *plane;
  extern char *getenv(const char *);

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

  MyNode.Epoch = random() & 0xffff;
  /* start up the network subsystem */
  port = EMERALDFIRSTPORT + getplane();

  while (MTNetStart(0,  port, MyNode.Epoch) != 0) {
    port = EMERALDPORTPROBE(port);
    if (port > 0x10000) return -1;
  }
  MyNode.IPAddress = myid.ipaddress;
  MyNode.EmeraldInstance = myid.port;
  MyNode.Epoch = myid.incarnation;
  MyBaseOID.IPAddress = ntohl(MyNode.IPAddress);
  MyBaseOID.EmeraldInstance = MyNode.EmeraldInstance;
  MyBaseOID.Epoch = MyNode.Epoch;

  return 0;
}

#ifndef WORKERSTACKSIZE
#define WORKERSTACKSIZE (32 * 1024)
#endif

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

char *NodeAddrString(NodeAddr srv)
{
  static char buf[5][60];
  static int i = 0;
  char *rval;

  rval = buf[i]; i = (i+1) % 5;
  sprintf(rval, "%08lx.%04x.%04x", srv.ipaddress, srv.port, srv.incarnation);
  return rval;
}
#endif /* MTHREADS */
