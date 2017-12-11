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

/* upcall.c - call from the runtime into Emerald
*/
#include "system.h"

#include "vm_exp.h"
#include "gc.h"

Object upcallStub = (Object) JNIL;

void init_upcall(void)
{
  unsigned int *stack = (unsigned int*) vmMalloc(stackSize);
  ConcreteType ct = BuiltinInstCT(STUBI);

  assert(ct);
  inhibit_gc++;
  upcallStub = CreateObjectFromOutside(ct, (u32)stack);
  vmFree(stack);
  inhibit_gc--;
}

int
upcall(Object o, int fn, int *fail, int argc, int retc, int *args)
{
  extern int interpret(State *state);
  int i, sp;
  State *state;
  ConcreteType ct = CODEPTR(o->flags);
  state = newState(o, ct);
  sp = state->sb;

  /* build the stack */
  for (i = 0 ; i < 2 * (argc + retc) ; i++) PUSH(int, args[i]);
  state->sp = sp;
  pushBottomAR(state);

  /* set up the interpreter state */
  state->pc = (u32) ct->d.opVector->d.data[fn]->d.code->d.data;

  /* make it go */
  makeReady(state);
  return 0;
}
