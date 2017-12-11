#ifndef _EMERALD_STORAGE_H
#define _EMERALD_STORAGE_H

#if defined(MALLOCPARANOID)
extern void *vmMalloc(int);
extern void *vmRealloc(void *, int);
extern void *vmCalloc(int, int);
extern void vmFree(void *);
#else
#if defined(WIN32MALLOCDEBUG)
/*
 * Microsoft C debug malloc.
 */
#include <crtdbg.h>
#endif


#define vmMalloc(a) malloc((a))
#define vmRealloc(a,b) realloc(a,(b))
#define vmCalloc(a,b) calloc(a,b)
#define vmFree(a) (free(a))
#endif

extern void *gc_malloc(int);
extern void *gc_malloc_old(int nb, int remember);
extern void *extraRoots[];
extern int     extraRootsSP;
#define regRoot(x) (extraRoots[extraRootsSP++] = (void *)&(x))
#define unregRoot() ( extraRoots[--extraRootsSP] = 0)

extern void InitStorage(void);
#endif
