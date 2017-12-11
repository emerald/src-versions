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
