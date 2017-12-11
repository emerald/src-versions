dnl Process this file with autoconf to produce a configure script.
AC_INIT(X/X.m)

PACKAGE=emerald
VERSION=1.05alpha
AM_INIT_AUTOMAKE($PACKAGE,$VERSION)
AC_DEFINE([SINGLESTEP])
AC_DEFINE([COUNTBYTECODES])
AC_DEFINE([STDARG_WORKS])
AC_DEFINE([DISTRIBUTED])
AC_PROG_RANLIB
AC_PATH_PROGS(SH, sh)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_LEX
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_YACC

dnl Checks for libraries.
dnl Replace `main' with a function in -ll:
AC_CHECK_LIB(l, main)
dnl Replace `main' with a function in -lm:
AC_CHECK_LIB(m, main)

dnl Checks for header files.
AC_PATH_X
AC_HEADER_DIRENT
AC_HEADER_STDC
AC_CHECK_HEADERS(fcntl.h sys/file.h sys/time.h unistd.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_C_INLINE
AC_TYPE_SIZE_T
AC_HEADER_TIME
AC_STRUCT_TM

dnl Checks for library functions.
AC_FUNC_MEMCMP
AC_TYPE_SIGNAL
AC_FUNC_STRFTIME
AC_FUNC_VPRINTF
AC_CHECK_FUNCS(ftime gethostname gettimeofday mktime regcomp socket strcspn strerror)
AC_CONFIG_FILES(Makefile)
AC_OUTPUT(vm/Makefile vm/src/Makefile ccalls/Makefile bin/Makefile)


