/*
 * HELLO.H
 *
 * a silly primitive C call.  Can go away when we have real ones.
 */

void hello(void);

/* Emerald interpreter exports */

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

CCALL( hello, HELLO, "v"  )

