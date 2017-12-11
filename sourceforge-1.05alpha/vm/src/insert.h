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

#ifndef _EMERALD_INSERT_H
#define _EMERALD_INSERT_H

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#ifdef E_NEEDS_INSERT_BITS8
static inline void InsertBits8(Bits8 *theByte, Bits8 *data)
{
  *data = *theByte;
}
#endif

static inline void InsertBits16(Bits16 *theWord, Bits8 *data)
{
  *((Bits16 *) data) = htons(*theWord);
}

static inline void InsertBits32(Bits32 *theLong, Bits8 *data)
{
  *((Bits32 *) data) = htonl(*theLong);
}

static inline void InsertOID(OID *theOID, Bits8 *data)
{
  InsertBits32(&theOID->ipaddress, data);
  InsertBits16(&theOID->port, data + 4);
  InsertBits16(&theOID->epoch, data + 6);
  InsertBits32(&theOID->Seq, data + 8);
}

#endif /* _EMERALD_INSERT_H */
