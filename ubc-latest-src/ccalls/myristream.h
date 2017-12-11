/* streams.h - Brian Edmonds <edmonds@cs.ubc.ca> 94Oct13 */

#ifndef CCALL
#define CCALL( func, subcode, argstring )
#endif /* CCALL */

int streamOpen( int *fail, char *fname );
CCALL( streamOpen, EMS_OPEN, "ixS" )

void streamClose( int *fail, int fd );
CCALL( streamClose, EMS_CLOSE, "vxi" )

int streamEos( int *fail, int fd );
CCALL( streamEos, EMS_EOS, "bxi" )

int streamIsAtty( int *fail, int fd );
CCALL( streamIsAtty, EMS_ISATTY, "bxi" )

char streamGetChar( int *fail, int fd );
CCALL( streamGetChar, EMS_GETC, "cxi" )

void streamUngetChar( int *fail, int fd, char c );
CCALL( streamUngetChar, EMS_UNGETC, "vxic" )

char *streamGetString( int *fail, int fd );
CCALL( streamGetString, EMS_GETS, "Sxi" )

int streamFillVector( int *fail, int fd, int v );
CCALL( streamFillVector, EMS_FILLV, "ixip" )

void streamPutChar( int *fail, int fd, char c );
CCALL( streamPutChar, EMS_PUTC, "vxic" )

void streamPutInt( int *fail, int fd, int n, int width );
CCALL( streamPutInt, EMS_PUTI, "vxiii" )

void streamWriteInt( int *fail, int fd, int num, int bytes );
CCALL( streamWriteInt, EMS_WRITEI, "vxiii" )

void streamPutReal( int *fail, int fd, int n );
CCALL( streamPutReal, EMS_PUTF, "vxif" )

void streamPutString( int *fail, int fd, int b );
CCALL( streamPutString, EMS_PUTS, "vxip" )

void streamFlush( int *fail, int fd );
CCALL( streamFlush, EMS_FLUSH, "vxi" )

int streamBind( char *url );
CCALL( streamBind, EMS_BIND, "iS" )

int streamAccept( int boundSocket );
CCALL( streamAccept, EMS_ACCEPT, "ii" )

/* EOF */
