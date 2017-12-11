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
/*
 * Trivial dynamic read-only arrays
 */

#ifndef _EMERALD_ARRAY_H
#define _EMERALD_ARRAY_H

#ifndef _EMERALD_STORAGE_H
#include "storage.h"
#endif

typedef struct array {
  int *base, *limit, *cp;
} *array;

#define ASUB(a,i) (*((a)->base + (int)(i)))
#define REF(a,i) ((a)->base + (int)(i))
#define ARRAYSIZE(a) ((a)->cp - (a)->base)
extern array arrayCreate(int);
extern void arrayAppend(array, int);
extern void arrayDestroy(array);

#endif /* _EMERALD_ARRAY_H */
