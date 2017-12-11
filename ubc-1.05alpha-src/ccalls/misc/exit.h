/*
 * EXIT.H
 *
 * a trivial C call to get at exit(2).
 */

#include <stdlib.h>
/* Emerald interpreter exports */

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

CCALL( exit, EXIT, "vi"  )
