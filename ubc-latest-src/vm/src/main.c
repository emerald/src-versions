#define E_NEEDS_SOCKET
#define E_NEEDS_SIGNAL
#include "system.h"

#include "vm_exp.h"
#include "types.h"
#include "iisc.h"
#include "trace.h"
#include "assert.h"
#include "trace.h"
#include "iset.h"
#include "globals.h"
#include "misc.h"
#include "read.h"
#include "io.h"
#include "dist.h"
#include "gaggle.h"
#include "mqueue.h"
#include "timer.h"

extern MQueue incoming;
ISet allProcesses;
ISet running;
extern int traceprocess;

#include "squeue.h"
SQueue ready;
extern char *gRootNode;
int doDistribution = 0;
#ifdef PROFILEINVOKES
IISc invokeprofile, opvectorentry2ct;
#endif

int beVerbose = 0, doInvokeProfiling = 0, dontExecute = 0;
int activelyInitialize = 1;
extern int errno;
int doCompression = 0, writeCP = 0;
int runningProcesses = 0;
int debugInteractively = 0;
int gotsigint = 0;
int checkSameUser = 1;
int offsetbyuserid = 1;
int fakeUnavailable = 0;
int debugFirst = 0;
extern int checkpointBuiltins;
extern void statistics(void);

void die(void)
{
  statistics();
  TraceFin();
  exit(1);
}

#if !defined(EMERALD_MYRINET)
void sigdie(int signalnumber)
{
#ifdef SINGLESTEP
  if (debugInteractively) {
    if (ISetSize(running) > 0) {
      if (instructionsToExecute != 1) {
	instructionsToExecute = 1;
	gotsigint = 1;
      }
    } else if (ISetSize(allProcesses) > 0) {
      debug((State *)ISetSelect(allProcesses), "Interrupt");
    } else {
      fprintf(stderr, "Can't debug (no processes)\n");
      beVerbose = 1;
      die();
    }
  } else {
#endif
    beVerbose = 1;
    showAllProcesses(0, 1);
    die();
#ifdef SINGLESTEP
  }
#endif
}
#endif

extern int p_bytesPerGeneration, p_copyCount, p_old_size, 
           p_guaranteeInterGcInterval;
extern int bytesPerGeneration, copyCount, old_size;
extern void gc_init(void (*)(void), void (*)(void), void (*)(void), void (*)(void));
extern void gc_stats (int *tg, int *og, int *n, int *no, int *nd, int *ndr);
extern void init_nodeinfo(void), sysinit(void);
extern int parseTraceFlag(char *), init_upcall(void), interpret(struct State *);

int ac;
char **av;

void startProcesses(void)
{
  IISc temp;
  int why;
  Object anElem;

  if (!processes) return;
  temp = processes;
  processes = 0;
  while (IIScSize(temp) > 0) {
    anElem = (Object) IIScSelect(temp, &why);
    run(anElem, why, 1);
    IIScDelete(temp, (int)anElem);
  }
  IIScDestroy(temp);
  {
    extern int activelyInitialize;
    extern IISc tobeinitialized;
    int value;
    Object o;

    if (activelyInitialize && tobeinitialized) {
      while (IIScSize(tobeinitialized) > 0) {
	o = (Object)IIScSelect(tobeinitialized, &value);
	tryToInit(o);
	IIScDelete(tobeinitialized, (int)o);
      }
      IIScDestroy(tobeinitialized);
      tobeinitialized = 0;
    }
  }
}

void processEverythingOnce(void)
{
  State *r;
  extern int timeAdvanced, inDebugger;

  checkForIO(MQueueSize(incoming) == 0 && SQueueSize(ready) == 0 ? 1 : 0);
  if (timeAdvanced) { timeAdvanced = 0 ; checkForTimeouts(); }
#ifdef DISTRIBUTED
  if (MQueueSize(incoming) > 0) serveRequest();
#endif
  if (SQueueSize(ready) > 0 && !inDebugger) {
    r = SQueueRemove(ready);
    assert(r);
    TRACE(process, 3, ("Running process %x", r));
    ISetInsert(running, (int)r);
    interpret(r);
    ISetDelete(running, (int)r);
  }
}

extern int nProcessesDelayed;

int stuffToDo(void)
{
  return SQueueSize(ready) > 0 || nProcessesDelayed > 0;
}

void processEverything(void)
{
  while (doDistribution ? 1 : stuffToDo()) {
    processEverythingOnce();
  }
}

#ifdef DISTRIBUTED
int nMessagesSent, nMessagesReceived, nBytesSent, nBytesReceived;
#endif

void makeReady(State *state)
{
  assert((int)state != -1);
  if (RESDNT(state->op->flags)) {
    SQueueInsert(ready, state);
#if DISTRIBUTED
  } else {
    returnToForeignObject(state, JNIL);
#endif
  }
}

int isReady(State *state)
{
  State *astate;
  assert((int)state != -1);
  SQueueForEach(ready, astate) {
    if (astate == state) return 1;
  } SQueueNext();
  return 0;
}

void hack_mainp(void *arg)
{
  int doDefault = 1, x, value;

  assert(sizeof(Bits32) == 4);
  assert(sizeof(Bits16) == 2);
  assert(sizeof(Bits8)  == 1);
  assert(sizeof(void *) >= 4);

  ready = SQueueCreate();

  start_times();
  CallInit();
  ReadInit();
  OIDToObjectInit();
#ifdef DISTRIBUTED
  initGaggle();
#endif
  allProcesses = ISetCreate();
  running = ISetCreate();

  ac--;
  av++;
  while (ac > 0) {
    if (av[0][0] == '-') {
      x = 1;
      value = 1;
      if (av[0][x] == '-') {
	value = ! value;
	x++;
      }
      switch (av[0][x]) {
      case '1':
	activelyInitialize = value;
	break;
      case 'f':
	++x;
	value = mstrtol(&av[0][x], 0, 0);
	fakeUnavailable = value;
	if (fakeUnavailable < 1) fakeUnavailable = 1;
	if (fakeUnavailable > 100) fakeUnavailable = 100;
	break;
      case 'F':
	SetTraceFile(&av[0][x+1]);
	break;
      case 'T':
	parseTraceFlag(av[0]);
	break;
      case 'v':
	beVerbose = value;
	break;
      case 'x':
	dontExecute = value;
	break;
      case 'P':
	p_guaranteeInterGcInterval = value;
	break;
      case 'p':
#ifdef PROFILEINVOKES
	if (invokeprofile == NULL)
	  invokeprofile = IIScCreate();
	if (opvectorentry2ct == NULL)
	  opvectorentry2ct = IIScCreate();
	doInvokeProfiling = value;
#else
	ftrace("Sorry, not configured for profiling");
#endif
	break;
      case 'b':
	checkpointBuiltins = value;
	break;
      case 'B':
	doDefault = ! value;
	break;
      case 'c':
	doCompression = value;
	break;
      case 't':
	x++;
	if (av[0][x]) {
	  char *rest;
	  int t = mstrtol(&av[0][x], &rest, 0);
	  if (*rest == 'k' || *rest == 'K') t *= 1024;
	  if (*rest == 'm' || *rest == 'M') t *= 1024 * 1024;
	  SetTraceBufferSize(t);
	}
	break;
      case 'g':
	x++;
	if (av[0][x]) {
	  char *rest;
	  int t = mstrtol(&av[0][x], &rest, 0);
	  if (*rest == 'k' || *rest == 'K') t *= 1024;
	  if (*rest == 'm' || *rest == 'M') t *= 1024 * 1024;
	  p_bytesPerGeneration = (t + 3) & ~3;
	}
	break;
      case 's':
	x++;
	if (av[0][x]) {
	  char *rest;
	  int t = mstrtol(&av[0][x], &rest, 0);
	  if (*rest == 'k' || *rest == 'K') t *= 1024;
	  if (*rest == 'm' || *rest == 'M') t *= 1024 * 1024;
	  stackSize = (t + 1023) & ~1023;
	}
	break;
      case 'O':
	x++;
	if (av[0][x]) {
	  char *rest;
	  int t = mstrtol(&av[0][x], &rest, 0);
	  if (*rest == 'k' || *rest == 'K') t *= 1024;
	  if (*rest == 'm' || *rest == 'M') t *= 1024 * 1024;
	  p_old_size = t;
	}
	break;
      case 'G':
	x++;
	if (av[0][x]) {
	  char *rest;
	  int t = mstrtol(&av[0][x], &rest, 0);
	  p_copyCount = t;
	}
	break;
      case 'i':
	debugInteractively = value;
	break;
      case 'I':
	debugFirst = value;
	if (value) debugInteractively = 1;
	break;
      case 'u':
	offsetbyuserid = value;
	break;
      case 'U':
	checkSameUser = 0;
	break;
      case 'C':
	if (doDefault) {
	  gc_init(0, 0, 0, 0);
	  DoCheckpointFromFile(0);
	  doDefault = 0;
	}
	writeCP = value;
	doCompression = 1;
	dontExecute = 1;
	beVerbose = 1;
	break;
      case 'S':
#if defined(DISTRIBUTED)
	doDistribution = 1;
	gRootNode = "search";
#else
	fprintf(stderr, "emx: not compiled for distribution (DISTRIBUTED)\n");
#endif
	break;
      case 'R':
#if defined(DISTRIBUTED)
	doDistribution = 1;
	x++;
	if (av[0][x]) {
	  gRootNode = &av[0][x];
	} else {
	  gRootNode = "here";
	}
#else
	fprintf(stderr, "emx: not compiled for distribution (DISTRIBUTED)\n");
#endif
	break;
      default:
	ftrace("emx: Unknown flag \"%s\"", av[0]);
      }
    } else if ((av[0][0] == ' ' && av[0][1] == '\0') ||
               (av[0][0] == ' ' && av[0][1] == ' ' && av[0][2] == '\0')) {
      /* ignore it */
    } else {
      if (doDefault) {
	gc_init(0, 0, 0, 0);
	DoCheckpointFromFile(0);
	doDefault = 0;
      }
      gc_init(0, 0, 0, 0);
      DoCheckpointFromFile(av[0]);
    }
    ac--;
    av++;
  }
  if (doDefault) {
    gc_init(0, 0, 0, 0);
    DoCheckpointFromFile(0);
    doDefault = 0;
  }

  if (dontExecute) { return; }
  initGlobals();
  init_nodeinfo();
  init_upcall();
  sysinit();

  runningProcesses = 1;
  startProcesses();
  /*
   * Don't actively initialize moved in objects, this is only interesting
   * for initially reading the checkpoint file.
   */
  activelyInitialize = 0;
  receivingObjects = 1;

  processEverything();
  statistics();
  TraceFin();
  exit(0);
}

int main( int argc, char **argv )
{
#ifdef alpha
  /* Try to get these right */
  int i;
  ac = argc;
  av = vmCalloc(ac, sizeof(char *));
  for (i = 0; i < ac; i++) {
    av[i] = argv[i];
  }
#else
  ac = argc; av = argv;
#endif

  srandom(time(0));
#ifdef WIN32
  {
	  WORD wVersionRequested = MAKEWORD(1, 1);
	  WSADATA wsaData;
	  if (WSAStartup(wVersionRequested, &wsaData)) {
		  fprintf(stderr, "WSA Startup failed.\n");
		  exit(1);
	  }
  }
#endif /* WIN32 */
  TraceInit();
  DInit();
  IOInit();
  if( InitDist() < 0 ) abort();
  TimerInit();
  hack_mainp(0);
  return 0;
}

IISc processes;

void scheduleProcess(Object o, int opIndex)
{
  if (runningProcesses) {
    run(o, opIndex, 1);
  } else {
    if (!(int)processes) processes = IIScCreate();
    IIScInsert(processes, (int)o, opIndex);
  }
}

#if defined(_SC_PAGE_SIZE) && !defined(ibm) && !defined(sgi) && !defined(alpha)
size_t getpagesize(void)
{
  return sysconf(_SC_PAGE_SIZE);
}
#endif

#if defined(m88k)
getpagesize()
{
  return 4096;
}
#endif

void statistics(void)
{
  if (beVerbose) {
    int tg, og, time;
    int n, no, nd, ndremoved;
    extern long long totalbytecodes;

    time = currentCpuTime();
    
    printf("Executed %lld bytecodes in %d.%02d seconds\n", 
	   totalbytecodes, time/100, time%100);
    gc_stats(&tg, &og, &n, &no, &nd, &ndremoved);
    if (n > 0) {
      if (bytesPerGeneration % 1024 == 0) {
	printf("%d gcs in %d*%d*%dk = %d Kbytes, time %d.%02d\n", n,
	       copyCount==1?1:2, copyCount, bytesPerGeneration / 1024, 
	       bytesPerGeneration * copyCount * (copyCount==1?1:2)/1024,
	       tg/100,tg%100);
      } else {
	printf("%d gcs in %d*%d*%d = %d bytes, time %d.%02d\n", n,
	       copyCount==1?1:2, copyCount, bytesPerGeneration, 
	       bytesPerGeneration * copyCount * (copyCount==1?1:2), 
	       tg/100,tg%100);
      }
    }
    if (no > 0) {
      if (old_size % 1024 == 0) {
	printf("%d old generation gcs in %d Kbytes, time %d.%02d\n", 
	       no, old_size/1024, og/100, og%100);
      } else {
	printf("%d old generation gcs in %d bytes, time %d.%02d\n", 
	       no, old_size, og/100, og%100);
      }
    }
#ifdef DISTRIBUTED
    if (nd > 0) {
		printf("%d distributed gcs freed %d objects\n", nd, ndremoved);
	}
    printf("Received %d messages (%d bytes), sent %d messages (%d bytes)\n",
	   nMessagesReceived, nBytesReceived, nMessagesSent, nBytesSent);
#endif
#ifdef PROFILEINTERPRET
    outputProfile();
#endif
  }
#ifdef PROFILEINVOKES
  if (doInvokeProfiling)
    outputInvokeProfile();
#endif
  return;
}

#undef abort
void myabort(void)
{
  abort();
}

void FatalError(char *ErrorMessage)
{
  perror(ErrorMessage);
  die();
}
