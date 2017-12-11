# Microsoft Developer Studio Project File - Name="emx" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=emx - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "emx.mak".
!MESSAGE 
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

# Begin Project
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "emx - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /Zp4 /W3 /GX /O2 /I "c:\emerald\vm\src" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DISTRIBUTED" /D "USEDISTGC" /D inline= /D "COUNTBYTECODES" /D "TIMESLICE" /D "STDARG_WORKS" /FD /D EMERALDROOT="\"c:\\emerald\"" /c
# SUBTRACT CPP /YX
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 Wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "emx - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /Zp4 /W3 /Gm /GX /Zi /Od /I "c:\emerald\vm\src" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DISTRIBUTED" /D "USEDISTGC" /D inline= /D "COUNTBYTECODES" /D "TIMESLICE" /D "STDARG_WORKS" /FD /D /D EMERALDROOT="\"c:\emerald\"" EMERALDROOT="\"c:/emerald\"" /c
# SUBTRACT CPP /YX
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 Wsock32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "emx - Win32 Release"
# Name "emx - Win32 Debug"
# Begin Source File

SOURCE=.\array.c
# End Source File
# Begin Source File

SOURCE=.\array.h
# End Source File
# Begin Source File

SOURCE=.\assert.h
# End Source File
# Begin Source File

SOURCE=.\bufstr.c
# End Source File
# Begin Source File

SOURCE=.\bufstr.h
# End Source File
# Begin Source File

SOURCE=.\builtins.h
# End Source File
# Begin Source File

SOURCE=.\call.c
# End Source File
# Begin Source File

SOURCE=.\call.h
# End Source File
# Begin Source File

SOURCE=.\cctab.c
# End Source File
# Begin Source File

SOURCE=.\cctab.h
# End Source File
# Begin Source File

SOURCE=.\concurr.h
# End Source File
# Begin Source File

SOURCE=.\config.h
# End Source File
# Begin Source File

SOURCE=.\conform.c
# End Source File
# Begin Source File

SOURCE=.\creation.c
# End Source File
# Begin Source File

SOURCE=.\creation.h
# End Source File
# Begin Source File

SOURCE=.\debug.c
# End Source File
# Begin Source File

SOURCE=.\dist.c
# End Source File
# Begin Source File

SOURCE=.\dist.h
# End Source File
# Begin Source File

SOURCE=.\distgc.c
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\emstream\emstream.c
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\emstream\emstream.h
# End Source File
# Begin Source File

SOURCE=.\extract.h
# End Source File
# Begin Source File

SOURCE=.\filestr.c
# End Source File
# Begin Source File

SOURCE=.\filestr.h
# End Source File
# Begin Source File

SOURCE=.\gaggle.c
# End Source File
# Begin Source File

SOURCE=.\gaggle.h
# End Source File
# Begin Source File

SOURCE=.\gc.c
# End Source File
# Begin Source File

SOURCE=.\gc.h
# End Source File
# Begin Source File

SOURCE=.\globals.c
# End Source File
# Begin Source File

SOURCE=.\globals.h
# End Source File
# Begin Source File

SOURCE=.\iisc.c
# End Source File
# Begin Source File

SOURCE=.\iisc.h
# End Source File
# Begin Source File

SOURCE=.\iixsc.c
# End Source File
# Begin Source File

SOURCE=.\iixsc.h
# End Source File
# Begin Source File

SOURCE=.\ilist.c
# End Source File
# Begin Source File

SOURCE=.\ilist.h
# End Source File
# Begin Source File

SOURCE=.\init.h
# End Source File
# Begin Source File

SOURCE=.\insert.h
# End Source File
# Begin Source File

SOURCE=.\io.c
# End Source File
# Begin Source File

SOURCE=.\io.h
# End Source File
# Begin Source File

SOURCE=.\iosc.c
# End Source File
# Begin Source File

SOURCE=.\iosc.h
# End Source File
# Begin Source File

SOURCE=.\iset.c
# End Source File
# Begin Source File

SOURCE=.\iset.h
# End Source File
# Begin Source File

SOURCE=.\joveisc.c
# End Source File
# Begin Source File

SOURCE=.\joveisc.h
# End Source File
# Begin Source File

SOURCE=.\jsys.c
# End Source File
# Begin Source File

SOURCE=.\jsys.h
# End Source File
# Begin Source File

SOURCE=.\jvisc.c
# End Source File
# Begin Source File

SOURCE=.\jvisc.h
# End Source File
# Begin Source File

SOURCE=.\locate.c
# End Source File
# Begin Source File

SOURCE=.\locate.h
# End Source File
# Begin Source File

SOURCE=.\main.c
# End Source File
# Begin Source File

SOURCE=.\memory.h
# End Source File
# Begin Source File

SOURCE=.\misc.c
# End Source File
# Begin Source File

SOURCE=.\misc.h
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\misk\misk.c
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\misk\misk.h
# End Source File
# Begin Source File

SOURCE=.\move.c
# End Source File
# Begin Source File

SOURCE=.\move.h
# End Source File
# Begin Source File

SOURCE=.\mqueue.c
# End Source File
# Begin Source File

SOURCE=.\mqueue.h
# End Source File
# Begin Source File

SOURCE=.\oidtoobj.c
# End Source File
# Begin Source File

SOURCE=.\oidtoobj.h
# End Source File
# Begin Source File

SOURCE=.\oisc.c
# End Source File
# Begin Source File

SOURCE=.\oisc.h
# End Source File
# Begin Source File

SOURCE=.\ooisc.c
# End Source File
# Begin Source File

SOURCE=.\ooisc.h
# End Source File
# Begin Source File

SOURCE=.\otable.c
# End Source File
# Begin Source File

SOURCE=.\otable.h
# End Source File
# Begin Source File

SOURCE=.\read.c
# End Source File
# Begin Source File

SOURCE=.\read.h
# End Source File
# Begin Source File

SOURCE=.\remote.c
# End Source File
# Begin Source File

SOURCE=.\remote.h
# End Source File
# Begin Source File

SOURCE=.\rinvoke.c
# End Source File
# Begin Source File

SOURCE=.\rinvoke.h
# End Source File
# Begin Source File

SOURCE=.\sisc.c
# End Source File
# Begin Source File

SOURCE=.\sisc.h
# End Source File
# Begin Source File

SOURCE=.\squeue.c
# End Source File
# Begin Source File

SOURCE=.\squeue.h
# End Source File
# Begin Source File

SOURCE=.\storage.c
# End Source File
# Begin Source File

SOURCE=.\storage.h
# End Source File
# Begin Source File

SOURCE=.\streams.c
# End Source File
# Begin Source File

SOURCE=.\streams.h
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\string\string.c
# End Source File
# Begin Source File

SOURCE=..\..\ccalls\string\string.h
# End Source File
# Begin Source File

SOURCE=.\system.h
# End Source File
# Begin Source File

SOURCE=.\timer.c
# End Source File
# Begin Source File

SOURCE=.\trace.c
# End Source File
# Begin Source File

SOURCE=.\trace.h
# End Source File
# Begin Source File

SOURCE=.\types.h
# End Source File
# Begin Source File

SOURCE=.\upcall.c
# End Source File
# Begin Source File

SOURCE=.\vm.c
# End Source File
# Begin Source File

SOURCE=.\vm.h
# End Source File
# Begin Source File

SOURCE=.\vm_exp.h
# End Source File
# Begin Source File

SOURCE=.\vm_i.h
# End Source File
# Begin Source File

SOURCE=.\write.c
# End Source File
# Begin Source File

SOURCE=.\write.h
# End Source File
# End Target
# End Project
