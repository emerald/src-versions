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
