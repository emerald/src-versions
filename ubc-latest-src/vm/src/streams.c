/****************************************************************************
 File     : streams.c 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Streams package

 Modifications
 -------------

*****************************************************************************/

#define E_NEEDS_STRING
#define E_NEEDS_IOV
#include "system.h"

#include "streams.h"
#include "storage.h"
#include "assert.h"
#include "trace.h"
#include "misc.h"

typedef struct Stream {
  struct StreamBuffer  theBuffer;
  StreamSeekFunction   theSeekFn;
  StreamFunction       theUpdateFn;
  StreamFunction       theDestroyFn;
  StreamType           theType;
  void                *Hook;
} StreamRep;

int IsReadStream(Stream theStream)
{
  return theStream->theType == Read;
}

int IsWriteStream(Stream theStream)
{
  return theStream->theType == Write;
}

/*
 * Create a new stream
 */

Stream CreateStream(StreamConstructor theConstructor, void *Hook)
{
  Stream NewStream;

  assert(theConstructor->theCreateFn);

  NewStream = (Stream) vmMalloc(sizeof(StreamRep));
  if( NewStream == NULL ) return NULL;

  NewStream->theBuffer.AtEOF = 0;
  NewStream->theType = theConstructor->theType;
  NewStream->Hook = Hook;

  if( theConstructor->theCreateFn(&NewStream->theBuffer, &NewStream->Hook) ) {
    vmFree( NewStream );
    return NULL;
  }

  NewStream->theUpdateFn = theConstructor->theUpdateFn;
  NewStream->theDestroyFn = theConstructor->theDestroyFn;
  NewStream->theSeekFn = theConstructor->theSeekFn;

  return NewStream;
}

/* 
 * Destroy a stream
 */

void DestroyStream(Stream theStream)
{
  if( theStream == NULL ) return;

  if (theStream->theType == Write)
    FlushStream(theStream);

  TRACE(rinvoke, 15, ("Destroying stream %x", theStream));
  if (theStream->theDestroyFn)
    theStream->theDestroyFn(&theStream->theBuffer, &theStream->Hook);
  memset( (void*) theStream, 0, sizeof(*theStream) );
  vmFree(theStream);
}

/*
 * Steal a stream.  This makes the old reference invalid and uninteresting,
 * useful only for destroying.
 */
Stream StealStream(Stream theStream)
{
  Stream theNewStream = (Stream) vmMalloc(sizeof(StreamRep));
  TRACE(rinvoke, 5, ("Stealing the substance of stream %x to stream %x", theStream,
		     theNewStream));
  assert (theNewStream != NULL);
  memmove(theNewStream, theStream, sizeof(StreamRep));
  memset(theStream, 0, sizeof(StreamRep));
  return theNewStream;
}

/*
 * Read some bytes from a stream
 */

StreamByte *ReadStream(Stream theStream, unsigned int Bytes)
{
  StreamByte *Result;
  
  assert(theStream->theType == Read);

  /* Make sure the buffer is big enough */
  assert (theStream->theBuffer.End - theStream->theBuffer.Start >= (int)Bytes);

  if (theStream->theBuffer.ValidBytes < (int)Bytes)
    FillStream(theStream);

  if (theStream->theBuffer.ValidBytes >= (int)Bytes) {
    Result = theStream->theBuffer.Head;
    theStream->theBuffer.Head += Bytes;
    theStream->theBuffer.ValidBytes -= Bytes;
  }
  else /* Insufficient data available */
    Result = NULL;

  return Result;
}

/*
 * Peek at some bytes from a stream,
 */

StreamByte *PeekStream(Stream theStream, unsigned int Bytes)
{
  StreamByte *Result;
  
  assert(theStream->theType == Read);

  /* Make sure the buffer is big enough */
  assert (theStream->theBuffer.End - theStream->theBuffer.Start >= (int)Bytes);

  if (theStream->theBuffer.ValidBytes < (int)Bytes)
    FillStream(theStream);

  if (theStream->theBuffer.ValidBytes >= (int)Bytes) {
    Result = theStream->theBuffer.Head;
  }
  else /* Insufficient data available */
    Result = NULL;

  return Result;
}

/*
 * Write some bytes to a stream
 */

StreamByte *WriteStream(Stream theStream, unsigned int Bytes)
{
  StreamByte *Result;

  assert(theStream->theType == Write);

  /* Make sure the buffer is big enough */
  assert (theStream->theBuffer.End - theStream->theBuffer.Start >= (int)Bytes);

  if (theStream->theBuffer.End - theStream->theBuffer.Start -
      theStream->theBuffer.ValidBytes < (int)Bytes)
    FlushStream(theStream);

  if (theStream->theBuffer.End - theStream->theBuffer.Start - 
      theStream->theBuffer.ValidBytes >= (int)Bytes) {
    Result = theStream->theBuffer.Head;
    theStream->theBuffer.Head += Bytes;
    theStream->theBuffer.ValidBytes += Bytes;
  }
  else /* Insufficient space available */
    Result = NULL;

  return Result;
}

/*
 * Read some bytes from a stream into a designated buffer
 */

void ReadStreamToBuffer(Stream theStream, unsigned int Bytes,
			StreamByte *theBuffer)
{
  int BytesToCopy;

  assert(theStream->theType == Read);

  while (1) {
    if (theStream->theBuffer.ValidBytes >= (int)Bytes)
      BytesToCopy = Bytes;
    else
      BytesToCopy = theStream->theBuffer.ValidBytes;

    memmove(theBuffer, theStream->theBuffer.Head, BytesToCopy);
    theStream->theBuffer.Head += BytesToCopy;
    theStream->theBuffer.ValidBytes -= BytesToCopy;

    theBuffer += BytesToCopy;
    Bytes -= BytesToCopy;
    
    if (Bytes == 0) break;
  
    FillStream(theStream);
  }

  return;
}
  
/*
 * Write some bytes into a stream from a designated buffer
 */

void WriteStreamFromBuffer(Stream theStream, unsigned int Bytes,
			   StreamByte *theBuffer)
{
  int BytesToCopy;

  assert(theStream->theType == Write);

  while (1) {
    if (theStream->theBuffer.End - theStream->theBuffer.Start -
	theStream->theBuffer.ValidBytes >= (int)Bytes)
      BytesToCopy = Bytes;
    else
      BytesToCopy = (theStream->theBuffer.End - theStream->theBuffer.Start -
		     theStream->theBuffer.ValidBytes);

    memmove(theStream->theBuffer.Head, theBuffer, BytesToCopy);
    theStream->theBuffer.Head += BytesToCopy;
    theStream->theBuffer.ValidBytes += BytesToCopy;
    Bytes -= BytesToCopy;
    theBuffer += BytesToCopy;

    if (Bytes == 0) break;
    
    FlushStream(theStream);
  }

  return;
}
  
/*
 * Fill a stream with new data 
 */

void FillStream(Stream theStream)
{
  assert(theStream->theType == Read);

  if( theStream->theUpdateFn == NULL ) {
    theStream->theBuffer.AtEOF = 1;
    return;
  }

  memcpy(theStream->theBuffer.Start, theStream->theBuffer.Head, 
	  theStream->theBuffer.ValidBytes);
  theStream->theBuffer.Head = theStream->theBuffer.Start;
  
  theStream->theBuffer.ValidBytes += 
    theStream->theUpdateFn(&theStream->theBuffer, &theStream->Hook);
}

/*
 * Flush a stream
 */

void FlushStream(Stream theStream)
{
  int BytesWritten;
  
  assert(theStream->theType == Write);
  assert(theStream->theUpdateFn);

  if (theStream->theBuffer.ValidBytes > 0) {
    BytesWritten = theStream->theUpdateFn(&theStream->theBuffer, 
					  &theStream->Hook);
    theStream->theBuffer.ValidBytes -= BytesWritten;
    theStream->theBuffer.Head -= BytesWritten;
  }
}

/*
 * Seek to a given position in a stream
 */

void SeekStream(Stream theStream, unsigned int Position)
{
  assert(theStream->theSeekFn);

  theStream->theSeekFn(&theStream->theBuffer, &theStream->Hook, Position);
}

/*
 * Rewind a stream
 */

void RewindStream(Stream theStream)
{
  SeekStream(theStream, 0);
}

/*
 * Determine whether or not a stream is at the end of file
 */

int StreamLength(Stream theStream)
{
  assert(theStream->theBuffer.AtEOF);
  return theStream->theBuffer.ValidBytes;
}

short AtEOF(Stream theStream)
{
  return theStream->theBuffer.AtEOF && !theStream->theBuffer.ValidBytes;
}

/*
 * Get at the private stream data from its abstract type
 */

void GetStreamData( Stream str, StreamBuffer *buf, void **Hook )
{
  *buf = &str->theBuffer;
  *Hook = str->Hook;
}

/* EOF */
