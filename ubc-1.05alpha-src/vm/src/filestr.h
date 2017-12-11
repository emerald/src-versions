/****************************************************************************
 File     : filestreams.h 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : File Streams package

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_FILESTREAMS_H
#define _EMERALD_FILESTREAMS_H

/*
  This module provides a stream implementation for files.

  The Hook argument to CreateStream should be a char * pointing to the name
  of the file to open.
*/

#include "streams.h"

extern StreamConstructor ReadFileStream;
extern StreamConstructor WriteFileStream;
extern StreamConstructor AppendFileStream;

#endif /* _EMERALD_FILESSTREAMS_H */
