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

/****************************************************************************
 File     : streams.h 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Streams package

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_STREAMS_H
#define _EMERALD_STREAMS_H

/*
  This module implements a C streams package based on the Modula-3 streams 
  package described in "IO Streams : Abstract Tyes, Real Programs" by 
  Mark R. Brown and Greg Nelson ((C) Digital Equiptment Corporation 1989).

  For clients of the streams package :

  The type stream should be treated as an opaque type.  It should be used
  only as an argument to the functions defined in this module.  It can be
  assigned to other variables of type stream.  However, this simply creates
  another reference to the same stream, not a copy of the stream.

  The following operations are declared :

  Stream       CreateStream(StreamConstructor theConstructor, void *Hook);
    This routine is called with a StreamConstructor declared by a service
    provider.  (For example, filestreams.h declares ReadFileStream).  To
    determine the correct value for Hook, look in the service provider
    module.
  void         DestroyStream(Stream theStream);
  Stream       StealStream(Stream theStream);
    This routine makes the old stream unusable except for Destroying, and
    makes the new stream be a clone of the original.

  StreamByte  *ReadStream(Stream theStream, unsigned int Bytes);
  StreamByte  *WriteStream(Stream theStream, unsigned int Bytes);
    These two routines return pointers into the buffer used for reading and
    writing, or NULL if for some reason the request cannot be satisfied.  It
    is expected that the caller will not read or write more than Bytes bytes
    past the pointer returned, and that the caller will not write into a 
    buffer used for reading, or vice versa.  A StreamByte should be one byte.
    On most machines the typedef below (typedef unsigned char StreamByte)
    should be sufficient.  If an unsigned char is not one byte on your
    machine, change the typedef accordingly.

  void         ReadStreamToBuffer(Stream theStream, unsigned int Bytes,
                                  StreamByte *theBuffer);
  void         WriteStreamFromBuffer(Stream theStream, unsigned int Bytes,
				     StreamByte *theBuffer);
    These routines read or write directly from theBuffer.

  void         FillStream(Stream theStream);
  void         FlushStream(Stream theStream);
    FillStream() fills the internal buffer if theStream is a readable stream.
    FlusStream() flushes the internal buffer if theStream is a writeable 
    stream.  It is an error to call FillStream with a writeable stream, or
    to call FlushStream with a readable stream.

  void         SeekStream(Stream theStream, unsigned int Position);
  void         RewindStream(Stream theStream);
    SeekStream() resets the head to Position bytes from the beginning of the 
    stream, if possible.  RewindStream is equivalent to 
    SeekStream(theStream, 0).

  short        AtEOF(Stream theStream);
    AtEOF() returns 1 if the stream is at the End Of File -- all bytes have
    been read.  Otherwise, AtEOF() returns 0.

  For service providers :

  A new stream type can be implemented by providing a StreamConstructor as
  declared below.  theCreateFn is called whenever CreateStream() is called.
  theCreateFn is responsible for allocating internal buffer space in the
  StreamBuffer it is passed, and initializing all the StreamBuffer fields.
  The ValidBytes field indicates how many bytes in the buffer are valid, for
  either reading or writing.  The flag AtEOF should be set if no more bytes
  will be availabe besides those already in the buffer. When AtEOF() is called
  it returns 1 if and only if the AtEOF flag is set and ValidBytes is 0.

  theUpdateFn is called whenever more bytes must be read into or written out
  of a buffer.  ValidBytes indicates how many bytes in the buffer are valid :
  Flush functions should try to flush ValidBytes, Fill functions should try
  to fill all but ValidBytes.  These functions should not do any copying of
  bytes within the buffer or adjustment of the Head -- simply fill the buffer
  at the Head, or write the buffer up to the Head.

  theDestroyFn is called whenever DestroyStream() is called.  DestroyStream()
  does *not* deallocate the local buffer -- that is the responsibility of 
  theDestroyFn.

  theSeekFn is called by SeekStream().  It may manipulate the StreamBuffer
  as it sees fit.

  The service provider should not maintiain any internal state based on the
  value of theBuffer passed to theCreateFn().  The stream package is free
  to modify theBuffer as it sees fit.  The value of Hook is an invariant 
  however -- the streams package will not modify it.
*/

/**************/
/* Data Types */
/**************/

typedef unsigned char StreamByte;
typedef enum StreamType {
  Read,
  Write} StreamType;

typedef struct StreamBuffer {
  StreamByte *Start;
  StreamByte *End;
  StreamByte *Head;
  int         ValidBytes;
  short       AtEOF;
} *StreamBuffer;

typedef int  (*StreamFunction)     (StreamBuffer, void **);
typedef void (*StreamSeekFunction) (StreamBuffer, void **, unsigned int);

typedef struct StreamConstructor {
  StreamType     theType;
  StreamFunction theCreateFn;
  StreamFunction theUpdateFn;
  StreamFunction theDestroyFn;
  StreamSeekFunction theSeekFn;
} *StreamConstructor;

typedef struct Stream *Stream;

/*************/
/* Interface */
/*************/

extern int          IsReadStream(Stream);
extern int          IsWriteStream(Stream);
extern Stream       CreateStream(StreamConstructor theConstructor, void *Hook);
extern void         DestroyStream(Stream theStream);
extern Stream       StealStream(Stream theStream);

extern StreamByte  *PeekStream(Stream theStream, unsigned int Bytes);
extern StreamByte  *ReadStream(Stream theStream, unsigned int Bytes);
extern StreamByte  *WriteStream(Stream theStream, unsigned int Bytes);
extern void         ReadStreamToBuffer(Stream theStream, unsigned int Bytes,
				       StreamByte *theBuffer);
extern void         WriteStreamFromBuffer(Stream theStream, unsigned int Bytes,
					  StreamByte *theBuffer);
extern void         FillStream(Stream theStream);
extern void         FlushStream(Stream theStream);

extern void         SeekStream(Stream theStream, unsigned int Position);
extern void         RewindStream(Stream theStream);

extern short        AtEOF(Stream theStream);
extern int          StreamLength(Stream theStream);

void GetStreamData( Stream str, StreamBuffer *buf, void **Hook );
#endif /* _EMERALD_STREAMS_H */
