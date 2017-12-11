/* streams.h - Brian Edmonds <edmonds@cs.ubc.ca> 94Oct13 */

#ifndef CCALL
#define CCALL( func, subcode, argstring )
#endif /* CCALL */

int streamOpen( int *fail, char *fname );
CCALL( streamOpen, EMSTR_OPEN, "ixs" )

void streamClose( int *fail, int fd );
CCALL( streamClose, EMSTR_CLOSE, "vxi" )

int streamEos( int *fail, int fd );
CCALL( streamEos, EMSTR_EOS, "bxi" )

int streamIsAtty( int *fail, int fd );
CCALL( streamIsAtty, EMSTR_ISATTY, "bxi" )

char streamGetChar( int *fail, int fd );
CCALL( streamGetChar, EMSTR_GETC, "cxi" )

void streamUngetChar( int *fail, int fd, char c );
CCALL( streamUngetChar, EMSTR_UNGETC, "vxic" )

char *streamGetString( int *fail, int fd );
CCALL( streamGetString, EMSTR_GETS, "Sxi" )

int streamFillVector( int *fail, int fd, int v );
CCALL( streamFillVector, EMSTR_FILLV, "ixip" )

void streamPutChar( int *fail, int fd, char c );
CCALL( streamPutChar, EMSTR_PUTC, "vxic" )

void streamPutInt( int *fail, int fd, int n, int width );
CCALL( streamPutInt, EMSTR_PUTI, "vxiii" )

void streamWriteInt( int *fail, int fd, int num, int bytes );
CCALL( streamWriteInt, EMSTR_WRITEI, "vxiii" )

void streamPutReal( int *fail, int fd, float n );
CCALL( streamPutReal, EMSTR_PUTF, "vxif" )

void streamPutString( int *fail, int fd, int b );
CCALL( streamPutString, EMSTR_PUTS, "vxip" )

void streamFlush( int *fail, int fd );
CCALL( streamFlush, EMSTR_FLUSH, "vxi" )

int streamBind( char *url );
CCALL( streamBind, EMSTR_BIND, "is" )

int streamAccept( int boundSocket );
CCALL( streamAccept, EMSTR_ACCEPT, "ii" )

/* EOF */
