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
