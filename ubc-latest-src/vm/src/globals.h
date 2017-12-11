/* comment me!
 */

#ifndef _EMERALD_GLOBALS_H
#define _EMERALD_GLOBALS_H

#include "builtins.h"
#include "iisc.h"
#include "types.h"

/*
 * The builtin global array manages the following pointers for each builtin:
 *
 * Object it;
 * AbstractType itsAt;
 * ConcreteType itsCt;
 * AbstractType instanceAt;
 * ConcreteType instanceCt;
 */

extern Object BuiltinGlobalArray[NUMBUILTINS][NUMTAGS];

#define BuiltinGA(i,tag) (BuiltinGlobalArray[i][(int)tag])
#define Builtin(i)       (BuiltinGA(i,B_IT))
#define BuiltinAT(i)     ((AbstractType)BuiltinGA(i,B_ITSAT))
#define BuiltinCT(i)     ((ConcreteType)BuiltinGA(i,B_ITSCT))
#define BuiltinInstAT(i) ((AbstractType)BuiltinGA(i,B_INSTAT))
#define BuiltinInstCT(i) ((ConcreteType)BuiltinGA(i,B_INSTCT))

#define ROUNDUP(x) (((x) + 3) & ~0x3)

extern String TrueString, FalseString;

extern IISc processes;
extern IISc notHostedMap;
extern Node MyNode;

extern int
	getstdin(struct State *),
	getstdout(struct State *),
	gettod(struct State *),
	getlnn(struct State *),
	getname(struct State *),
	getnode(struct State *),
	getactivenodes(struct State *),
	getallnodes(struct State *),
	delay(struct State *),
	jislocal(struct State *),
	jisfixed(struct State *),
	jmove(struct State *),
	jfix(struct State *),
	junfix(struct State *),
	jrefix(struct State *),
	jlocate(struct State *),
	jgetIncarnationTime(struct State *),
	jgetLoadAverage(struct State *);

extern int (*(sysfuncs[]))(struct State *),
	(*(xfuncs[]))(int *);
extern void initGlobals(void);

#endif /* _EMERALD_GLOBALS_H */
