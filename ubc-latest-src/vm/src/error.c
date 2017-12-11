/****************************************************************************
 File     : error.c 
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Error handling package

 Modifications
 -------------

*****************************************************************************/

#pragma warning(disable: 4068)
#pragma pointer_size long
#include <stdio.h>
#include <errno.h>
#pragma pointer_size short
#include "error.h"

void FatalError(char *ErrorMessage)
{
  perror(ErrorMessage);
  exit(1);
}
