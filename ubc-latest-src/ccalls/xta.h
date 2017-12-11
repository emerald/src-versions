/*
 * Xt.h
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

CCALL(XtToolkitInitialize, XTTOOLKITINITIALIZE, "v")
CCALL(XtCreateApplicationContext, XTCREATEAPPLICATIONCONTEXT, "i")
CCALL(mXtOpenDisplay, XTOPENDISPLAY, "iiss")
CCALL(mXtAppCreateShell, XTAPPCREATESHELL, "issiiii")
CCALL(XtManageChild, XTMANAGECHILD, "vi")
CCALL(XtRealizeWidget, XTREALIZEWIDGET, "vi")
CCALL(XtAppMainLoop, XTAPPMAINLOOP, "vi")
CCALL(XtSetLanguageProc, XTSETLANGUAGEPROC, "v")
CCALL(mXtVaAppInitialize, XTVAAPPINITIALIZE, "is")
CCALL(XtVaCreateManagedWidget, XTVACREATEMANAGEDWIDGET, "isiisii")
CCALL(mXtAddCallback, XTADDCALLBACK, "visi")
CCALL(mXtRetrieveCallback, XTRETRIEVECALLBACK, "i")
CCALL(mXtSetArgInt, MXTSETARGINT, "vii")
CCALL(mXtSetArgString, MXTSETARGSTRING, "vis")
CCALL(mXtClearArg, MXTCLEARARG, "vi")
CCALL(mXtVaCreateManagedWidget, MXTVACREATEMANAGEDWIDGET, "isiii")


