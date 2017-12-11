/*
 * misk
 *
 * Get at exit(2), getenv(3).
 */

#pragma warning(disable: 4068)
#pragma pointer_size long
#include <stdlib.h>
#pragma pointer_size short

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */
extern void die(void);

CCALL(die, UEXIT, "vi")
CCALL(mgetenv, "UGETENV", "sS")
CCALL(opendir, "UOPENDIR", "pS");
CCALL(mreaddir, "UREADDIR", "sp");
CCALL(closedir, "UCLOSEDIR", "vp");
