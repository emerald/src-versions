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

extern void srandom(unsigned int);
extern long random();
CCALL( random, RANDOM, "i" );

CCALL( srandom, SRANDOM, "vi" );
