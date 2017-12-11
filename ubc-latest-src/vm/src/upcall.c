/*
 * upcall.c - call from the runtime into Emerald
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
