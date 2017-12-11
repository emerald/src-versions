/*
 * xma.h
 */

#pragma pointer_size long
#include <stdlib.h>
#include <Xm/Xm.h>
#include <Xm/Label.h>
#include <Xm/MainW.h>
#include <Xm/MessageB.h>
#include <Xm/FileSB.h>
#include <Xm/PushB.h>
#pragma pointer_size short

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

#define ARGSSETUP(INDEX) int _i; \
	for (_i=0;_i<INDEX;_i++) \
	  _mxtargs[_i] = _mxtlocal[_i].thearg; \
	_mxtargs[INDEX] = NULL


Widget mXtAppCreateShell(String n, String m, int x, Display *d, Arg *args, int nargs);
Display *mXtOpenDisplay(XtAppContext appContext, String n, String o);

CCALL(XmCreateLabel, XMCREATELABEL, "iisii")
CCALL(XmStringCreateLocalized, XMSTRINGCREATELOCALIZED, "is")
CCALL(XmStringFree, XMSTRINGFREE, "vi")
CCALL(mxmMapWidgetClass, MXMMAPWIDGETCLASS, "iS")
CCALL(mXmVaCreateSimpleMenuBar,MXMVACREATESIMPLEMENUBAR,"iiSi")

