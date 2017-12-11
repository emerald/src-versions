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

#ifndef _EMERALD_WRITE_H
#define _EMERALD_WRITE_H

#include "types.h"
#include "read.h"
#include "streams.h"

extern int checkpointBuiltins;
extern void (*checkpointCallback)(Object);
extern void (*checkpointCTCallback)(Object);
void (*checkpointCTIntermediateCallback)(int (*)(IISc, Object), IISc);
extern int isABuiltin(Object);
extern void Checkpoint(Object o, ConcreteType ct, Stream theFile);
extern void CheckpointToFile(Object o, ConcreteType ct, String file);
extern void FigureSize(Object o, ConcreteType c);
extern void WriteOID(OID *oid, Stream theStream);
extern Stream OpenCheckpointFile(char *cpfile);
extern void WriteTheCheckpointStream(Stream theStream, 
				     CheckpointData *theContents);

#endif /* _EMERALD_WRITE_H */
