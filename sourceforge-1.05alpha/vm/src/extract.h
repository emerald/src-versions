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

#ifndef _EMERALD_EXTRACT_H
#define _EMERALD_EXTRACT_H

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#ifdef E_NEEDS_EXTRACT_BITS8
static inline void ExtractBits8(Bits8 *theByte, Bits8 *data)
{
  *theByte = *data;
}
#endif

#if defined(E_NEEDS_EXTRACT_BITS16) || defined(E_NEEDS_EXTRACT_NODE) || defined(E_NEEDS_EXTRACT_OID)
static inline void ExtractBits16(Bits16 *theWord, Bits8 *data)
{
  *theWord = ntohs(*((Bits16 *) data));
}
#endif

static inline void ExtractBits32(Bits32 *theLong, Bits8 *data)
{
  *theLong = ntohl(*((Bits32 *) data));
}

#ifdef E_NEEDS_EXTRACT_OID
static inline void ExtractOID(OID *theOID, Bits8 *data)
{
  ExtractBits32(&theOID->ipaddress, data);
  ExtractBits16(&theOID->port, data + 4);
  ExtractBits16(&theOID->epoch, data + 6);
  ExtractBits32(&theOID->Seq, data + 8);
}
#endif

extern void incomingRef(Object, int), incomingObject(Object);
extern void makeRefBlack(Object), makeRefGrey(Object);

#ifdef E_NEEDS_EXTRACT_OBJECT_DESCRIPTOR
static inline void ExtractObjectDescriptor(Object o, Bits8 *data)
{
  unsigned int newflags, finalflags;
  ExtractBits32(&newflags, data);
  finalflags = (o->flags & ALLBITS) | newflags;  
  /*
   * If we are dgcing, and the other side says the object is black,
   * and it was not resident before, then remove it from greys.
   */
  if (inDistGC() && !RESDNT(o->flags))
    if (DISTGC(newflags))
      makeRefBlack(o);
    else
      makeRefGrey(o);

    
  if (DISTGC(o->flags) && !DISTGC(newflags)) CLEARDISTGC(finalflags);
  TRACE(index, 2, ("EOD: %x was %x now %x", o, o->flags, finalflags));
  o->flags = finalflags;
}
#endif

#ifdef E_NEEDS_EXTRACT_NODE
static void ExtractNode(Node *t, Bits8 *data)
{
  /* No ntoh desired here */
  t->ipaddress = *(Bits32 *) data;
  ExtractBits16(&t->port, data + 4);
  ExtractBits16(&t->epoch, data + 6);
}
#endif

#endif /* _EMERALD_EXTRACT_H */
