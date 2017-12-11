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
 * Unbounded arrays of int sized things.
 */

#define E_NEEDS_STRING
#include "system.h"

#include "array.h"

void arrayDestroy(array a)
{
  if(a->base){
    memset((void*)a->base, 0, a->limit-a->base);
    vmFree(a->base);
    a->base = a->limit = a->cp = 0;
    vmFree(a);
  }
}

array arrayCreate(int blocksize)
{
  array a = (array)vmMalloc(sizeof(struct array));
  if (blocksize<2) blocksize = 2; /* required for append to work right */
  a->base = (int *)vmMalloc(blocksize * sizeof(int));
  a->cp   = a->base;
  a->limit= a->base + blocksize - 1;
  return a;
}

void arrayAppend(array a, int l)
{
  int size;
  *a->cp++ = l;
  if (a->cp >= a->limit) {
    size     = a->limit - a->base + 1;
    size    += size;
    a->base  = (int *)vmRealloc(a->base, size * sizeof(int));
    a->limit = a->base + size - 1;
    a->cp    = a->limit - (size >> 1);
  }
}
