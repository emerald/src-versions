/*
 * The Emerald Distributed Programming Language
 * 
 * Copyright (C) 2004 Emerald Authors & Contributors
 * 
 * This file is part of the Emerald Distributed Programming Language.
 *
 * The Emerald Distributed Programming Language is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 *  The Emerald Distributed Programming Language is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the Emerald Distributed Programming Language; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

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
