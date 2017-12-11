/* comment me!
 */

#ifndef _EMERALD_MISC_H
#define _EMREALD_MISC_H

#include "types.h"
#include "storage.h"

#ifndef _EMERALD_DIST_H
#include "dist.h"
#endif

#ifndef _EMERALD_SQUEUE_H
#include "squeue.h"
#endif

#define MAX_FILE_DESCRIPTORS 32
#define STACKSIZE (16 * 1024)
extern int stackSize;
#define CCALL_MAXARGS 11

extern void OpoidsInit(void);
extern char *OperationName(int OpID);
extern void docall(int, int, int, ConcreteType, Object, int);

#ifdef PROFILEINVOKES
extern int doInvokeProfiling;
extern void profileBump(/*pc, ove, ct*/);
extern unsigned int *currentOPECount;
#endif

struct State;
extern Object rootdir, rootdirg, node, inctm, upcallStub, locsrv, debugger;
extern int unwind(struct State *state);
void showAllProcesses(struct State *state, int levelOfDetail);
struct State *processDone(struct State *state, int fail);
extern int currentCpuTime(void);
extern void start_times(void);
void tryToInit(Object obj);
void becomeStub(Object o, ConcreteType ct, void *stub);
extern int sizeOf(Object o);
extern int sizeFromTemplate(Template t);
extern int findLineNumber(unsigned pc, Code code, Template template);
extern void showProcess(struct State *state, int levelOfDetail);
extern struct State *findAcceptable(SQueue, AbstractType);
int upcall( Object o, int fn, int *fail, int argc, int retc, int *args );
void WriteOID(struct OID *oid, Stream theStream);
void ReadOID(struct OID *oid, Stream theStream);
void ReadNode(Node *srv, Stream theStream);
void WriteNode(Node *srv, Stream theStream);
extern int mstrtol(const char *str, char **ptr, int base);
extern int unavailable(struct State *state, Object o);
#ifdef sun4
#define memmove(a, b, c) bcopy(b, a, c)
#endif
#endif /* _EMERALD_MISC_H */
