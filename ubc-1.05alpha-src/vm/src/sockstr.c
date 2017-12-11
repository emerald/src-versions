/****************************************************************************
 File     : socketstreams.c 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Socket Streams package

 Modifications
 -------------

*****************************************************************************/

#include <stddef.h>
#ifdef WIN32
#include <io.h>
#else /* not WIN32 */
#include <sys/file.h>
#endif /* not WIN32 */
#include <sys/stat.h>
#ifndef WIN32
#include <sys/socket.h>
#endif
#include "sockstr.h"
#include "error.h"
#include "memory.h"
#include "misc.h"
#include "assert.h"

/*
 * NOTE: The code in this file assumes that sizeof(int) <= sizeof(void *).
 *       The Hook pointer is used to store a file descriptor.  If this is
 *       inappropriate, set the Hook pointer to point to the file descriptor.
 */

#define READSOCKETBUFFERSIZE  4096
#define WRITESOCKETBUFFERSIZE 4096

static struct StreamConstructor ReadSocketStreamConstructor;
static struct StreamConstructor WriteSocketStreamConstructor;

StreamConstructor ReadSocketStream = &ReadSocketStreamConstructor;
StreamConstructor WriteSocketStream = &WriteSocketStreamConstructor;

static int  CreateReadSocketStream(StreamBuffer theBuffer, void **Hook);
static int  FillReadSocketStream(StreamBuffer theBuffer, void **Hook);
static int  DestroyReadSocketStream(StreamBuffer theBuffer, void **Hook);

static int  CreateWriteSocketStream(StreamBuffer theBuffer, void **Hook);
static int  FlushWriteSocketStream(StreamBuffer theBuffer, void **Hook);
static int  DestroyWriteSocketStream(StreamBuffer theBuffer, void **Hook);

static struct StreamConstructor ReadSocketStreamConstructor = {
  Read,
  CreateReadSocketStream,
  FillReadSocketStream,
  DestroyReadSocketStream,
  NULL };

static struct StreamConstructor WriteSocketStreamConstructor = {
  Write,
  CreateWriteSocketStream,
  FlushWriteSocketStream,
  DestroyWriteSocketStream,
  NULL }; 

static StreamBuffer BufferCache[MAX_FILE_DESCRIPTORS];

/*
 * Initialize a new ReadSocketStream
 *
 * Hook should point to the file descriptor of the socket.
 * This function then resets Hook to contain the file descriptor.
 */

static int
CreateReadSocketStream(StreamBuffer theBuffer, void **Hook)
{
  int   fd;

  assert(sizeof(int) <= sizeof(void *)); /* Make sure it's OK to store
					    fd in *Hook */

  fd = *((int *) *Hook);
  *((int *) Hook) = fd;

  theBuffer->Start = (StreamByte *) vmMalloc(READSOCKETBUFFERSIZE);
  theBuffer->End = theBuffer->Start + READSOCKETBUFFERSIZE;
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;

  BufferCache[fd] = theBuffer;
  RegisterFD(fd, ProcessNewSocketData);
  return 0;
}

/*
 * Fill the file buffer
 */

#ifdef WIN32
#define read _read
#define close _close
#define write _write
#endif

static int
FillReadSocketStream(StreamBuffer theBuffer, void **Hook)
{
  int fd, BytesRead;

  fd = *((int *) Hook);

  BytesRead = read(fd, theBuffer->Start + theBuffer->ValidBytes,
		   theBuffer->End - theBuffer->Start - theBuffer->ValidBytes);

  if (BytesRead < 0) {
#ifndef WIN32
    if (errno == EWOULDBLOCK)
      return 0;
    else
#endif /* not WIN32 */
      FatalError("FillReadSocketStream ");
  }
  
  if (BytesRead == 0)
    theBuffer->AtEOF = 1;

  return BytesRead;
}

/*
 * Destroy the ReadSocketStream 
 */

static int
DestroyReadSocketStream(StreamBuffer theBuffer, void **Hook)
{
  int fd;

  fd = *((int *) Hook);

  UnRegisterFD(fd);
  if (close(fd) < 0) 
    FatalError("DestroyReadSocketStream ");

  if (theBuffer->Start)
    vmFree(theBuffer->Start);
  return 0;
}

/*
 * Initialize a new WriteSocketStream
 *
 * Hook should point to a char * containing the name of the file to open.
 * This function then resets Hook to contain the file descriptor.
 */

static int
CreateWriteSocketStream(StreamBuffer theBuffer, void **Hook)
{
  int   fd;

  assert(sizeof(int) <= sizeof(void *)); /* Make sure it's OK to store
					    fd in *Hook */

  fd = *((int *) *Hook);
  *((int *) Hook) = fd;

  theBuffer->Start = (StreamByte *) vmMalloc(WRITESOCKETBUFFERSIZE);
  theBuffer->End = theBuffer->Start + WRITESOCKETBUFFERSIZE;
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;
  return 0;
}

/*
 * Flush the file buffer
 */

static int
FlushWriteSocketStream(StreamBuffer theBuffer, void **Hook)
{
  int fd, BytesWritten;

  fd = *((int *) Hook);

  BytesWritten = write(fd, theBuffer->Start, theBuffer->ValidBytes);

  if (BytesWritten < 0)
    FatalError("FlushWriteSocketStream ");

  assert(BytesWritten == theBuffer->ValidBytes);

  return BytesWritten;
}

/*
 * Destroy the WriteSocketStream 
 */

static int
DestroyWriteSocketStream(StreamBuffer theBuffer, void **Hook)
{
  if (theBuffer->Start)
    vmFree(theBuffer->Start);
  return 0;
}

/*
 * Deal with new data arriving on a socket.
 */

void ProcessNewSocketData(Socket theSocket) 
{
  int BytesRead;

  BytesRead = FillReadSocketStream(BufferCache[theSocket], (void**)&theSocket);
  BufferCache[theSocket]->ValidBytes += BytesRead;

  ActivateFD(theSocket);
}
