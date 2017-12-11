/* streams.c - Brian Edmonds <edmonds@cs.ubc.ca> 94Oct13 */

#define E_NEEDS_SOCKET
#define E_NEEDS_STRING
#define E_NEEDS_FILE
#define E_NEEDS_ERRNO
#define E_NEEDS_NETDB
#include "system.h"

#include "trace.h"
#include "dist.h"
#include "io.h"

#include "emstream.h"

#define MAXSTREAMS 32
#define BUFBLOCKSIZE 4096
#define STRINGBUFSIZE 1024

#define STREAM_READ	0x01
#define STREAM_WRITE	0x02
#define STREAM_APPEND	0x04

#define VERIFY_FD(fd) ( (fd) >= 0 && (fd) < MAXSTREAMS && streams[fd].mode )

typedef struct EMStreamBuffer *EMStreamBufferPtr;
struct EMStreamBuffer {
  int index, max;
  char buf[BUFBLOCKSIZE];
  EMStreamBufferPtr n;
};

struct StreamRecord {
  int mode, eof, isatty;
  EMStreamBufferPtr ibuf, obuf;
};

static EMStreamBufferPtr freebufs = NULL;
static struct StreamRecord streams[MAXSTREAMS] = {
  { STREAM_READ, 0, 1, NULL, NULL },
  { STREAM_WRITE, 0, 1, NULL, NULL },
  { STREAM_WRITE, 0, 1, NULL, NULL }
};

static EMStreamBufferPtr
mallocEMStreamBuffer( void )
{
  EMStreamBufferPtr buf;

  if( freebufs ) {
    buf = freebufs;
    freebufs = buf->n;
  } else {
    buf = (EMStreamBufferPtr) vmMalloc( sizeof( struct EMStreamBuffer ) );
  }
  memset( (void*)buf, 0, sizeof( struct EMStreamBuffer ) );
  return buf;
}

static void
freeEMStreamBuffer( EMStreamBufferPtr *buf )
{
  EMStreamBufferPtr tmp = *buf;

  if( *buf == NULL ) return;
  (*buf) = (*buf)->n;
  tmp->n = freebufs;
  freebufs = tmp;
}

/*
 * trypopen
 *   Start a child running sh -c COMMAND, return the fd of the socket
 */
static int trypopen(char *command, int flags)
{
  int fds[2], pid;
  if (socketpair(AF_UNIX, SOCK_STREAM, 0, fds) < 0) 
    return -1;
  switch (pid = fork()) {
  case -1:
    return -1;
    break;
  case 0:
    /* I am going to be COMMAND */
    dup2(fds[1], 0);
    dup2(fds[1], 1);
    close(fds[0]);
    close(fds[1]);
    execlp("/bin/sh", "sh", "-c", command, 0);
    return -1;
    break;
  default:
    /* I am the parent */
    if (!(flags & STREAM_READ)) {
      /* The parent will not be reading */
      shutdown(fds[0], 0); /* no more receives */
    }
    if (!(flags & STREAM_WRITE)) {
      /* The parent will not be writing */
      shutdown(fds[0], 1); /* no more sends */
    }
    close(fds[1]);
    return fds[0];
    break;
  }
}

int
streamOpen( int *fail, char *url )
{
  int fd, openFlags = 0;
  int nameOffset = 0, openMode = 0;

  /* handle the rw flag */
  if( url[0] == '+' ) {
    openFlags = STREAM_READ | STREAM_WRITE;
    nameOffset = 1;
  }

  /* are we reading the file */
  if( url[nameOffset] == '<' ) {
    openFlags |= STREAM_READ;
    nameOffset++;

  /* are we writing the file */
  } else if( url[nameOffset] == '>' ) {
    openFlags |= STREAM_WRITE;
    nameOffset++;
    if( url[nameOffset] == '>' ) {
      openFlags |= STREAM_APPEND;
      nameOffset++;
    }

  /* ok, neither, so default to reading */
  } else {
    openFlags = STREAM_READ;
    nameOffset = 0;
  }

#if defined(WIN32) && 0
  {
    extern int _fmode;
    _fmode = O_BINARY;
  }
#endif

  if (url[nameOffset] == '|') {
    fd = trypopen(url + nameOffset + 1, openFlags);
  } else {
    /* open the bloody thing */
    openMode = 
      O_BINARY |
      ( (openFlags&STREAM_WRITE) ? O_CREAT |
	( (openFlags&STREAM_APPEND) ? O_APPEND : O_TRUNC ) : 0) |
      ( (openFlags&STREAM_READ) ?
	( (openFlags&STREAM_WRITE) ? O_RDWR : O_RDONLY ) : O_WRONLY );
    errno = 0; fd = open( url + nameOffset, openMode, 0644);
  }

  /* check for failure in open */
  if( fd < 0 ) {
    TRACE( streams, 1, ("streamOpen( url=%s ) -> errno %d", url, errno ));
    *fail = 1; return -1;
  } else if( fd >= MAXSTREAMS ) {
    TRACE( streams, 0, ("streamOpen( url=%s ) -> EMFILE", url ));
    close( fd ); *fail = 1; return -1;
  }

  /* check for conflict with existing file */
  if( streams[fd].mode ) {
    fprintf( stderr, "WARNING: opening stream on existing fd (%d)!\n", fd );
    while( streams[fd].ibuf ) { freeEMStreamBuffer( &streams[fd].ibuf ); }
  }

  /* set 'em up and get outta here */
  memset( (void*) &streams[fd], 0, sizeof( struct StreamRecord ) );
  streams[fd].mode = openFlags;
  streams[fd].isatty = isatty(fd);
  TRACE( streams, 1, ("streamOpen( url=%s ) -> %d", url, fd ));
  return fd;
}

#ifdef WIN32
#define io_read(a,b,c) read(a,b,c)
#endif

static void
fillStream( int fd )
{
  EMStreamBufferPtr buf = mallocEMStreamBuffer();
  EMStreamBufferPtr *ibuf = &streams[fd].ibuf;

  errno = 0; buf->max = io_read( fd, buf->buf, BUFBLOCKSIZE );
  if( buf->max <= 0 ) {
    TRACE(streams, 1,
	  ("fillStream on fd %d reached eof (errno=%d)", fd, errno ));
    freeEMStreamBuffer( &buf ); streams[fd].eof = 1;
  } else {
    TRACE( streams, 1, ("fillStream on fd %d read %db", fd, buf->max ));
    while( *ibuf ) { ibuf = &((*ibuf)->n); } (*ibuf) = buf;
  }
}

static void
flushStream( int fd, int all )
{
  int res;
  EMStreamBufferPtr *obuf = &( streams[fd].obuf );

  for(;;)
  {
    if( *obuf == NULL || (! all && (*obuf)->max < BUFBLOCKSIZE )) break;
    if ((res = write( fd, (*obuf)->buf, (*obuf)->max )) != (*obuf)->max) {
      if (res < 0 && errno == EINTR) continue;
      TRACE(streams, 0, ("Short write wanted %d got %d, errno = %d",
			 (*obuf)->max, res, errno));
    }
    freeEMStreamBuffer( obuf );
  }
}

int
streamEos( int *fail, int fd )
{
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamEos( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return -1;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamEos( fd=%d ) -> EBADF", fd ));
    *fail = 1; return -1;
  }
  if( ! streams[fd].eof ) {
    while( streams[fd].ibuf && 
           streams[fd].ibuf->index >= streams[fd].ibuf->max ) {
      freeEMStreamBuffer( &streams[fd].ibuf );
    }
    if( streams[fd].ibuf == NULL ) { fillStream( fd ); }
  }
  TRACE(streams, 1, ("streamEos( fd=%d ) -> %d", fd, streams[fd].eof ));
  return streams[fd].eof;
}

static int
streamRead( int fd, char *buf, int size )
{
  int index = 0;

  /* fill a buffer */
  while( index < size && ( ! streams[fd].eof || streams[fd].ibuf ) ) {
    EMStreamBufferPtr *ibuf = &streams[fd].ibuf;

    if( ! *ibuf ) {
      fillStream( fd );
    } else if( (*ibuf)->max - (*ibuf)->index > size - index ) {
      memcpy( (void*)(buf+index), (void*)((*ibuf)->buf + 
		(*ibuf)->index), size - index );
      (*ibuf)->index += size - index; index = size;
    } else {
      memcpy( (void*)(buf+index), (void*)((*ibuf)->buf +
		(*ibuf)->index), (*ibuf)->max - (*ibuf)->index );
      index += (*ibuf)->max - (*ibuf)->index;
      freeEMStreamBuffer( ibuf );
    }
  }
  return index;
}

char
streamGetChar( int *fail, int fd )
{
  char c;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamGetChar( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return -1;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamGetChar( fd=%d ) -> EBADF", fd ));
    *fail = 1; return -1;
  }
  if( streamRead( fd, &c, 1 ) < 1 ) {
    TRACE(streams, 1, ("streamGetChar( fd=%d ) -> EOF", fd ));
    *fail = 1;
  } else {
    TRACE(streams, 1, ("streamGetChar( fd=%d ) -> %02X", fd, c ));
  }
  return c;
}

void
streamUngetChar( int *fail, int fd, char c )
{
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamUngetChar( fd=%d, c=%02X ) -> EINVAL", fd, c ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamUngetChar( fd=%d, c=%02X ) -> EBADF", fd, c ));
    *fail = 1; return;
  }
  TRACE(streams, 1, ("streamUngetChar( fd=%d, c=%02X )", fd, c ));
  streams[fd].eof = 0;
  if( streams[fd].ibuf && streams[fd].ibuf->index > 0 ) {
    streams[fd].ibuf->buf[--streams[fd].ibuf->index] = c;
  } else {
    EMStreamBufferPtr ibuf = mallocEMStreamBuffer();
    ibuf -> index = ( ibuf -> max = BUFBLOCKSIZE ) - 1;
    ibuf -> buf[ ibuf -> index ] = c;
    ibuf -> n = streams[fd].ibuf; streams[fd].ibuf = ibuf;
  }
}

char *
streamGetString( int *fail, int fd )
{
  char *buf;
  int index = 0, length = STRINGBUFSIZE;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamGetString( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return NULL;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamGetString( fd=%d ) -> EBADF", fd ));
    *fail = 1; return NULL;
  }

  /* fill a buffer */
  buf = (char*) vmMalloc( length + 1 );
  while (1) {
    if (index >= length) {
      length *= 2;
      buf = (char *)vmRealloc(buf, length + 1);
    }
    if( streamRead( fd, buf + index, 1 ) < 1 ) break;
    if( buf[index++] == '\n' ) break;
  } 
  buf[index] = '\0';
  TRACE(streams, 1, ("streamGetString( fd=%d ) -> [%dc]", fd, strlen( buf ) ));
  if( index == 0 ) { *fail = 1; }
  return buf;
}

int
streamFillVector( int *fail, int fd, int v )
{
  int index;
  Vector vec = (Vector) v;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamFillVector( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return 0;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamFillVector( fd=%d ) -> EBADF", fd ));
    *fail = 1; return 0;
  }

  /* fill the vector */
  for( index = 0 ; index < vec -> d.items ; ) {
    if( streamRead( fd, (char *)vec->d.data + index, 1 ) < 1 ) break;
    if( vec->d.data[index++] == '\n' ) break;
  }
  TRACE(streams, 1, ("streamFillVector( fd=%d ) -> [%dc]", fd, index ));
  if( index == 0 ) { *fail = 1; }
  return index;
}

int
streamRawRead( int *fail, int fd, int v )
{
  int index, nread;
  Vector vec = (Vector) v;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamRawRead( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return 0;
  }
  if( ! ( streams[fd].mode & STREAM_READ ) ) {
    TRACE(streams, 0, ("streamRawRead( fd=%d ) -> EBADF", fd ));
    *fail = 1; return 0;
  }

  /* fill the vector */
  for( index = 0 ; index < vec -> d.items ; ) {
    if( (nread = streamRead( fd, (char *)vec->d.data + index, vec->d.items - index )) < 1 ) break;
    index += nread;
  }
  TRACE(streams, 1, ("streamFillVector( fd=%d ) -> [%dc]", fd, index ));
  if( index == 0 ) { *fail = 1; }
  return index;
}

int
streamIsAtty( int *fail, int fd )
{
  int rval;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamIsAtty( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return 0;
  }
  rval = isatty( fd );
  TRACE(streams, 1, ("streamIsAtty( fd=%d ) -> %d", fd, rval ));
  return rval;
}

static int
streamWrite( int fd, char *buf, int len )
{
  EMStreamBufferPtr *obuf = &( streams[fd].obuf );
  int cout = 0, forceFlush = 0;

  while( len > 0 ) {

    /* make sure we've got a buffer to write into */
    if( *obuf == NULL ) {
      *obuf = mallocEMStreamBuffer();
      if( *obuf == NULL ) return cout;
    }

    /* is there sufficient room in the available buffer */
    if( (*obuf)->max + len <= BUFBLOCKSIZE ) {
      memcpy( (*obuf) -> buf + (*obuf) -> max, buf, len );
      forceFlush = streams[fd].isatty && memchr(buf, '\n', len);
      (*obuf)->max += len; buf += len; cout += len; len = 0;

    /* no, so use as much as we can */
    } else {
      int len0 = BUFBLOCKSIZE - (*obuf) -> max;
      memcpy( (*obuf) -> buf + (*obuf) -> max, buf, len0 );
      forceFlush = streams[fd].isatty && memchr(buf, '\n', len0);
      (*obuf) -> max += len0; buf += len0; cout += len0; len -= len0;
      obuf = &( (*obuf) -> n );
    }
  }

  /* flush if enough data to write */
  if (forceFlush || (streams[fd].obuf != NULL && streams[fd].obuf -> max == BUFBLOCKSIZE))

    flushStream( fd, forceFlush );
  return cout;
}

void
streamPutChar( int *fail, int fd, char c )
{
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0,
	  ("streamPutChar( fd=%d, c=%02X ) -> EINVAL", fd, c ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 1,
	  ("streamPutChar( fd=%d, c=%02X ) -> EBADF", fd, c ));
    *fail = 1; return;
  }
  TRACE(streams, 1, ("streamPutChar( fd=%d, c=%02X )", fd, c ));
  streamWrite( fd, &c, 1 );
}

void
streamPutInt( int *fail, int fd, int n, int width )
{
  char buf[256];
  
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0,
	  ("streamPutInt( fd=%d, n=%d, width=%d ) -> EINVAL", fd, n, width ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 0,
	  ("streamPutInt( fd=%d, n=%d, width=%d ) -> EBADF", fd, n, width ));
    *fail = 1; return;
  }
  sprintf( buf, "%*d", width, n );
  TRACE(streams, 1,
	("streamPutInt( fd=%d, n=%d, width=%d ) -> '%s'", fd, n, width, buf ));
  streamWrite( fd, buf, strlen(buf) );
}

void
streamWriteInt( int *fail, int fd, int n, int bytes )
{
  int rval;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0,
	  ("streamWriteInt( fd=%d, n=x%08X, size=%d ) -> EINVAL", fd, n, bytes ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 0,
	  ("streamWriteInt( fd=%d, n=x%08X, size=%d ) -> EBADF", fd, n, bytes ));
    *fail = 1; return;
  }
  if( bytes == 1 ) {
    unsigned char c = (unsigned char) ( n & 0xff );
    rval = streamWrite( fd, (char*) &c, 1 );
  } else if( bytes == 2 ) {
    unsigned short s = htons( (unsigned short) ( n & 0xffff ) );
    rval = streamWrite( fd, (char*) &s, 2 );
  } else if( bytes == 4 ) {
    unsigned int l = htonl( (unsigned int) n );
    TRACE(streams, 2,
	  ("0> streamWriteInt( fd=%d, n=x%08X, size=%d )", fd, l, bytes ));
    rval = streamWrite( fd, (char*) &l, 4 );
    TRACE(streams, 2,
	  ("1> streamWriteInt( fd=%d, n=x%08X, size=%d ) -> %d", fd, l, bytes, rval ));
  } else {
    TRACE(streams, 0,
	  ("streamWriteInt( fd=%d, n=x%08X, size=%d ) -> EINVAL", fd, n, bytes ));
    *fail = 1; return;
  }
  TRACE(streams, 1,
	("streamWriteInt( fd=%d, n=x%08X, size=%d ) -> %d", fd, n, bytes, rval ));
}

void
streamPutReal( int *fail, int fd, float n )
{
  char buf[256];

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamPutReal( fd=%d, n=%f ) -> EINVAL", fd, n ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 0, ("streamPutReal( fd=%d, n=%f ) -> EBADF", fd, n ));
    *fail = 1; return;
  }
  sprintf( buf, "%g", n );
  TRACE(streams, 1, ("streamPutReal( fd=%d, n=%f ) -> '%s'", fd, n, buf ));
  streamWrite( fd, buf, strlen(buf) );
}

void
streamPutString( int *fail, int fd, int b )
{
  Vector buf = (Vector) b;
  int rval;

  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0,
	  ("streamPutString( fd=%d, s=[%dc] ) -> EINVAL", fd, buf->d.items ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 0,
	  ("streamPutString( fd=%d, s=[%dc] ) -> EBADF", fd, buf->d.items ));
    *fail = 1; return;
  }
  if( buf->d.items < 0 ) {
    *fail = 1; return;
  } else if (buf->d.items == 0) {
    rval = 0;
  } else {
    rval = streamWrite( fd, (char *)buf->d.data, buf->d.items );
  }
  TRACE(streams, 1,
	("streamPutString( fd=%d, s=[%dc] ) -> %d", fd, buf->d.items, rval ));
}

void
streamFlush( int *fail, int fd )
{
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamFlush( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return;
  }
  if( ! ( streams[fd].mode & STREAM_WRITE ) ) {
    TRACE(streams, 0, ("streamFlush( fd=%d ) -> EBADF", fd ));
    *fail = 1; return;
  }
  TRACE(streams, 1, ("streamFlush( fd=%d )", fd ));
  flushStream( fd, 1 );
}

int
streamBind( char *url )
{
#ifdef WIN32
  return -1;
#else
  unsigned short port;
  struct sockaddr_in sin;
  int s;

  TRACE(streams, 1, ("CCALL(bind,\"%s\")", url));

  /* clean out the socket structure */
  memset((char*) &sin, 0, sizeof(sin));
  sin.sin_addr.s_addr = htonl( INADDR_ANY );
  sin.sin_family = AF_INET;

  /* parse out the protocol/port */
  if( sscanf( url, "tcp://localhost:%hd/", &port ) ) {
    sin.sin_port = htons( port );
    TRACE(streams, 1, ("Binding port %d", port));
    errno = 0; s = socket( AF_INET, SOCK_STREAM, 0 );
    if (s < 0) {
      TRACE(streams,1, ("socket() failed, errno = %d",errno));
      return s;
    }
  } else {
    TRACE(streams, 1, ("sscanf(\"%s\") failed",url));
    return -1;
  }

  /* bind the sucker */
  errno = 0;
  if( bind( s, (struct sockaddr *) &sin, sizeof( sin ) ) < 0 ) {
    close( s );
    TRACE(streams,1, ("bind() failed, errno = %d",errno));
    return -1;
  }

  /* clean up and go home */
  listen( s, 5 );
  TRACE(streams,1, ("port %d bound successfully",port));
  return s;
#endif
}

int
streamAccept( int boundSocket )
{
#ifdef WIN32
  return -1;
#else
  int fd, sinlen;
  struct sockaddr_in sin;

  /* grab the connection */
  sinlen = sizeof( sin ); memset(&sin, 0, sinlen);
  fd = accept( boundSocket, (struct sockaddr *)&sin, &sinlen );
  if( fd >= 0 ) {
    streams[fd].mode = STREAM_READ | STREAM_WRITE;
    streams[fd].eof = 0;
    streams[fd].ibuf = NULL;
  }
  return fd;
#endif
}

void
streamClose( int *fail, int fd )
{
  if( ! VERIFY_FD( fd ) ) {
    TRACE(streams, 0, ("streamClose( fd=%d ) -> EINVAL", fd ));
    *fail = 1; return;
  }
  if( streams[fd].mode & STREAM_WRITE ) flushStream( fd, 1 );
  while( streams[fd].ibuf ) { freeEMStreamBuffer( &streams[fd].ibuf ); }
  TRACE(streams, 1, ("streamClose( fd=%d )", fd ));
  close( fd );
  memset( (void*) &streams[fd], 0, sizeof( struct StreamRecord ) );
}

/* EOF */
