/* bufstr.c - buffer stream using streams.c
 */

#define E_NEEDS_IOV
#include "system.h"

#include "assert.h"
#include "bufstr.h"
#include "storage.h"
#include "trace.h"

enum { INITIALWRITEBUFFERSIZE = 1024 };

static struct StreamConstructor rbs_constructor;
StreamConstructor ReadBufferStream = &rbs_constructor;
static int create_rbs( StreamBuffer buf, void **d );
static void seek_rbs( StreamBuffer buf, void **d, unsigned int where );
static int destroy_rbs( StreamBuffer buf, void **d );

static struct StreamConstructor fbs_constructor;
StreamConstructor FreeBufferStream = &fbs_constructor;
static int destroy_fbs( StreamBuffer buf, void **d );

static struct StreamConstructor wbs_constructor;
StreamConstructor WriteBufferStream = &wbs_constructor;
static int create_wbs( StreamBuffer buf, void **d );
static int flush_wbs( StreamBuffer buf, void **d );
static int destroy_wbs( StreamBuffer buf, void **d );

static struct StreamConstructor rbs_constructor = {
  Read,
  create_rbs,
  NULL,
  destroy_rbs,
  seek_rbs };

static struct StreamConstructor fbs_constructor = {
  Read,
  create_rbs,
  NULL,
  destroy_fbs,
  seek_rbs };

static struct StreamConstructor wbs_constructor = {
  Write,
  create_wbs,
  flush_wbs,
  destroy_wbs,
  NULL }; 
  
static int
create_rbs( StreamBuffer buf, void **d )
{
  struct iovec *iov;

  iov = (struct iovec*) vmMalloc( sizeof( struct iovec ) );
  if( iov == NULL ) { return -1; }
  *iov = *(struct iovec*)(*d); *d = (void*)iov;
  buf->Start = (StreamByte*) iov->iov_base;
  buf->End = buf->Start + iov->iov_len;
  buf->Head = buf->Start; buf->AtEOF = 1;
  buf->ValidBytes = iov->iov_len;
  return 0;
}

static void
seek_rbs( StreamBuffer buf, void **d, unsigned int pos )
{
  if( (int)pos > buf->ValidBytes ) FatalError("seek_rbs ");
  buf->Head = buf->Start + pos;
  buf->ValidBytes = buf->End - buf->Head;
}

static int
destroy_rbs( StreamBuffer buf, void **d )
{
  struct iovec *iov = (struct iovec*) (*d);
  vmFree( iov ); return 0;
}

static int
destroy_fbs( StreamBuffer buf, void **d )
{
  struct iovec *iov = (struct iovec*) (*d);
  vmFree( iov->iov_base ); vmFree( iov );
  return 0;
}

static int
create_wbs( StreamBuffer buf, void **d )
{
  struct iovec* iov;

  buf->Start = (StreamByte*) vmMalloc( INITIALWRITEBUFFERSIZE );
  if( buf->Start == NULL ) { return -1; }
  buf->End = buf->Start + INITIALWRITEBUFFERSIZE;
  buf->Head = buf->Start;
  buf->ValidBytes = 0;

  iov = (struct iovec*) vmMalloc( sizeof( struct iovec ) );
  if( iov == NULL ) { vmFree( buf->Start ); return -1; }
  iov->iov_base = (char *)buf->Start;
  iov->iov_len = INITIALWRITEBUFFERSIZE;
  *d = (void*)iov; return 0;
}

static int
flush_wbs( StreamBuffer buf, void **d )
{
  struct iovec *iov = (struct iovec*) (*d);
  int len = (int)buf->Start - (int)iov->iov_base + buf->ValidBytes;

  iov->iov_len *= 2;
  iov->iov_base = (void*) vmRealloc( iov->iov_base, iov->iov_len );
  assert( iov->iov_base != NULL );
  buf->Start = (StreamByte *)iov->iov_base + len;
  /* Head is decremented in FlushStream */
  buf->Head = buf->Start + buf->ValidBytes;
  buf->End = (StreamByte *)iov->iov_base + iov->iov_len;
  return buf->ValidBytes;
}

static int
destroy_wbs( StreamBuffer buf, void **d )
{
  struct iovec *iov;

  assert(d);
  TRACE(rinvoke, 15, ("destroy_wbs buf = %x, d = %x, *d = %x", buf, d, *d));
  iov = (struct iovec*) (*d);

  TRACE(rinvoke, 16, ("destroy_wbs iov->iov_base = %x", iov->iov_base));
  vmFree( iov->iov_base );
  vmFree( iov ); return 0;
}

void
BufferToIovec( Stream str, struct iovec *iov )
{
  StreamBuffer buf;
  struct iovec *iov0;

  GetStreamData( str, &buf, (void**) &iov0 );
  iov->iov_base = iov0->iov_base;
  iov->iov_len = (int)buf->Start - (int)iov0->iov_base + buf->ValidBytes;
}

int
BufferLength( Stream str )
{
  StreamBuffer buf;
  struct iovec *iov;

  GetStreamData( str, &buf, (void**) &iov );
  return (int)buf->Start - (int)iov->iov_base + buf->ValidBytes;
}

char *
BufferData( Stream str )
{
  StreamBuffer buf;
  struct iovec *iov;

  GetStreamData( str, &buf, (void**) &iov );
  return (char*) iov->iov_base;
}

Stream WriteToReadStream(Stream wStream, int dodestroy)
{
  Stream rStream;
  struct iovec wvec, rvec;
  BufferToIovec(wStream, &wvec);
  rvec.iov_base = malloc(wvec.iov_len);
  rvec.iov_len = wvec.iov_len;
  memcpy(rvec.iov_base, wvec.iov_base, rvec.iov_len);
  rStream = CreateStream(FreeBufferStream, &rvec);
  if (dodestroy) DestroyStream(wStream);
  return rStream;
}

/* EOF */
