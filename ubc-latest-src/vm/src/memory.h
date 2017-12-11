/****************************************************************************
 File     : memory.h
 Date     : 06-22-92
 Author   : Mark Immel

 Contents : Memory allocation functions

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_MEMORY_H
#define _EMERALD_MEMORY_H

#include "threads.h"

extern int strncmp(const char *, const char *, size_t);
extern void *gc_malloc(int);
extern void *gc_malloc_nogc(int), *gc_malloc_old(int nb, int remember);
extern void *extraRoots[];
extern int     extraRootsSP;
#define regRoot(x) (extraRoots[extraRootsSP++] = (void *)&(x))
#define unregRoot() ( extraRoots[--extraRootsSP] = 0)
#endif /* _EMERALD_MEMORY_H */

