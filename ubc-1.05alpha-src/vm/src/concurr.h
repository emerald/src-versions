#ifndef _EMERALD_CONCURRENT_H
#define _EMERALD_CONCURRENT_H 1

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#include "squeue.h"

typedef struct monitor {
  int 		busy;
  SQueue 	waiting;
} monitor;

typedef struct condition {
  Object	o;
  SQueue	waiting;
} condition;

extern SQueue ready;
extern int runningProcesses;
#endif
