/*
 * RANDOM.H
 *
 * Access to random and srandom
 */

#include "system.h"

/* Emerald interpreter exports */

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

CCALL( xrandom, RANDOM, "i" )
CCALL( xsrandom, SRANDOM, "vi" )
