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
	jlocate(struct State *);

extern int (*(sysfuncs[]))(struct State *),
	(*(xfuncs[]))(int *);
extern void initGlobals(void);

#endif /* _EMERALD_GLOBALS_H */
