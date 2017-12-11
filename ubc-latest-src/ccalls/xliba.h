/*
 * Xlib.h
 */

#pragma pointer_size long
#include <stdlib.h>
#include <X11/Xlib.h>
#pragma pointer_size short

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

extern void MTRegisterFD(int);

CCALL(XOpenDisplay, XOPENDISPLAY, "is")
CCALL(XConnectionNumber, XCONNECTIONNUMBER, "ii")
CCALL(MTRegisterFD, MTREGISTERFD, "vi")
