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

CCALL( random, RANDOM, "i" )

CCALL( srandom, SRANDOM, "vi" )
