#ifndef _EMERALD_LOCATE_H
#define _EMERALD_LOCATE_H

#ifndef _EMERALD_ISET_H
#include "iset.h"
#endif

#ifndef _EMERALD_OISC_H
#include "oisc.h"
#endif

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#ifndef _EMERALD_DIST_H
#include "dist.h"
#endif

#ifndef _EMERALD_RINVOKE_H
#include "rinvoke.h"
#endif

#define LOCATE_TIMES_TO_TRY 5

typedef struct locationRecord {
  OID  oid, ctoid;
  enum { LEasy, LAggressive } stage;
  int count;
  ISet outstandingRequests;
  ISet waitingStates;
  ISet waitingMsgs;
} locationRecord;

extern OISc outstandingLocates;

extern void aggressivelyLocate(Object);
extern void locateHandleDown(noderecord *nd);
#endif
