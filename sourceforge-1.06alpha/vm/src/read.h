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

#ifndef _EMERALD_READ_H
#define _EMERALD_READ_H

#include "types.h"
#include "array.h"
#include "iisc.h"
#include "oisc.h"
#include "iosc.h"
#include "streams.h"
#include "dist.h"

/*typedef struct LFE {
  OID    oid;
  Object ptr;
} LFE;
*/
#define filesizeofLFE 16

typedef enum Signature {
  ObjectWithID = 0, 
  ObjectWithoutID = 1, 
  Extern = 2, 
  AbConObj = 3, 
  MakeObject = 4, 
  Comment = 5, 
  SigNone = 6,
  Stub = 7,
  VectorStub = 8,
  SQ = 9,
  SigError = 10
  } Signature;

#define NUM_SIGNATURES 10
#define filesizeofSignature 4
#define filesizeofObjectDescriptor 4
extern char signatures[NUM_SIGNATURES + 1][filesizeofSignature];

/*
 * Here is the structure of a failure handler entry
 */
struct FHE {
  unsigned short blockStart;
  unsigned short blockEnd;
  unsigned short handlerStart;
  unsigned short variableOffset;
  unsigned int name;
};
struct FHC {
  unsigned short count;
  char h;
  char c;
};

/*
 * Relocation item descriptor.  This is for missing objects that are later
 * loaded.  
 */
typedef struct relocation {
  Object o;
  int offset;
} Relocation;

extern OISc relocationMap;

typedef struct CheckpointData {
  array Objects;
  array MakeObjects;
  array AbCons;
  IOSc  Externs;
} CheckpointData;

extern int  fixLiterals(Code c);
extern char *findHisTemplate(ConcreteType ct);
extern void ReadOID(OID *oid, Stream theStream);
extern Object DoCheckpoint(Stream theFile, char *cpfile);
extern Object ExtractObjects(Stream theFile, Node srv);
extern void DoCheckpointFromFile(char *cpfile);

extern void ReadInit(void);
#endif /* _EMERALD_READ_H */
