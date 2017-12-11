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
