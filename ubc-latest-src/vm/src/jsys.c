/*
 * The Emerald interface to the system.
 */

#define E_NEEDS_NETDB
#define E_NEEDS_STRING
#include "system.h"

#include "vm_exp.h"
#include "init.h"
#include "trace.h"
#include "types.h"
#include "globals.h"
#include "oidtoobj.h"
#include "assert.h"
#include "creation.h"
#include "gc.h"
#include "rinvoke.h"
#include "move.h"
#include "remote.h"
#include "timer.h"

/*
 * Here is the name of the machine we are on.
 */
String SysName;

/*
 * Here is our lnn, whatever inet_lnaof returns
 */
static int syslnn = -1;

/*
 * Our incarnation time is created in remote.c:init_nodeinfo.
 */
extern Object inctm;

/*
 * Here are pointers to our standard input and output streams
 */
Object StdInStream, StdOutStream;

/*
 * System routines which take arguments find those arguments
 * immediately above the current sp.
 */

#define sp state->sp  

/*
 * The get* functions all return various pieces of the system state.
 * They take no parameters.
 */
int getstdin(State *state)
{
  PUSH(Object, StdInStream);
  return 0;
}
int getstdout(State *state)
{
  PUSH(Object, StdOutStream);
  return 0;
}

int gettod(State *state)
{
  if (gettimeofday((struct timeval *)sp, 0) < 0)
    TRACE(sys, 1, ("gettimeofday fails!"));
  TRACE(sys, 3, ("gettimeofday returns %d:%06d", 
		 ((struct timeval *)sp)->tv_sec,
		 ((struct timeval *)sp)->tv_usec));
  sp += 2 * sizeof(int);
  return 0;
}
int getlnn(State *state)
{
  PUSH(u32, syslnn);
  return 0;
}

int getname(State *state)
{
  TRACE(sys, 1, ("getname returns %.*s", SysName->d.items, SysName->d.data));
  PUSH(String, SysName);
  return 0;
}

int jgetIncarnationTime(State *state)
{
  PUSH(Object, inctm);
  return 0;
}

int jgetLoadAverage(State *state)
{
  double avg = 1.0;
  int ret;
#if defined(i386freebsd)
  ret = getloadavg(&avg, 1);
  if (ret < 1) {
    TRACE(sys, 0, ("getloadavg failed, ret %d", ret));
    avg = 1.0;
  }
#endif
  PUSH(float, (float) avg);
  return 0;
}

int jisfixed(State *state)
{
  ConcreteType ct;
  Object o;

  o = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);

  if (ISNIL(o) || !HASODP(ct->d.instanceFlags)) {
    PUSH(int, 0);
    PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
    return 0;
  } else if (RESDNT(o->flags)) {
    PUSH(int, isFixedHere(o));
    PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
    return 0;
#ifdef DISTRIBUTED
  } else {
    doIsFixed(o, state, 0);
    return 1;
#endif
  }
}

/*
 *  Return true if the object is local.
 */
int jislocal(State *state)
{
  ConcreteType ct;
  Object o;
  int ans;

  o = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);

  ans = ISNIL(o) || !HASODP(ct->d.instanceFlags) || RESDNT(o->flags);
  PUSH(int, ans);
  PUSH(ConcreteType, BuiltinInstCT(BOOLEANI));
  return 0;
}

int getallnodes(State *state)
{
  Vector ans = getnodes(0);
  PUSH(Vector, ans);
  return 0;
}

int getactivenodes(State *state)
{
  Vector ans = getnodes(1);
  PUSH(Vector, ans);
  return 0;
}

int nProcessesDelayed = 0;

static void delayCallback(void *arg)
{
  State *state = arg;
  TRACE(sys, 3, ("delay: thread %x waking", state));
  TRACE(process, 3, ("process %x waking", state));
  nProcessesDelayed --;
  makeReady(state);
}

int delay(State *state)
{
  JTime t = *(JTime *)sp;
  struct timeval tv;
  TRACE(sys, 3, ("delay: sleeping for %d.%06d", t->d.secs, t->d.usecs));
  TRACE(process, 3, ("process %x sleeping for %d.%06d", state, t->d.secs, t->d.usecs));
  if (t->d.secs < 0 || (t->d.secs == 0 && t->d.usecs < 100)) return 0;
  tv.tv_sec = t->d.secs;
  tv.tv_usec = t->d.usecs;
  afterTime(tv, delayCallback, state);
  nProcessesDelayed++;
  return 1;
}

int jfix(State *state)
{
  ConcreteType ct, d_ct;
  Object obj, d;
  int retc = 0;

  obj = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);
  d = *(Object *)(sp+8);
  d_ct = *(ConcreteType *)(sp+12);

  TRACE(sys, 2, ("fix of %x at location of %x", obj, d));
#ifdef DISTRIBUTED
  if (ISNIL(obj) || !HASODP(ct->d.instanceFlags) || ISIMUT(ct->d.instanceFlags)) {
    /* do nothing */
  } else {
    Object dn = whereIs(d, d_ct);
    if (ISNIL(dn)) {
      return unavailable(state, d);
    } else if (RESDNT(dn->flags) && RESDNT(obj->flags)) {
      fixHere(obj);
    } else {
      move(1, obj, getLocFromObj(dn), state);
      retc = 1;
    }
  }
#endif
  return retc;
}

int jrefix(State *state)
{
  ConcreteType ct, d_ct;
  Object obj, d;
  int retc = 0;

  obj = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);
  d = *(Object *)(sp+8);
  d_ct = *(ConcreteType *)(sp+12);

  TRACE(sys, 2, ("refix of %x at location of %x", obj, d));
#ifdef DISTRIBUTED
  if (ISNIL(obj) || !HASODP(ct->d.instanceFlags) || ISIMUT(ct->d.instanceFlags)) {
    /* do nothing */
  } else {
    Object dn = whereIs(d, d_ct);
    if (ISNIL(dn)) {
      return unavailable(state, d);
    } else if (RESDNT(dn->flags) && RESDNT(obj->flags)) {
      fixHere(obj);
    } else {
      move(2, obj, getLocFromObj(dn), state);
      retc = 1;
    }
  }
#endif
  return retc;
}

int junfix(State *state)
{
  ConcreteType ct;
  Object o;

  o = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);
  TRACE(sys, 2, ("unfix of %x", o));
  if (RESDNT(o->flags)) {
    unfixHere(o);
    return 0;
#ifdef DISTRIBUTED
  } else {
    doIsFixed(o, state, 1);
    return 1;
#endif
  }
}

int jmove(State *state)
{
  ConcreteType ct, d_ct;
  Object obj, d;
  int retc = 0;

  obj = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);
  d = *(Object *)(sp + 8);
  d_ct = *(ConcreteType *)(sp + 12);

#ifdef DISTRIBUTED
  if (ISNIL(obj) || !HASODP(ct->d.instanceFlags) || ISIMUT(ct->d.instanceFlags)) {
    /* do nothing */
  } else {
    Object dn = whereIs(d, d_ct);
    if (ISNIL(dn)) {
      return unavailable(state, d);
    } else if (RESDNT(dn->flags) && RESDNT(obj->flags)) {
    } else if (RESDNT(obj->flags) && isFixedHere(obj)) {
      retc = 0x1000;
    } else {
      move(0, obj, getLocFromObj(dn), state);
      retc = 1;
    }
  }
#endif
  TRACE(sys, 3, ("move: completed with code %x", retc));
  return retc;
}

int getnode(State *state)
{
  PUSH(Object, OIDFetch(thisnode->node));
  return 0;
}

int jlocate(State *state)
{
  ConcreteType ct;
  Object obj, dn;

  obj = *(Object *)sp;
  ct = *(ConcreteType *)(sp+4);
  TRACE(sys, 2, ("locate of %x", obj));
#ifdef DISTRIBUTED
  dn = whereIs(obj, ct);
  if (ISNIL(dn)) {
    /* The node the object was on is dead */
    printf("Should this raise unavailable?\n");
    PUSH(Object, dn);
    PUSH(ConcreteType, (ConcreteType)JNIL);
    return 0;
  } else if (RESDNT(dn->flags)) {
    PUSH(Object, dn);
    PUSH(ConcreteType, BuiltinInstCT(NODEI));
    return 0;
  } else {
    findLocation(obj, ct, state, 0);
    return 1;
  }
#else
  dn = OIDFetch(thisnode->node);
  TRACE(sys, 2, ("Locate returns node %x", dn));
  PUSH(Object, dn);
  PUSH(ConcreteType, BuiltinInstCT(NODEI));
  return 0;
#endif
}

#undef sp

#define MAXFOO 128

void sysinit(void)
{
  unsigned int stack[32];
  ConcreteType ct;
  extern Node MyNode;
  /*
   * Query UNIX for hostname and lnn
   */
  char name[MAXFOO];

  inhibit_gc++;

#if !defined(WIN32)
  if (gethostname(name, sizeof name) < 0) {
    fprintf(stderr, "Can't get my own host name, making one up\n");
    strcpy(name, "imaginary");
  }

#else
#if defined(SYSTYPE_SYSV)
  strcpy(name, "Some SYSV machine");
#endif
#if defined(WIN32)
  strcpy(name, "DOS-PC");
#endif
#endif
  SysName = (String) CreateVector(BuiltinInstCT(STRINGI), strlen(name));
  memmove(SysName->d.data, name, SysName->d.items);
  syslnn = MyNode.port << 16 | MyNode.epoch;
  TRACE(sys, 1, ("Started on %.*s <%08x.%04x.%04x>", 
		 SysName->d.items, SysName->d.data,
		 ntohl(MyNode.ipaddress), MyNode.port, 
		 MyNode.epoch));

  /*
   * Create StdInStream and StdOutStream.  The initially expects a single
   * integer filedescriptor on the top of the stack, and that's all folks.
   */
  if ((ct = BuiltinInstCT(INSTREAMI)) == 0) {
    StdInStream = (Object) JNIL;
    fprintf( stderr, "StdInStream initialized to JNIL\n" );
  } else {
    stack[0] = 0;
    stack[1] = (unsigned int)intct;
    StdInStream = CreateObjectFromOutside(ct, (unsigned int)stack);
  }
  if ((ct = BuiltinInstCT(OUTSTREAMI)) == 0) {
    StdOutStream = (Object) JNIL;
    fprintf( stderr, "StdOutStream initialized to JNIL\n" );
  } else {
    stack[0] = 1;
    stack[1] = (unsigned int)intct;
    StdOutStream = CreateObjectFromOutside(ct, (unsigned int) stack);
  }
  inhibit_gc--;
}

