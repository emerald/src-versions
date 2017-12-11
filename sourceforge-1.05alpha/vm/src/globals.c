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

/* comment me!
 */

#include "system.h"

#include "types.h"
#include "globals.h"
#include "jsys.h"
#include "creation.h"

int obsoletesys(struct State *state)
{
  printf("Obsolete JSYS\n");
  abort();
  return 1;
}

Object BuiltinGlobalArray[NUMBUILTINS][NUMTAGS];
int totalbytecodes;
String TrueString, FalseString;
Node MyNode;
char *gRootNode;
int (*sysfuncs[JSYS_OPS])(struct State *) = {
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       getstdin,
       getstdout,
       gettod,
       getlnn,
       getname,
       obsoletesys,
       obsoletesys,
       getactivenodes,
       getallnodes,
       delay,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       jislocal,
       obsoletesys,
       jmove,
       jfix,
       junfix,
       jrefix,
       jlocate,
       jisfixed
     };

void initGlobals()
{
  TrueString = CreateString("true");
  FalseString = CreateString("false");
}
