# Microsoft Developer Studio Generated NMAKE File, Based on emx.dsp
!IF "$(CFG)" == ""
CFG=emx - Win32 Debug
!MESSAGE No configuration specified. Defaulting to emx - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "emx - Win32 Release" && "$(CFG)" != "emx - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "emx.mak" CFG="emx - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "emx - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "emx - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "emx - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\emx.exe"

!ELSE 

ALL : "$(OUTDIR)\emx.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\array.obj"
	-@erase "$(INTDIR)\bufstr.obj"
	-@erase "$(INTDIR)\call.obj"
	-@erase "$(INTDIR)\cctab.obj"
	-@erase "$(INTDIR)\conform.obj"
	-@erase "$(INTDIR)\creation.obj"
	-@erase "$(INTDIR)\debug.obj"
	-@erase "$(INTDIR)\dist.obj"
	-@erase "$(INTDIR)\distgc.obj"
	-@erase "$(INTDIR)\emstream.obj"
	-@erase "$(INTDIR)\filestr.obj"
	-@erase "$(INTDIR)\gaggle.obj"
	-@erase "$(INTDIR)\gc.obj"
	-@erase "$(INTDIR)\globals.obj"
	-@erase "$(INTDIR)\iisc.obj"
	-@erase "$(INTDIR)\iixsc.obj"
	-@erase "$(INTDIR)\ilist.obj"
	-@erase "$(INTDIR)\io.obj"
	-@erase "$(INTDIR)\iosc.obj"
	-@erase "$(INTDIR)\iset.obj"
	-@erase "$(INTDIR)\joveisc.obj"
	-@erase "$(INTDIR)\jsys.obj"
	-@erase "$(INTDIR)\jvisc.obj"
	-@erase "$(INTDIR)\locate.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\misc.obj"
	-@erase "$(INTDIR)\misk.obj"
	-@erase "$(INTDIR)\move.obj"
	-@erase "$(INTDIR)\mqueue.obj"
	-@erase "$(INTDIR)\oidtoobj.obj"
	-@erase "$(INTDIR)\oisc.obj"
	-@erase "$(INTDIR)\ooisc.obj"
	-@erase "$(INTDIR)\otable.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\remote.obj"
	-@erase "$(INTDIR)\rinvoke.obj"
	-@erase "$(INTDIR)\sisc.obj"
	-@erase "$(INTDIR)\squeue.obj"
	-@erase "$(INTDIR)\storage.obj"
	-@erase "$(INTDIR)\streams.obj"
	-@erase "$(INTDIR)\string.obj"
	-@erase "$(INTDIR)\timer.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\upcall.obj"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(INTDIR)\vm.obj"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(OUTDIR)\emx.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /Zp4 /ML /W3 /GX /O2 /I "c:\emerald\vm\src" /D "NDEBUG" /D\
 "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DISTRIBUTED" /D "USEDISTGC" /D inline= /D\
 "COUNTBYTECODES" /D "TIMESLICE" /D "STDARG_WORKS" /Fo"$(INTDIR)\\"\
 /Fd"$(INTDIR)\\" /FD /D EMERALDROOT="\"c:\\emerald\"" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.

.c{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\emx.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=Wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib\
 comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib\
 odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)\emx.pdb" /machine:I386 /out:"$(OUTDIR)\emx.exe" 
LINK32_OBJS= \
	"$(INTDIR)\array.obj" \
	"$(INTDIR)\bufstr.obj" \
	"$(INTDIR)\call.obj" \
	"$(INTDIR)\cctab.obj" \
	"$(INTDIR)\conform.obj" \
	"$(INTDIR)\creation.obj" \
	"$(INTDIR)\debug.obj" \
	"$(INTDIR)\dist.obj" \
	"$(INTDIR)\distgc.obj" \
	"$(INTDIR)\emstream.obj" \
	"$(INTDIR)\filestr.obj" \
	"$(INTDIR)\gaggle.obj" \
	"$(INTDIR)\gc.obj" \
	"$(INTDIR)\globals.obj" \
	"$(INTDIR)\iisc.obj" \
	"$(INTDIR)\iixsc.obj" \
	"$(INTDIR)\ilist.obj" \
	"$(INTDIR)\io.obj" \
	"$(INTDIR)\iosc.obj" \
	"$(INTDIR)\iset.obj" \
	"$(INTDIR)\joveisc.obj" \
	"$(INTDIR)\jsys.obj" \
	"$(INTDIR)\jvisc.obj" \
	"$(INTDIR)\locate.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\misc.obj" \
	"$(INTDIR)\misk.obj" \
	"$(INTDIR)\move.obj" \
	"$(INTDIR)\mqueue.obj" \
	"$(INTDIR)\oidtoobj.obj" \
	"$(INTDIR)\oisc.obj" \
	"$(INTDIR)\ooisc.obj" \
	"$(INTDIR)\otable.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\remote.obj" \
	"$(INTDIR)\rinvoke.obj" \
	"$(INTDIR)\sisc.obj" \
	"$(INTDIR)\squeue.obj" \
	"$(INTDIR)\storage.obj" \
	"$(INTDIR)\streams.obj" \
	"$(INTDIR)\string.obj" \
	"$(INTDIR)\timer.obj" \
	"$(INTDIR)\trace.obj" \
	"$(INTDIR)\upcall.obj" \
	"$(INTDIR)\vm.obj" \
	"$(INTDIR)\write.obj"

"$(OUTDIR)\emx.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\emx.exe"

!ELSE 

ALL : "$(OUTDIR)\emx.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\array.obj"
	-@erase "$(INTDIR)\bufstr.obj"
	-@erase "$(INTDIR)\call.obj"
	-@erase "$(INTDIR)\cctab.obj"
	-@erase "$(INTDIR)\conform.obj"
	-@erase "$(INTDIR)\creation.obj"
	-@erase "$(INTDIR)\debug.obj"
	-@erase "$(INTDIR)\dist.obj"
	-@erase "$(INTDIR)\distgc.obj"
	-@erase "$(INTDIR)\emstream.obj"
	-@erase "$(INTDIR)\filestr.obj"
	-@erase "$(INTDIR)\gaggle.obj"
	-@erase "$(INTDIR)\gc.obj"
	-@erase "$(INTDIR)\globals.obj"
	-@erase "$(INTDIR)\iisc.obj"
	-@erase "$(INTDIR)\iixsc.obj"
	-@erase "$(INTDIR)\ilist.obj"
	-@erase "$(INTDIR)\io.obj"
	-@erase "$(INTDIR)\iosc.obj"
	-@erase "$(INTDIR)\iset.obj"
	-@erase "$(INTDIR)\joveisc.obj"
	-@erase "$(INTDIR)\jsys.obj"
	-@erase "$(INTDIR)\jvisc.obj"
	-@erase "$(INTDIR)\locate.obj"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\misc.obj"
	-@erase "$(INTDIR)\misk.obj"
	-@erase "$(INTDIR)\move.obj"
	-@erase "$(INTDIR)\mqueue.obj"
	-@erase "$(INTDIR)\oidtoobj.obj"
	-@erase "$(INTDIR)\oisc.obj"
	-@erase "$(INTDIR)\ooisc.obj"
	-@erase "$(INTDIR)\otable.obj"
	-@erase "$(INTDIR)\read.obj"
	-@erase "$(INTDIR)\remote.obj"
	-@erase "$(INTDIR)\rinvoke.obj"
	-@erase "$(INTDIR)\sisc.obj"
	-@erase "$(INTDIR)\squeue.obj"
	-@erase "$(INTDIR)\storage.obj"
	-@erase "$(INTDIR)\streams.obj"
	-@erase "$(INTDIR)\string.obj"
	-@erase "$(INTDIR)\timer.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\upcall.obj"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(INTDIR)\vc50.pdb"
	-@erase "$(INTDIR)\vm.obj"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(OUTDIR)\emx.exe"
	-@erase "$(OUTDIR)\emx.ilk"
	-@erase "$(OUTDIR)\emx.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /Zp4 /MLd /W3 /Gm /GX /Zi /Od /I "c:\emerald\vm\src" /D\
 "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DISTRIBUTED" /D "USEDISTGC" /D\
 inline= /D "COUNTBYTECODES" /D "TIMESLICE" /D "STDARG_WORKS" /Fo"$(INTDIR)\\"\
 /Fd"$(INTDIR)\\" /FD /D /D EMERALDROOT="\"c:\emerald\""\
 EMERALDROOT="\"c:/emerald\"" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.

.c{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\emx.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=Wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib\
 comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib\
 odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)\emx.pdb" /debug /machine:I386 /out:"$(OUTDIR)\emx.exe"\
 /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\array.obj" \
	"$(INTDIR)\bufstr.obj" \
	"$(INTDIR)\call.obj" \
	"$(INTDIR)\cctab.obj" \
	"$(INTDIR)\conform.obj" \
	"$(INTDIR)\creation.obj" \
	"$(INTDIR)\debug.obj" \
	"$(INTDIR)\dist.obj" \
	"$(INTDIR)\distgc.obj" \
	"$(INTDIR)\emstream.obj" \
	"$(INTDIR)\filestr.obj" \
	"$(INTDIR)\gaggle.obj" \
	"$(INTDIR)\gc.obj" \
	"$(INTDIR)\globals.obj" \
	"$(INTDIR)\iisc.obj" \
	"$(INTDIR)\iixsc.obj" \
	"$(INTDIR)\ilist.obj" \
	"$(INTDIR)\io.obj" \
	"$(INTDIR)\iosc.obj" \
	"$(INTDIR)\iset.obj" \
	"$(INTDIR)\joveisc.obj" \
	"$(INTDIR)\jsys.obj" \
	"$(INTDIR)\jvisc.obj" \
	"$(INTDIR)\locate.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\misc.obj" \
	"$(INTDIR)\misk.obj" \
	"$(INTDIR)\move.obj" \
	"$(INTDIR)\mqueue.obj" \
	"$(INTDIR)\oidtoobj.obj" \
	"$(INTDIR)\oisc.obj" \
	"$(INTDIR)\ooisc.obj" \
	"$(INTDIR)\otable.obj" \
	"$(INTDIR)\read.obj" \
	"$(INTDIR)\remote.obj" \
	"$(INTDIR)\rinvoke.obj" \
	"$(INTDIR)\sisc.obj" \
	"$(INTDIR)\squeue.obj" \
	"$(INTDIR)\storage.obj" \
	"$(INTDIR)\streams.obj" \
	"$(INTDIR)\string.obj" \
	"$(INTDIR)\timer.obj" \
	"$(INTDIR)\trace.obj" \
	"$(INTDIR)\upcall.obj" \
	"$(INTDIR)\vm.obj" \
	"$(INTDIR)\write.obj"

"$(OUTDIR)\emx.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(CFG)" == "emx - Win32 Release" || "$(CFG)" == "emx - Win32 Debug"
SOURCE=.\array.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_ARRAY=\
	".\array.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\array.obj" : $(SOURCE) $(DEP_CPP_ARRAY) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_ARRAY=\
	".\array.h"\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_ARRAY=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\array.obj" : $(SOURCE) $(DEP_CPP_ARRAY) "$(INTDIR)"


!ENDIF 

SOURCE=.\bufstr.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_BUFST=\
	".\assert.h"\
	".\bufstr.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	

"$(INTDIR)\bufstr.obj" : $(SOURCE) $(DEP_CPP_BUFST) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_BUFST=\
	".\assert.h"\
	".\bufstr.h"\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_BUFST=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\bufstr.obj" : $(SOURCE) $(DEP_CPP_BUFST) "$(INTDIR)"


!ENDIF 

SOURCE=.\call.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_CALL_=\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\call.obj" : $(SOURCE) $(DEP_CPP_CALL_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_CALL_=\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_CALL_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\call.obj" : $(SOURCE) $(DEP_CPP_CALL_) "$(INTDIR)"


!ENDIF 

SOURCE=.\cctab.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_CCTAB=\
	".\assert.h"\
	".\cctab.h"\
	".\system.h"\
	

"$(INTDIR)\cctab.obj" : $(SOURCE) $(DEP_CPP_CCTAB) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_CCTAB=\
	".\assert.h"\
	".\cctab.h"\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_CCTAB=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\cctab.obj" : $(SOURCE) $(DEP_CPP_CCTAB) "$(INTDIR)"


!ENDIF 

SOURCE=.\conform.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_CONFO=\
	".\assert.h"\
	".\builtins.h"\
	".\globals.h"\
	".\iisc.h"\
	".\oidtoobj.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	

"$(INTDIR)\conform.obj" : $(SOURCE) $(DEP_CPP_CONFO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_CONFO=\
	".\assert.h"\
	".\builtins.h"\
	".\dist.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\oidtoobj.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_CONFO=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\conform.obj" : $(SOURCE) $(DEP_CPP_CONFO) "$(INTDIR)"


!ENDIF 

SOURCE=.\creation.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_CREAT=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\creation.obj" : $(SOURCE) $(DEP_CPP_CREAT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_CREAT=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_CREAT=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\creation.obj" : $(SOURCE) $(DEP_CPP_CREAT) "$(INTDIR)"


!ENDIF 

SOURCE=.\debug.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_DEBUG=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\debug.obj" : $(SOURCE) $(DEP_CPP_DEBUG) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_DEBUG=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_DEBUG=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\debug.obj" : $(SOURCE) $(DEP_CPP_DEBUG) "$(INTDIR)"


!ENDIF 

SOURCE=.\dist.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_DIST_=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\dist.obj" : $(SOURCE) $(DEP_CPP_DIST_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_DIST_=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_DIST_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\dist.obj" : $(SOURCE) $(DEP_CPP_DIST_) "$(INTDIR)"


!ENDIF 

SOURCE=.\distgc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_DISTG=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\distgc.obj" : $(SOURCE) $(DEP_CPP_DISTG) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_DISTG=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_DISTG=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\distgc.obj" : $(SOURCE) $(DEP_CPP_DISTG) "$(INTDIR)"


!ENDIF 

SOURCE=..\..\ccalls\emstream\emstream.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_EMSTR=\
	"..\..\ccalls\emstream\emstream.h"\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\emstream.obj" : $(SOURCE) $(DEP_CPP_EMSTR) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_EMSTR=\
	"..\..\ccalls\emstream\emstream.h"\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_EMSTR=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\emstream.obj" : $(SOURCE) $(DEP_CPP_EMSTR) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=.\filestr.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_FILES=\
	".\assert.h"\
	".\dist.h"\
	".\filestr.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\filestr.obj" : $(SOURCE) $(DEP_CPP_FILES) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_FILES=\
	".\assert.h"\
	".\dist.h"\
	".\filestr.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_FILES=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\filestr.obj" : $(SOURCE) $(DEP_CPP_FILES) "$(INTDIR)"


!ENDIF 

SOURCE=.\gaggle.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_GAGGL=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\gaggle.obj" : $(SOURCE) $(DEP_CPP_GAGGL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_GAGGL=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_GAGGL=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\gaggle.obj" : $(SOURCE) $(DEP_CPP_GAGGL) "$(INTDIR)"


!ENDIF 

SOURCE=.\gc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_GC_C18=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iixsc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_i.h"\
	

"$(INTDIR)\gc.obj" : $(SOURCE) $(DEP_CPP_GC_C18) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_GC_C18=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iixsc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_GC_C18=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\gc.obj" : $(SOURCE) $(DEP_CPP_GC_C18) "$(INTDIR)"


!ENDIF 

SOURCE=.\globals.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_GLOBA=\
	".\builtins.h"\
	".\creation.h"\
	".\globals.h"\
	".\iisc.h"\
	".\jsys.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	

"$(INTDIR)\globals.obj" : $(SOURCE) $(DEP_CPP_GLOBA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_GLOBA=\
	".\builtins.h"\
	".\creation.h"\
	".\dist.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\jsys.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_GLOBA=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\globals.obj" : $(SOURCE) $(DEP_CPP_GLOBA) "$(INTDIR)"


!ENDIF 

SOURCE=.\iisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_IISC_=\
	".\assert.h"\
	".\iisc.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\iisc.obj" : $(SOURCE) $(DEP_CPP_IISC_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_IISC_=\
	".\assert.h"\
	".\dist.h"\
	".\iisc.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_IISC_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\iisc.obj" : $(SOURCE) $(DEP_CPP_IISC_) "$(INTDIR)"


!ENDIF 

SOURCE=.\iixsc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_IIXSC=\
	".\assert.h"\
	".\iisc.h"\
	".\iixsc.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\iixsc.obj" : $(SOURCE) $(DEP_CPP_IIXSC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_IIXSC=\
	".\assert.h"\
	".\dist.h"\
	".\iisc.h"\
	".\iixsc.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_IIXSC=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\iixsc.obj" : $(SOURCE) $(DEP_CPP_IIXSC) "$(INTDIR)"


!ENDIF 

SOURCE=.\ilist.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_ILIST=\
	".\assert.h"\
	".\ilist.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\ilist.obj" : $(SOURCE) $(DEP_CPP_ILIST) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_ILIST=\
	".\assert.h"\
	".\dist.h"\
	".\ilist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_ILIST=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\ilist.obj" : $(SOURCE) $(DEP_CPP_ILIST) "$(INTDIR)"


!ENDIF 

SOURCE=.\io.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_IO_C22=\
	".\assert.h"\
	".\dist.h"\
	".\iisc.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\io.obj" : $(SOURCE) $(DEP_CPP_IO_C22) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_IO_C22=\
	".\assert.h"\
	".\dist.h"\
	".\iisc.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_IO_C22=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\io.obj" : $(SOURCE) $(DEP_CPP_IO_C22) "$(INTDIR)"


!ENDIF 

SOURCE=.\iosc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_IOSC_=\
	".\assert.h"\
	".\iosc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	

"$(INTDIR)\iosc.obj" : $(SOURCE) $(DEP_CPP_IOSC_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_IOSC_=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\iosc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_IOSC_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\iosc.obj" : $(SOURCE) $(DEP_CPP_IOSC_) "$(INTDIR)"


!ENDIF 

SOURCE=.\iset.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_ISET_=\
	".\assert.h"\
	".\iset.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\iset.obj" : $(SOURCE) $(DEP_CPP_ISET_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_ISET_=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\iset.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_ISET_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\iset.obj" : $(SOURCE) $(DEP_CPP_ISET_) "$(INTDIR)"


!ENDIF 

SOURCE=.\joveisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_JOVEI=\
	".\array.h"\
	".\assert.h"\
	".\iisc.h"\
	".\joveisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\joveisc.obj" : $(SOURCE) $(DEP_CPP_JOVEI) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_JOVEI=\
	".\array.h"\
	".\assert.h"\
	".\dist.h"\
	".\iisc.h"\
	".\io.h"\
	".\joveisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_JOVEI=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\joveisc.obj" : $(SOURCE) $(DEP_CPP_JOVEI) "$(INTDIR)"


!ENDIF 

SOURCE=.\jsys.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_JSYS_=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\init.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\jsys.obj" : $(SOURCE) $(DEP_CPP_JSYS_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_JSYS_=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\init.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_JSYS_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\jsys.obj" : $(SOURCE) $(DEP_CPP_JSYS_) "$(INTDIR)"


!ENDIF 

SOURCE=.\jvisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_JVISC=\
	".\assert.h"\
	".\builtins.h"\
	".\globals.h"\
	".\iisc.h"\
	".\jvisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\jvisc.obj" : $(SOURCE) $(DEP_CPP_JVISC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_JVISC=\
	".\assert.h"\
	".\builtins.h"\
	".\dist.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\jvisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_JVISC=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\jvisc.obj" : $(SOURCE) $(DEP_CPP_JVISC) "$(INTDIR)"


!ENDIF 

SOURCE=.\locate.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_LOCAT=\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\locate.obj" : $(SOURCE) $(DEP_CPP_LOCAT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_LOCAT=\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_LOCAT=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\locate.obj" : $(SOURCE) $(DEP_CPP_LOCAT) "$(INTDIR)"


!ENDIF 

SOURCE=.\main.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_MAIN_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\main.obj" : $(SOURCE) $(DEP_CPP_MAIN_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_MAIN_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\timer.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_MAIN_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\main.obj" : $(SOURCE) $(DEP_CPP_MAIN_) "$(INTDIR)"


!ENDIF 

SOURCE=.\misc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_MISC_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\misc.obj" : $(SOURCE) $(DEP_CPP_MISC_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_MISC_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_MISC_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\misc.obj" : $(SOURCE) $(DEP_CPP_MISC_) "$(INTDIR)"


!ENDIF 

SOURCE=..\..\ccalls\misk\misk.c
DEP_CPP_MISK_=\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\misk.obj" : $(SOURCE) $(DEP_CPP_MISK_) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=.\move.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_MOVE_=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	

"$(INTDIR)\move.obj" : $(SOURCE) $(DEP_CPP_MOVE_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_MOVE_=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_MOVE_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\move.obj" : $(SOURCE) $(DEP_CPP_MOVE_) "$(INTDIR)"


!ENDIF 

SOURCE=.\mqueue.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_MQUEU=\
	".\assert.h"\
	".\dist.h"\
	".\mqueue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	

"$(INTDIR)\mqueue.obj" : $(SOURCE) $(DEP_CPP_MQUEU) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_MQUEU=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\mqueue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_MQUEU=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\mqueue.obj" : $(SOURCE) $(DEP_CPP_MQUEU) "$(INTDIR)"


!ENDIF 

SOURCE=.\oidtoobj.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_OIDTO=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\oidtoobj.obj" : $(SOURCE) $(DEP_CPP_OIDTO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_OIDTO=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\ooisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_OIDTO=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\oidtoobj.obj" : $(SOURCE) $(DEP_CPP_OIDTO) "$(INTDIR)"


!ENDIF 

SOURCE=.\oisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_OISC_=\
	".\assert.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	

"$(INTDIR)\oisc.obj" : $(SOURCE) $(DEP_CPP_OISC_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_OISC_=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_OISC_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\oisc.obj" : $(SOURCE) $(DEP_CPP_OISC_) "$(INTDIR)"


!ENDIF 

SOURCE=.\ooisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_OOISC=\
	".\assert.h"\
	".\ooisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	

"$(INTDIR)\ooisc.obj" : $(SOURCE) $(DEP_CPP_OOISC) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_OOISC=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\ooisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_OOISC=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\ooisc.obj" : $(SOURCE) $(DEP_CPP_OOISC) "$(INTDIR)"


!ENDIF 

SOURCE=.\otable.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_OTABL=\
	".\assert.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	

"$(INTDIR)\otable.obj" : $(SOURCE) $(DEP_CPP_OTABL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_OTABL=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_OTABL=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\otable.obj" : $(SOURCE) $(DEP_CPP_OTABL) "$(INTDIR)"


!ENDIF 

SOURCE=.\read.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_READ_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\extract.h"\
	".\filestr.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\joveisc.h"\
	".\jsys.h"\
	".\jvisc.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\read.obj" : $(SOURCE) $(DEP_CPP_READ_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_READ_=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\extract.h"\
	".\filestr.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\joveisc.h"\
	".\jsys.h"\
	".\jvisc.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_READ_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\read.obj" : $(SOURCE) $(DEP_CPP_READ_) "$(INTDIR)"


!ENDIF 

SOURCE=.\remote.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_REMOT=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\extract.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\insert.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\move.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\remote.obj" : $(SOURCE) $(DEP_CPP_REMOT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_REMOT=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\extract.h"\
	".\gaggle.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\insert.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\move.h"\
	".\mqueue.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_REMOT=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\remote.obj" : $(SOURCE) $(DEP_CPP_REMOT) "$(INTDIR)"


!ENDIF 

SOURCE=.\rinvoke.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_RINVO=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	

"$(INTDIR)\rinvoke.obj" : $(SOURCE) $(DEP_CPP_RINVO) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_RINVO=\
	".\array.h"\
	".\assert.h"\
	".\bufstr.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\locate.h"\
	".\misc.h"\
	".\move.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\remote.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_RINVO=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\rinvoke.obj" : $(SOURCE) $(DEP_CPP_RINVO) "$(INTDIR)"


!ENDIF 

SOURCE=.\sisc.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_SISC_=\
	".\assert.h"\
	".\sisc.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\sisc.obj" : $(SOURCE) $(DEP_CPP_SISC_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_SISC_=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\sisc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_SISC_=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\sisc.obj" : $(SOURCE) $(DEP_CPP_SISC_) "$(INTDIR)"


!ENDIF 

SOURCE=.\squeue.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_SQUEU=\
	".\assert.h"\
	".\squeue.h"\
	".\storage.h"\
	".\system.h"\
	

"$(INTDIR)\squeue.obj" : $(SOURCE) $(DEP_CPP_SQUEU) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_SQUEU=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_SQUEU=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\squeue.obj" : $(SOURCE) $(DEP_CPP_SQUEU) "$(INTDIR)"


!ENDIF 

SOURCE=.\storage.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_STORA=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	

"$(INTDIR)\storage.obj" : $(SOURCE) $(DEP_CPP_STORA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_STORA=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_STORA=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\storage.obj" : $(SOURCE) $(DEP_CPP_STORA) "$(INTDIR)"


!ENDIF 

SOURCE=.\streams.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_STREA=\
	".\assert.h"\
	".\dist.h"\
	".\misc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	

"$(INTDIR)\streams.obj" : $(SOURCE) $(DEP_CPP_STREA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_STREA=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\misc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_STREA=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\streams.obj" : $(SOURCE) $(DEP_CPP_STREA) "$(INTDIR)"


!ENDIF 

SOURCE=..\..\ccalls\string\string.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_STRIN=\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	

"$(INTDIR)\string.obj" : $(SOURCE) $(DEP_CPP_STRIN) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_STRIN=\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_STRIN=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\string.obj" : $(SOURCE) $(DEP_CPP_STRIN) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=.\timer.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_TIMER=\
	".\storage.h"\
	".\system.h"\
	".\trace.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\timer.obj" : $(SOURCE) $(DEP_CPP_TIMER) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_TIMER=\
	".\dist.h"\
	".\io.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_TIMER=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\timer.obj" : $(SOURCE) $(DEP_CPP_TIMER) "$(INTDIR)"


!ENDIF 

SOURCE=.\trace.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_TRACE=\
	".\assert.h"\
	".\dist.h"\
	".\misc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_TRACE=\
	".\assert.h"\
	".\dist.h"\
	".\io.h"\
	".\misc.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_TRACE=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ENDIF 

SOURCE=.\upcall.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_UPCAL=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	

"$(INTDIR)\upcall.obj" : $(SOURCE) $(DEP_CPP_UPCAL) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_UPCAL=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_UPCAL=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\upcall.obj" : $(SOURCE) $(DEP_CPP_UPCAL) "$(INTDIR)"


!ENDIF 

SOURCE=.\vm.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_VM_C58=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\vm.obj" : $(SOURCE) $(DEP_CPP_VM_C58) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_VM_C58=\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\io.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\otable.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_VM_C58=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\vm.obj" : $(SOURCE) $(DEP_CPP_VM_C58) "$(INTDIR)"


!ENDIF 

SOURCE=.\write.c

!IF  "$(CFG)" == "emx - Win32 Release"

DEP_CPP_WRITE=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\filestr.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\insert.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\types.h"\
	

"$(INTDIR)\write.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

DEP_CPP_WRITE=\
	".\array.h"\
	".\assert.h"\
	".\builtins.h"\
	".\call.h"\
	".\concurr.h"\
	".\creation.h"\
	".\dist.h"\
	".\filestr.h"\
	".\gc.h"\
	".\globals.h"\
	".\iisc.h"\
	".\insert.h"\
	".\io.h"\
	".\iosc.h"\
	".\iset.h"\
	".\jsys.h"\
	".\misc.h"\
	".\oidtoobj.h"\
	".\oisc.h"\
	".\otable.h"\
	".\read.h"\
	".\rinvoke.h"\
	".\squeue.h"\
	".\storage.h"\
	".\streams.h"\
	".\system.h"\
	".\trace.h"\
	".\types.h"\
	".\vm.h"\
	".\vm_exp.h"\
	".\vm_i.h"\
	".\write.h"\
	{$(INCLUDE)}"sys\stat.h"\
	{$(INCLUDE)}"sys\timeb.h"\
	{$(INCLUDE)}"sys\types.h"\
	
NODEP_CPP_WRITE=\
	".\netinet\tcp.h"\
	".\sys\socket.h"\
	

"$(INTDIR)\write.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


!ENDIF 


!ENDIF 

