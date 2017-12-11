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

#include "iisc.h"
#include "sisc.h"
#include "iset.h"
#include "slist.h"
#include "ilist.h"
#include "assert.h"

struct identifier_entry {
    char *name;		/* character string key for this entry */
    int  token;		/* token (id or some keyword) */    
    int  lineno;	/* source line number */
};

typedef struct thing {
  ISet first;
  ISet follow;
  int nrules;
  struct rule **rules;
} thing;

typedef struct rule {
  int nsymbols;
  ISet first;
  ISet director;
  struct identifier_entry **symbols;
} rule;
extern thing *currentthing;
extern rule  *currentrule;
typedef struct identifier_entry symbol;
extern symbol *first;
