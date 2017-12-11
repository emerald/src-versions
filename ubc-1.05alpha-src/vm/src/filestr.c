/****************************************************************************
 File     : filestreams.c 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : File Streams package

 Modifications
 -------------

*****************************************************************************/

#define E_NEEDS_FILE
#define E_NEEDS_ERRNO
#include "system.h"

#include "filestr.h"
#include "assert.h"
#include "storage.h"
#include "dist.h"

/*
 * NOTE: The code in this file assumes that sizeof(int) <= sizeof(void *).
 *       The Hook pointer is used to store a file descriptor.  If this is
 *       inappropriate, set the Hook pointer to point to the file descriptor.
 */

#define READFILEBUFFERSIZE 4096
#define WRITEFILEBUFFERSIZE 4096

#ifdef S_IRUSR
#define WRITEACCESS (S_IRUSR | S_IWUSR | S_IXUSR | S_IRWXG | S_IRWXO)
#else
/* Hope for the best */
#define WRITEACCESS 0777
#endif

#define OPEN_FOR_READ (O_RDONLY | O_BINARY)
#define OPEN_FOR_WRITE (O_WRONLY | O_TRUNC | O_CREAT | O_BINARY)
#define OPEN_FOR_APPEND (O_WRONLY | O_APPEND | O_CREAT | O_BINARY)

static struct StreamConstructor ReadFileStreamConstructor;
static struct StreamConstructor WriteFileStreamConstructor;
static struct StreamConstructor AppendFileStreamConstructor;

StreamConstructor ReadFileStream = &ReadFileStreamConstructor;
StreamConstructor WriteFileStream = &WriteFileStreamConstructor;
StreamConstructor AppendFileStream = &AppendFileStreamConstructor;

static int  CreateReadFileStream(StreamBuffer theBuffer, void **Hook);
static void SeekReadFileStream(StreamBuffer theBuffer, void **Hook, 
			       unsigned int Position);
static int  FillReadFileStream(StreamBuffer theBuffer, void **Hook);
static int  DestroyReadFileStream(StreamBuffer theBuffer, void **Hook);

static int  CreateWriteFileStream(StreamBuffer theBuffer, void **Hook);
static int  FlushWriteFileStream(StreamBuffer theBuffer, void **Hook);
static int  DestroyWriteFileStream(StreamBuffer theBuffer, void **Hook);

static int  CreateAppendFileStream(StreamBuffer theBuffer, void **Hook);

static struct StreamConstructor ReadFileStreamConstructor = {
  Read,
  CreateReadFileStream,
  FillReadFileStream,
  DestroyReadFileStream,
  SeekReadFileStream };

static struct StreamConstructor WriteFileStreamConstructor = {
  Write,
  CreateWriteFileStream,
  FlushWriteFileStream,
  DestroyWriteFileStream,
  NULL }; 
  
static struct StreamConstructor AppendFileStreamConstructor = {
  Write,
  CreateAppendFileStream,
  FlushWriteFileStream,
  DestroyWriteFileStream,
  NULL }; 
  
/*
 * Initialize a new ReadFileStream
 *
 * Hook should point to a char * containing the name of the file to open.
 * This function then resets Hook to contain the file descriptor.
 */

static int
CreateReadFileStream(StreamBuffer theBuffer, void **Hook)
{
  char *theFileName;
  int   fd;

  assert(sizeof(int) <= sizeof(void *)); /* Make sure it's OK to store
					    fd in *Hook */

  theFileName = (char *) (*Hook);
  fd = open(theFileName, OPEN_FOR_READ, 0);
  
  if (fd < 0) return -1;

  *((int *) Hook) = fd;

  theBuffer->Start = (StreamByte *) vmMalloc(READFILEBUFFERSIZE);
  if( theBuffer->Start == NULL ) { close(fd); return -1; }
  theBuffer->End = theBuffer->Start + READFILEBUFFERSIZE;
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;
  return 0;
}

/*
 * Seek to a new position in the ReadFileStream
 */

static void
SeekReadFileStream(StreamBuffer theBuffer, void **Hook, 
                        unsigned int Position)
{
#if defined(WIN32)
  assert(0);
#else
  int fd;

  fd = *((int *) Hook);
  
  if (lseek(fd, Position, L_SET) < 0)
    FatalError("SeekReadFileStream ");
  
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;
#endif
}

/*
 * Fill the file buffer
 */

static int
FillReadFileStream(StreamBuffer theBuffer, void **Hook)
{
  int fd, BytesRead;

  fd = *((int *) Hook);

  for(;;) {
    BytesRead = read(fd, theBuffer->Start + theBuffer->ValidBytes,
		   theBuffer->End - theBuffer->Start - theBuffer->ValidBytes);
    if( BytesRead >= 0 ) break;
    if( errno != EINTR ) FatalError("FillReadFileStream ");
  }

  return BytesRead;
}

/*
 * Destroy the ReadFileStream 
 */

static int
DestroyReadFileStream(StreamBuffer theBuffer, void **Hook)
{
  int fd;

  vmFree(theBuffer->Start);
  
  fd = *((int *) Hook);
  if (close(fd) < 0)
    FatalError("DestroyReadFileStream ");
  return 0;
}

/*
 * Initialize a new WriteFileStream
 *
 * Hook should point to a char * containing the name of the file to open.
 * This function then resets Hook to contain the file descriptor.
 */

static int
CreateWriteFileStream(StreamBuffer theBuffer, void **Hook)
{
  char *theFileName;
  int   fd;

  assert(sizeof(int) <= sizeof(void *)); /* Make sure it's OK to store
					    fd in *Hook */

  theFileName = (char *) (*Hook);
  fd = open(theFileName, OPEN_FOR_WRITE, WRITEACCESS);
  
  if (fd < 0) return -1;

  *((int *) Hook) = fd;

  theBuffer->Start = (StreamByte *) vmMalloc(WRITEFILEBUFFERSIZE);
  if( theBuffer->Start == NULL ) { close(fd); return -1; }
  theBuffer->End = theBuffer->Start + WRITEFILEBUFFERSIZE;
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;
  return 0;
}

/*
 * Flush the file buffer
 */

static int
FlushWriteFileStream(StreamBuffer theBuffer, void **Hook)
{
  int fd, BytesWritten;

  fd = *((int *) Hook);

  BytesWritten = write(fd, theBuffer->Start, theBuffer->ValidBytes);

  if (BytesWritten < 0)
    FatalError("FlushWriteFileStream ");

  assert(BytesWritten == theBuffer->ValidBytes);

  return BytesWritten;
}

/*
 * Destroy the WriteFileStream 
 */

static int
DestroyWriteFileStream(StreamBuffer theBuffer, void **Hook)
{
  int fd;

  vmFree(theBuffer->Start);

  fd = *((int *) Hook);
  if (close(fd) < 0)
    FatalError("DestroyWriteFileStream ");
  return 0;
}

/*
 * Initialize a new AppendFileStream
 *
 * Hook should point to a char * containing the name of the file to open.
 * This function then resets Hook to contain the file descriptor.
 */

static int
CreateAppendFileStream(StreamBuffer theBuffer, void **Hook)
{
  char *theFileName;
  int   fd;

  assert(sizeof(int) <= sizeof(void *)); /* Make sure it's OK to store
					    fd in *Hook */

  theFileName = (char *) (*Hook);
  fd = open(theFileName, OPEN_FOR_APPEND, WRITEACCESS);
  
  if (fd < 0) return -1;

  *((int *) Hook) = fd;

  theBuffer->Start = (StreamByte *) vmMalloc(WRITEFILEBUFFERSIZE);
  if( theBuffer->Start == NULL ) { close(fd); return -1; }
  theBuffer->End = theBuffer->Start + WRITEFILEBUFFERSIZE;
  theBuffer->Head = theBuffer->Start;
  theBuffer->ValidBytes = 0;
  return 0;
}

/* EOF */
