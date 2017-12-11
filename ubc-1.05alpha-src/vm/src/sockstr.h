/****************************************************************************
 File     : socketstreams.h 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Socket Streams package

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_SOCKETSTREAMS_H
#define _EMERALD_SOCKETSTREAMS_H

/*
  This module provides a stream implementation for sockets.

  The Hook argument to CreateStream should be the address of a integer
  containing the file descriptor associated with the socket to be used.

  All sockets given to these routines should be marked non-blocking.
*/

#include "streams.h"
#include "types.h"

extern StreamConstructor ReadSocketStream;
extern StreamConstructor WriteSocketStream;
extern void              ProcessNewSocketData(Socket theSocket);

#endif /* _EMERALD_SOCKESTREAMS_H */
