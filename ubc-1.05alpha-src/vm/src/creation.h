/* comment me!
 */

#ifndef _EMERALD_CREATION_H
#define _EMERALD_CREATION_H

#include "types.h"

extern Object AllocateObject(ConcreteType p, int size);
extern Vector CreateVector(ConcreteType p, unsigned nelems);
extern Object CreateUninitializedObject(ConcreteType);
extern Object CreateObjectFromOutside(ConcreteType, unsigned int);
extern String CreateString(char *);

extern void run(Object o, int kind, int asynch);
extern void makeReady(struct State *state);
extern int isReady(struct State *state);
extern int bottomStackFrame(struct State *state);
extern void runState(struct State *state, int asynch);
void scheduleProcess(Object o, int opIndex);
struct State *newState(Object o, ConcreteType ct);
extern void tryToFindState(struct State *state);
void deleteState(struct State *);
void setupState(struct State *s, Object o, ConcreteType ct);
#endif /* _EMERALD_CREATION_H */
