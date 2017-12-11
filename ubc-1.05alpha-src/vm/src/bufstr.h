/* comment me!
 */

#ifndef _EMERALD_BUFFERSTREAMS_H
#define _EMERALD_BUFFERSTREAMS_H

#include "streams.h"

/*
 *
 * Stream       WriteToReadStream(Stream theStream, int dodestroy);
 *   This routine turns the write stream around so it can be read.
 */

extern Stream       WriteToReadStream(Stream theStream, int dodestroy);
extern StreamConstructor ReadBufferStream;
extern StreamConstructor FreeBufferStream;
extern StreamConstructor WriteBufferStream;
void BufferToIovec( Stream str, struct iovec *iov );
int BufferLength( Stream str );
char *BufferData( Stream str );

#endif /* _EMERALD_BUFFERSTREAMS_H */
