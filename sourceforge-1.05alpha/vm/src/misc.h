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

#ifndef _EMERALD_MISC_H
#define _EMREALD_MISC_H

#include "types.h"
#include "storage.h"

#ifndef _EMERALD_DIST_H
#include "dist.h"
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

#define FINDCODEBODY(pc, result, ct, theId) {\
  OpVector ov = (ct)->d.opVector;\
  OpVectorElement ope;\
  int i;\
  (result) = 0;\
  for (i = 3; i < ov->d.items; i++) {\
    ope = ov->d.data[i];\
    if (ope->d.id == (theId)) {\
      PROFILEBUMP(pc, ope,ct);\
      (result) = (unsigned int)(ope->d.code->d.data);\
      break;\
    }\
  }\
  if ((result) == 0){\
    fprintf(stderr,"FindCode: op %s id %d undefined for ct %.*s (0x%08x)\n",\
            OperationName(theId),(theId),\
	    (ct)->d.name->d.items,\
	    (ct)->d.name->d.data,\
	    (ct));\
    DEBUG("");\
  }\
}

#define FINDCODE(pc, result, x, y) FINDCODEBODY(pc, result, x, y)

#define FINDOVE(result, ct, theId) {\
  if (ISNIL(ct)) { \
    (result) = 0; \
  } else { \
    OpVector ov = (ct)->d.opVector;\
    OpVectorElement ope;\
    int i;\
    (result) = 0;\
    for (i = 3; i < ov->d.items; i++) {\
      ope = ov->d.data[i];\
      if (ope->d.id == (theId)) {\
	(result) = i; \
	break;\
      }\
    }\
    if ((result) == 0){\
      fprintf(stderr,"FindCode: op %s id %d undefined for ct %.*s (0x%08x)\n",\
	      OperationName(theId),(theId),\
	      (ct)->d.name->d.items,\
	      (ct)->d.name->d.data,\
	      (u32)(ct));\
      DEBUG("");\
    }\
  } \
}

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
