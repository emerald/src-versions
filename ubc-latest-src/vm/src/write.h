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
