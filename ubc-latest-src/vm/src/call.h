#ifndef _EMERALD_CALL_H
#define _EMERALD_CALL_H

#ifndef _EMERALD_IISC_H
#include "iisc.h"
#endif

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

typedef enum { RFine = 0,
	       RInitially = 1,
	       RRemote = 2,
	       RDead = 4 }
    Reason;

extern IISc allfrozen;

extern int isReason(int why, Reason r);
extern int reasonToIndex(int why);

OpVectorElement findOpVectorElement(ConcreteType cp, unsigned int pc);
int findOpVectorIndex(ConcreteType cp, unsigned int pc);
void CallInit(void);
void returnToForeignObject(struct State *state, int answer);
int returnToBrokenObject(struct State *state);
void pushAR(struct State *state, Object obj, ConcreteType ct, int opindex);
void pushBottomAR(struct State *state);
void dependsOn(struct State *, struct State *, int);
struct State *stateFetch(OID oid, Node loc);
extern int isBroken(Object obj);
extern int duringInitialization(Object obj);
extern int findHandler(struct State *state, int name, Object o);
#endif /* _EMERALD_CALL_H */
