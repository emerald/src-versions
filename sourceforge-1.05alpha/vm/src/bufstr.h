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
/* comment me!
 */

#ifndef _EMERALD_BUFFERSTREAMS_H
#define _EMERALD_BUFFERSTREAMS_H

#include "streams.h"

/*
 *
 * Stream       WriteToReadStream(Stream theStream, int dodestroy);
 *   This routine turns the write stream around so it can be read.
 */

extern Stream       WriteToReadStream(Stream theStream, int dodestroy);
extern StreamConstructor ReadBufferStream;
extern StreamConstructor FreeBufferStream;
extern StreamConstructor WriteBufferStream;
void BufferToIovec( Stream str, struct iovec *iov );
int BufferLength( Stream str );
char *BufferData( Stream str );

#endif /* _EMERALD_BUFFERSTREAMS_H */
