#ifndef _EMERALD_NTOH_H
#define _EMERALD_NTOH_H
#ifdef WIN32
/*
 * For some reason ntoh is in some standard place in WIN32.  I don't know why?
 */
#else
#include <types.h>
#include <netinet/in.h>
#ifdef sgi
#include <endian.h>
#endif
#endif

#endif /* _EMERALD_NTOH_H */
