/*
 * Emerald Check Point Reader
 */
#define E_NEEDS_NTOH
#define E_NEEDS_STRING
#include "system.h"

#include "vm_exp.h"
#include "storage.h"
#include "array.h"
#include "assert.h"
#include "write.h"
#include "globals.h"
#include "iisc.h"
#include "oisc.h"
#include "iosc.h"
#include "iset.h"
#include "joveisc.h"
#include "jvisc.h"
#include "read.h"
#include "oidtoobj.h"
#include "filestr.h"
#include "trace.h"
#include "rinvoke.h"
#include "call.h"
#include "gc.h"
#include "squeue.h"

#define E_NEEDS_EXTRACT_OBJECT_DESCRIPTOR
#include "extract.h"

extern int  doCompression, writeCP, beVerbose;

#define CPFILE "/lib/Builtins"

/*
 * checkpoint files contain five fundamental kinds of information indicated
 * by these signatures.  AbCons are currently not generated.
 *
 * CP file formats are as follows:
 *
 *   "Object"      "NoOID"        "Extern"       "AbCon"      "Make Me"
 * |-----------| |-----------| |-----------| |-----------| |-----------|
 * |   +OB+    | |   +OB-    | |   -OB-    | |   +AC+    | |   *OB*    |
 * |-----------| |-----------| |-----------| |-----------| |-----------|
 * |  LENGTH   | |  LENGTH   | |   OID     | |   ABOID   | |   CONOID  |
 * |-----------| |-----------| |-----------| |-----------| |-----------|
 * |   OID     | |   DATA    | | more OID  | |more ABOID | |more CONOID|
 * |-----------| |    ...    | |-----------| |-----------| |-----------|
 * | more OID  | |-----------| | more OID  | |more ABOID | |more CONOID|
 * |-----------|               |-----------| |-----------| |-----------|
 * | more OID  |                             |   CONOID  | |  INOID    |
 * |-----------|                             |-----------| |-----------|
 * |   DATA    |                             |more CONOID| |more INOID |
 * |    ...    |                             |-----------| |-----------|
 *                                           |more CONOID| |more INOID |
 *                                           |-----------| |-----------|
 *
 * For regular ordinary objects, then, there is a fundamental translation
 * of 20 bytes (5 longwords in pointer-arithmetic land) from the signature
 * to the object itself.
 */

ConcreteType ctct, intct;

static void ReadObjectDescriptor(Object o, Stream theStream);
static void ReadSignature(Signature *theSignature, Stream theStream);
static void findRecoveries(CheckpointData *theContents);
static void findInitiallies(CheckpointData *theContents);
static void foldObjects(CheckpointData *theContents);
static void interp_template(Object o, char *s, CheckpointData *theContents);
static void translateOneObject(Object o, CheckpointData *theContents);
static void translateTheCheckpointArray(CheckpointData *theContents);
static void doMakeObjects(CheckpointData *theContents);
static void interpretLineNumbers(char *s, char *limit);
static void doLookAtEm(CheckpointData *theContents);
static void ReadTheCheckpointStream(CheckpointData *theContents,
				    Stream theStream);
static void ProcessCheckpointStream(CheckpointData *theContents,
				    Stream theStream);
static inline Object indexToObject(unsigned int index, Object within,
				   int offset, CheckpointData *theContents);

Node nonode = {0, 0, 0};

char signatures[NUM_SIGNATURES + 1][filesizeofSignature] = {
  "+OB+",
  "+OB-",
  "-OB-",
  "+AC+",
  "*OB*",
  "#!  ",
  "DONE",
  "-OS+",
  "-OV+",
  "+SQ-",
  "????"
  };

/*
 * A table of processes to start.
 */
OISc	    relocationMap;
IISc	    notHostedMap;

/*
 * The Constant Tables for strings and opvectorentries
 */
static JVISc       StrConstMap;
static JOVEISc     OVEConstMap;
IISc               translateMap;

void ReadInit(void)
{
  relocationMap = OIScCreate();
  notHostedMap = IIScCreateN(1000);
}

/*
 * Read an object descriptor from theStream into o
 */
static void ReadObjectDescriptor(Object o, Stream theStream)
{
  Bits8 *theBuffer;

  theBuffer = ReadStream(theStream, filesizeofObjectDescriptor);
  ExtractObjectDescriptor(o, theBuffer);
}

/* Used only for folding */
unsigned int indexToBuiltinIndex(int index, CheckpointData *theContents)
{
  Object o = (Object) ASUB(theContents->Objects, index);
  int answer = -1;
  OID oid;

  if (ISNIL(o)) {
    oid = IOScLookup(theContents->Externs, index);
  } else {
    oid = OIDOf(o);
  }
  if (isNoNode(oid) && isBuiltinINSTCT(oid.Seq)) {
    answer  = oid.Seq - INSTCTOFBUILTINOBJECTBASE;
  }
  return answer;
}

void registerRelocation(OID oid, Object o, int offset)
{
  ISet relocations;
  Relocation *r = (Relocation *) vmMalloc(sizeof(Relocation));

  TRACE(relocation, 1,
	 ("Registering relocation for oid %#x to location %#x+%#x",
	  oid.Seq, o, offset));
  relocations = (ISet) OIScLookup(relocationMap, oid);
  if (OIScIsNIL(relocations)) {
    relocations = ISetCreate();
    OIScInsert(relocationMap, oid, (int)relocations);
  }
  r->o = o;
  r->offset = offset;
  ISetInsert(relocations, (int)r);
}

static inline 
Object indexToObject(unsigned int index, Object within,
		     int offset, CheckpointData *theContents)
{
  Object o;
  OID    oid;

  if (ISNIL(index))
    return (Object) JNIL;

  if (doCompression) {
    o = (Object) IIScLookup(translateMap, (int)index);
    if (!IIScIsNIL(o)) 
      return o;
  }
  o = (Object) ASUB(theContents->Objects, (int)index);
  if (!ISNIL(o))
    return o;
  oid = IOScLookup(theContents->Externs, (int)index);
  o = OIDFetch(oid);

  if (!ISNIL(o)) 
    return o;
  else {
    registerRelocation(oid, within, offset);
    return (Object) JNIL;
  }
}

char *findHisTemplate(ConcreteType ct)
{
  char       *t;

  if (!ISNIL(ct->d.template)) {
    t = (char *) (ct->d.template->d.data); 
  } else {
    t = (char *)0;
  }
  return t;
}

/*
 * FindRecoveries goes through the object array.  Each object with a
 * recovery is frozen.
 */
static void findRecoveries(CheckpointData *theContents)
{
  int         i, size = ARRAYSIZE(theContents->Objects);
  Object      o;
  ConcreteType ct;

  for (i = 0; i < size; i++) {
    o = (Object) ASUB(theContents->Objects, i);
    if (ISNIL(o)) continue;
    if (!wasGCMalloced(o)) continue;
    ct = CODEPTR(o->flags);
    if (CODEPTRINDEX(o->flags) <= NUMBUILTINS) {
      /* no recovery */
    } else if (HASRECOVERY(ct)) {
      /*
       * break until recovery occurs
       */
      freeze(o, RInitially);
      if (HASPROCESS(ct)) scheduleProcess(o, OVE_RECOVERY);
      TRACE(initiallies, 1, ("Need to recover a %.*s obj %#x", 
	     ct->d.name->d.items, ct->d.name->d.data, o));
    }
  }
}

IISc tobeinitialized;
/*
 * FindInitiallies goes through the MKOB array
 */
static void findInitiallies(CheckpointData *theContents)
{
  OID	     *oid;
  Object      o;
  int         i, size = ARRAYSIZE(theContents->MakeObjects);
  ConcreteType ct;
  extern int activelyInitialize;

  if (activelyInitialize) tobeinitialized = IIScCreate();
  for (i = 0; i < size; i++) {
    oid = (OID *) ASUB(theContents->MakeObjects, i);
    /* lookup his CT */
    ct = (ConcreteType) OIDFetch(*oid);
    assert(!ISNIL(ct));
    if (ISNIL(oid[1].Seq) || (!oid[1].Seq)) {
      o = CreateUninitializedObject(ct);
    } else {
      o = OIDFetch(*(oid + 1));
      if (ISNIL(o)) {
	TRACE(initiallies, 0, ("Find initially needs to create %#x",
			       oid[1].Seq));
	o = CreateUninitializedObject(ct);
	OIDInsert(oid[1], o);
      }
    }

    if (HASINITIALLY(ct) || HASPROCESS(ct)) {
      if (HASINITIALLY(ct)) freeze(o, RInitially);
      if (HASPROCESS(ct) || ISCOMPILATION(ct)) {
	scheduleProcess(o, HASINITIALLY(ct) ? OVE_INITIALLY : OVE_PROCESS);
      } else if (activelyInitialize) {
	IIScInsert(tobeinitialized, (int)o, 0);
      }
      TRACE(initiallies, 1, ("Need to initialize a %.*s id %#x",
			     ct->d.name->d.items, ct->d.name->d.data,
			     oid[1].Seq));
    }
    vmFree(oid);
  }
}

void fixObjectReference(OID oid, Object within, int offset)
{
  Object      o;

  o = OIDFetch(oid);
  if (ISNIL(o)) {
    registerRelocation(oid, within, offset);
    *(Object *)((char *)within + offset) = (Object) JNIL;
  } else {
    *(Object *)((char *)within + offset) = o;
    stoCheck(within, o);
  }
}

void fixObjectReferenceFromSeq(unsigned seq, Object within, int offset)
{
  OID oid;
  oid = nooid;
  oid.Seq = seq;
  fixObjectReference(oid, within, offset);
}

void fixCTLiterals(ConcreteType ct)
{
  if (ISNIL(ct->d.literals)) return;
  if (ct->d.literals->d.items > 0) {
    int nLiterals = ct->d.literals->d.items
      / (sizeof(struct LFERep) / 4);
    struct LFERep *lfe = &ct->d.literals->d.data[0];
    int i;
#ifdef USEABCONS
    struct LFERep *ab, *con;
    AbCon abcon;
#endif

    for (i = 0; i < nLiterals; i++, lfe++) {
#ifdef USEABCONS
      switch (lfe->oid.Unused) {
      case 0:
#endif
	fixObjectReference(lfe->oid, (Object)ct->d.literals, 
			   OffsetOf(ct->d.literals, &lfe->ptr));
#ifdef USEABCONS
	break;
      case 1:
	/* This is actually the first oid in an ab/con pair */
	ab = lfe++;
	con = lfe;
	i++;
#ifdef USEABCONS
	{
	  OID aboid = ab->oid;
	  OID conoid = con->oid;
	  aboid.Unused = 0;
	  conoid.Unused = 0;
	  abcon = findAbCon(aboid, conoid);
	  ab->ptr = (Object)abcon;
	  con->ptr = (Object)abcon;
	}
#else
	fixObjectReference(con->oid, (Object)ct->d.literals, 
			   OffsetOf(ct->d.literals, &ab->ptr));
	fixObjectReference(con->oid, (Object)ct->d.literals,
			   OffsetOf(ct->d.literals, &con->ptr));
#endif
	break;
      }
#endif
    }
  }
}

void showCTLiterals(ConcreteType ct)
{
  if (ISNIL(ct->d.literals)) return;
  if (ct->d.literals->d.items > 0) {
    int nLiterals = ct->d.literals->d.items
      / (sizeof(struct LFERep) / 4);
    struct LFERep *lfe = &ct->d.literals->d.data[0];
    int i;
#ifdef USEABCONS
    struct LFERep *ab, *con;
    AbCon abcon;
#endif

    TRACE(trans, 2, ("  Literals: (%#x)", ct->d.literals));
    for (i = 0; i < nLiterals; i++, lfe++) {
#ifdef USEABCONS
      switch (lfe->oid.Unused) {
      case 0:
#endif
	TRACE(trans, 2, ("%6d: (%#x) OID %#x -> %#x", i, &lfe->ptr,
			 lfe->oid.Seq, lfe->ptr));
#ifdef USEABCONS
	break;
      case 1:
	/* This is actually the first oid in an ab/con pair */
	TRACE(trans, 2, ("Found an Ab/Con relocation item"));
	ab = lfe++;
	con = lfe;
	i++;
	{
	  OID aboid = ab->oid;
	  OID conoid = con->oid;
	  aboid.Unused = 0;
	  conoid.Unused = 0;
	  abcon = findAbCon(aboid, conoid);
	  TRACE(trans, 2, ("%6d: Ab/Con (0x%08x, 0x%08x) -> 0x%08x", 
			   i - 1, ab->oid.Seq, con->oid.Seq, abcon));
	  ab->ptr = (Object)abcon;
	  con->ptr = (Object)abcon;
	}
	break;
      }
#endif
    }
  }
}

int fixHandlers(String c)
{
  int         n;
  struct FHC *fhc;

  /*
   * start working through the handlers.  The structure is a variable number
   * of these:
   *	blockStart   (2 bytes)
   *	blockEnd     (2 bytes)
   *	handlerStart (2 bytes)
   *	variableOff  (2 bytes)
   *	name	     (4 bytes)
   *		0 == failure
   *		1 == unavailable
   *		? == userdefined (the name is hashed)
   * 
   * followed by:
   *	count        (2 bytes)
   *	'h' 'c'      (2 bytes)
   *
   * But this whole thing only exists if the 'h' and 'c' are there.
   */

  fhc = (struct FHC *)&c->d.data[c->d.items - 4];
  if (fhc->h == 'h' && fhc->c == 'c') {
    n = ntohs(fhc->count);
  } else {
    n = 0;
  }
  return n;
}

/*
 * Fold identical immutable objects
 */
static void foldObjects(CheckpointData *theContents)
{
  static int  stringsinserted, stringsfound, strbytesfreed;
  static int  ovesinserted, ovesfound, ovebytesfreed;
  int         i, size = ARRAYSIZE(theContents->Objects);
  int	      whichBuiltin;
  Object      o;
  String      s = 0;
  OpVectorElement e;
  int         q, n = 0;

  if (!doCompression) return;
  StrConstMap = JVIScCreate();
  OVEConstMap = JOVEIScCreate();
  translateMap = IIScCreate();

  TRACE(map, 2, ("Object array has %d entries\n", size));
  for (i = 0; i < size; i++) {
    o = (Object)ASUB(theContents->Objects, i);
    if (ISNIL(o) || !wasGCMalloced(o)) continue;

    whichBuiltin = indexToBuiltinIndex(CODEPTRINDEX(o->flags), theContents);

    switch (whichBuiltin) {
    case COPVECTOREI:
      e = (OpVectorElement) o;
      IFTRACE(fold, 5) {
	s = (String) ASUB(theContents->Objects, 
			 ntohl((int)e->d.name));
	n = ntohl(s->d.items);
      }
      q = JOVEIScLookup(OVEConstMap, e, theContents->Objects);
      if (q == -1) {
	TRACE(fold, 5, ("inserting an OVE %#x (%.*s) (%dth)",
			e, n, s->d.data, ++ovesinserted));
	JOVEIScInsert(OVEConstMap, e, (int)e, theContents->Objects);
      } else {
	ovebytesfreed += sizeof(struct OpVectorElement);
	++ovesfound;
	TRACE(fold, 5, ("found OVE %#x (%.*s) at %x (%d found %d freed)",
			e, n, s->d.data, q, ovesfound, ovebytesfreed));
	ASUB(theContents->Objects, i) = JNIL;
	IIScInsert(translateMap, i, q);
      }
      break;
    case STRINGI:
      s = (String) o;
      n = ntohl(s->d.items);
      if (HASOID(s->flags))
	break;
      q = JVIScLookup(StrConstMap, s);
      if (q == -1) {
	TRACE(fold, 5, ("inserting string %#x (%d:%.*s) (%d inserted)",
			s, n, n, s->d.data, ++stringsinserted));
	JVIScInsert(StrConstMap, s, (int)s);
      } else {
	strbytesfreed += sizeofCode + ROUNDUP(n);
	++stringsfound;
	TRACE(fold, 5, ("found str %#x (%d:%.*s) at %x (%d found %d freed)",
			s, n, n, s->d.data, q, stringsfound, strbytesfreed));
	ASUB(theContents->Objects, i) = JNIL;
	IIScInsert(translateMap, i, q);
      }
    }
  }

  JOVEIScDestroy(OVEConstMap);
  OVEConstMap = NULL;
  JVIScDestroy(StrConstMap);
  StrConstMap = NULL;

  if (beVerbose) {
    printf("%d strings (%d bytes), %d OVEs (%d bytes) freed\n",
	   stringsfound, strbytesfreed, ovesfound, ovebytesfreed);
    strbytesfreed = ovebytesfreed = 0;
  }
}

static void translateCT(ConcreteType ct, CheckpointData *theContents)
{
  if (HOSTED(ct)) return;
  SETHOSTED(ct);
  SETCODEPTR(ct->flags, indexToObject(CODEPTRINDEX(ct->flags), 0, 0, theContents));
  interp_template((Object)ct, "%2d%6X", theContents);
  translateOneObject((Object)ct->d.literals, theContents);
  fixCTLiterals(ct);
}

/*
 * Objects are converted from network to host byte order via interpretation
 * of a "template" string found in the Concrete Type's description of the
 * object.  So far v, x, d, m, c, b are handled, with either a constant
 * or '*' count allowed between the % and the type char.
 */
static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}
static void interp_template(Object o, char *s, CheckpointData *theContents)
{
  Bits32      *p = (Bits32 *) o->d;
  int         count, isAnArray;
  char        c;

  if (!s)
    return;
  TRACE(templ, 2, ("interp_template, o = %#x, s = %s", o, s));
  while (1) {
    switch (*s++) {
    case '%':
      count = isAnArray = 0;
      while (misdigit(c = *s++)) {
	count = count * 10 + c - '0';
      }
      if (!count)
	count = 1;
      if (c == '*') {
	count = *p = ntohl(*p);
	isAnArray = 1;
	p++;
	c = *s++;
      }
      TRACE(templ, 3, ("interp_template count %d", count));
      switch (c) {
      case 'l':
      case 'L':
	while (count--) {
	  *p = ntohl(*p);
	  p++;
	}
	break;
      case 'v':
      case 'V':
	while (count--) {
	  p[1] = (int) indexToObject(ntohl(p[1]), o, OffsetOf(o, p), theContents);
	  if (ISNIL(p[1])) {
	    *p = (int) indexToObject(ntohl(*p), o, OffsetOf(o, p), theContents);
	    assert(ISNIL(*p));
	  } else {
	    translateCT((ConcreteType)p[1], theContents);
	    if (HASODP(((ConcreteType)p[1])->d.instanceFlags)) {
	      *p = (int) indexToObject(ntohl(*p), o, OffsetOf(o, p), theContents);
	      stoCheck(o, (Object)*p);
	    } else {
	      *p = ntohl(*p);
	    }
	    stoCheck(o, (Object)(p[1]));
	  }
	  p+=2;
	}
	break;
      case 'x':
      case 'X':
	while (count--) {
	  *p = (int) indexToObject(ntohl(*p), o, OffsetOf(o, p), theContents);
	  stoCheck(o, (Object)*p);
	  p++;
	}
	break;
      case 'd':
      case 'D':
	while (count--) {
	  *p = ntohl(*p);
	  p++;
	}
	break;
      case 'f':
      case 'F':
	while (count--) {
	  *p = ntohl(*p);
	  p++;
	}
	break;
      case 'm':
	{
	  /* recover a monitor.  We set it to not busy, and initialize the */
	  /* waiting queue. */
	  monitor *m = (monitor *)p;
	  assert(count == 1);
	  m->busy = ntohl(m->busy);
	  m->waiting = (SQueue)ntohl((int)m->waiting);
	  if (ISNIL(m->waiting)) {
	    TRACE(trans, 1, ("Set up new monitor queue for object %x", o));
	    m->waiting = 0;
	  } else {
	    m->waiting = (SQueue)indexToObject((int)m->waiting, 0, 0, theContents);
	    TRACE(trans, 1, ("Set up monitor queue for object %x to %d waiters", 
			     o, SQueueSize(m->waiting)));
	  }
	  p += 2;
	}
	break;
      case 'q':
	{
	  /* recover an squeue */
	  assert(count == 1);
	  *p = ntohl(*p);
	  if (ISNIL(*p)) {
	    *p = (int)SQueueCreate();
	    TRACE(trans, 1, ("Set up new condition queue for object %x", o));
	  } else {
	    *p = (int)indexToObject(*p, 0, 0, theContents);
	    TRACE(trans, 1, ("Set up condition queue for object %x to %d waiters", 
			     o, SQueueSize((SQueue)*p)));
	  }
	  p++;
	}
	break;
      case 'c':
      case 'C':
      case 'b':
      case 'B':
	if (isAnArray) {
	  p += ((ROUNDUP(count)) / 4);
	} else {
	  while (count--) {
	    *p = ntohl(*p);
	    p++;
	  }
	}
	break;
      default:
	assert(0);
      }
      break;
    case '\0':
      return;
    default:
      break;
    }
  }
}

static void translateOneObject(Object o, CheckpointData *theContents)
{
  ConcreteType ct;
  char	     *t = 0;

  if (!HOSTED(o)) {
    SETHOSTED(o);

    ct = (ConcreteType) indexToObject(CODEPTRINDEX(o->flags), 0, 0, theContents);
    /*
     * look up his codePtr and traverse it as a concrete type
     */
    assert(!ISNIL(ct));
    if (!HOSTED(ct)) {
      /* minimal translate one object for concrete types */
      translateCT(ct, theContents);
    }
    if (RESDNT(o->flags)) {
      t = findHisTemplate(ct);
      if (t) interp_template(o, t, theContents);
      if (ct == ctct) {
	ConcreteType newct = (ConcreteType)o;
	translateOneObject((Object)newct->d.literals, theContents);
	fixCTLiterals(newct);
      }
    }
    SETCODEPTR(o->flags, ct);
    stoCheck(o, (Object)ct);
  }
}

void doAnSQueue(void *o)
{
  /* Do nothing */
}

/*
 * translate all indices and indirect checkpoint entries
 */
static void translateTheCheckpointArray(CheckpointData *theContents)
{
  int         i, size = ARRAYSIZE(theContents->Objects);
  Object      o;

  for (i = 0; i < size; i++) {
    o = (Object) ASUB(theContents->Objects, i);
    if (ISNIL(o)) {
      /* do nothing */
    } else if (wasGCMalloced(o)) {
      translateOneObject(o, theContents);
    } else {
      doAnSQueue(o);
    }
  }
}

static void doDistGCObjects(CheckpointData *theContents)
{
  int         i, size = ARRAYSIZE(theContents->Objects);
  Object      o;

  if (!inDistGC()) return;
  for (i = 0; i < size; i++) {
    o = (Object) ASUB(theContents->Objects, i);
    if (!wasGCMalloced(o)) continue;
    if (ISNIL(o)) continue;
    if (RESDNT(o->flags)) {
      incomingObject(o);
    } else {
      incomingRef(o, isGrey(o) ? 0 : DISTGCBIT);
    }
  }
}

static void doMakeObjects(CheckpointData *theContents)
{
  int         i, size = ARRAYSIZE(theContents->MakeObjects);
  OID        *oid;
  ConcreteType ct;
  Object      o;

  /*
   * Find MKOBs with referencable ids and do them
   */
  for (i = 0; i < size; i++) {
    oid = (OID *)ASUB(theContents->MakeObjects, i);
    /* lookup his CT */
    ct = (ConcreteType) OIDFetch(*oid);
    if (!ISNIL(oid[1].Seq) && oid[1].Seq) {
      o = OIDFetch(*(oid + 1)); 
      if (ISNIL(o)) {
	o = CreateUninitializedObject(ct);
	OIDInsert(oid[1], o);
      }
    }
  }
}

/*
 * The format is:
 *	#n		n is the starting line number
 * Followed by a sequence of either
 *	;n		n is the number of bytes of code for that line
 *	+n		n is the number of lines to add with no code
 *	#n		n is the number of the next line, no code
 * ;0 == +1
 */
static void interpretLineNumbers(char *s, char *limit)
{
  char       *rest;
  int         number, off = 0, this = -1;

  assert(*s == '#');
  s++;
  number = mstrtol(s, &rest, 10);
  printf("\tOffset\t\tLineNumber\n");
  while (rest < limit) {
    printf("\t%5d\t\t%5d\n", off, number);
    if (*rest == ';') {
      rest++;
      this = mstrtol(rest, &rest, 10);
      off += this;
      number++;
    } else if (*rest == '+') {
      rest++;
      this = mstrtol(rest, &rest, 10);
      number += this;
    } else if (*rest == '#') {
      rest++;
      number = mstrtol(rest, &rest, 10);
    } else {
      assert(0);
    }
  }
  printf("\t%5d\t\t%5d\n", off, number);
}

/*
 * Everyone always wants a pass in which lots of debugging
 * information gets printed out, at least if they have compiler bugs!
 * This function also does one important thing not related to debugging:
 *	fixes the literals in ConcreteTypes
 */
static void doLookAtEm(CheckpointData *theContents)
{
  int         i, size = ARRAYSIZE(theContents->Objects);
  ConcreteType ct;
  Object      o;
  IISc	      ctToSizes = 0;
  IISc	      ctToNumber = 0;
  int 	      thissize = 0;

  IFTRACE(ctinfo, 1) {
    ctToSizes  = IIScCreateN(100);
    ctToNumber = IIScCreateN(100);
  }
  for (i = 0; i < size; i++) {
    o = (Object) ASUB(theContents->Objects, i);
    if (!wasGCMalloced(o)) continue;
    if (!ISNIL(o)) {
      ct = CODEPTR(o->flags);
      assert(ct);
      IFTRACE(ctinfo, 1) {
	thissize = ct->d.instanceSize + 4;
      }
      if (ct == ctct) {
	ConcreteType ct = (ConcreteType) o;

	TRACE(trans, 1,
	      ("%#x is a concrete type %#x \"%.*s\" \"%.*s\"", ct,
	       OIDSeqOf((Object)ct),
	       ct->d.name->d.items,
	       ct->d.name->d.data,
	       ct->d.filename->d.items,
	       ct->d.filename->d.data));
	TRACE(trans, 2, ("  name: \"%.*s\"",
			 ct->d.name->d.items, ct->d.name->d.data));
	TRACE(trans, 2, ("  file name: \"%.*s\"",
			 ct->d.filename->d.items, ct->d.filename->d.data));
	TRACE(trans, 2, ("  instance size: %d", ct->d.instanceSize));
	if (!ISNIL(ct->d.template)) {
	  TRACE(trans, 2, ("  template: %s", 
		 (char *)(ct->d.template->d.data)));
	  IFTRACE(trans, 2) {
	    int   i = 0; 
	    int   n = ct->d.template->d.items;
	    unsigned char *d = 
	      (unsigned char *)(ct->d.template->d.data);

	    TRACE(trans, 2, ("  variables"));
	    for (; d[i]; i++);
	    i++;
	    while (i < n && d[i] != '#') {
	      printf("    %s\n", d + i);
	      for (; d[i]; i++);
	      i++;
	    }
	  }
	}
	showCTLiterals(ct);
      } else if (ct == BuiltinInstCT(COPVECTORI) || (int)ct == COPVECTORI) {
	int         i;
	OpVector    v = (OpVector) o;

	TRACE(trans, 2, ("%#x is an op vector", v));
	TRACE(trans, 2, ("  %d entries:", v->d.items));
	for (i = 0; i < v->d.items; i++) {
	  TRACE(trans, 2, ("    d[%d] = %#x", i, v->d.data[i]));
	}
	IFTRACE(ctinfo, 1) {
	  thissize = sizeofOpVector + v->d.items * sizeof(struct OpVectorElement *);
	}
      } else if (ct == BuiltinInstCT(COPVECTOREI) || (int)ct == COPVECTOREI) {
	OpVectorElement e = (OpVectorElement) o;

	TRACE(trans, 2, ("%#x is an op vector element", e));
	TRACE(trans, 2, ("  name: \"%.*s\" id: %d", 
			 e->d.name->d.items, e->d.name->d.data, e->d.id));
	if (e->d.code) {
	  int nHandlers = fixHandlers((String)e->d.code);
	  int hSize = nHandlers ? 4 + nHandlers * sizeof(struct FHE) :0;
	  TRACE(trans, 2, ("  code is %d - %d bytes long",
			   e->d.code->d.items, hSize));
	  IFTRACE(trans, 2) {
	    struct FHE *fhe;
	    int i;
	    fhe = (struct FHE *)&e->d.code->d.data[e->d.code->d.items - hSize];
	    for (i = 0; i < nHandlers; i++, fhe++) {
	      TRACE(trans, 2, ("%s handler for range [%d:%d] at %d",
			       ntohl(fhe->name) == 0 ? "failure" :
			       ntohl(fhe->name) == 1 ? "unavailable" :
			       "user defined",
			       ntohs(fhe->blockStart), ntohs(fhe->blockEnd),
			       ntohs(fhe->handlerStart)));
	      if (fhe->name == 1) 
		TRACE(trans, 4, ("variable at offset %d", fhe->variableOffset));
	    }
	  }
	  IFTRACE(trans, 2) {
	    int n = e->d.code->d.items;
	    disassemble((u32)e->d.code->d.data, n - hSize, stdout);
	  }
	} else {
	  TRACE(trans, 2, ("  No code"));
	}
	if (!ISNIL(e->d.template)) {
	  TRACE(trans, 2, ("  template: %s", 
			   (char *) (e->d.template->d.data)));
	  IFTRACE(trans, 2) {
	    int  i = 0; 
	    int  n = e->d.template->d.items;
	    unsigned char *d = e->d.template->d.data;

	    TRACE(trans, 2, ("  variables"));
	    for (; d[i]; i++);
	    i++;
	    while (i < n && d[i] != '#') {
	      printf("    %s\n", d + i);
	      for (; d[i]; i++);
	      i++;
	    }
	    IFTRACE(trans, 2) {
	      if (i < n) {
		TRACE(trans, 2, ("  Line Numbers"));
		interpretLineNumbers((char *)&d[i], (char *)&d[n]);
	      }
	    }
	  }
	}
      } else if (ct==BuiltinInstCT(ABSTRACTTYPEI) || (int)ct==ABSTRACTTYPEI) {
	AbstractType at = (AbstractType) o;

	TRACE(trans, 2, ("%#x is an abstract type", at));
	TRACE(trans, 2, ("  name: \"%.*s\"",
			 at->d.name->d.items, at->d.name->d.data));
	TRACE(trans, 2, ("  file name: \"%.*s\"",
			 at->d.filename->d.items, at->d.filename->d.data));
      } else if (ct == BuiltinInstCT(AOPVECTORI) || (int)ct == AOPVECTORI) {
	int         i;
	ATOpVector  v = (ATOpVector) o;

	TRACE(trans, 2, ("%#x is an abstract op vector with %d entries",
			 v, v->d.items));
	for (i = 0; i < v->d.items; i++) {
	  TRACE(trans, 2, ("    d[%d] = %#x", i, v->d.data[i]));
	}
	IFTRACE(ctinfo, 1) {
	  thissize = sizeofATOpVector + v->d.items * sizeof(struct ATOpVectorElement *);
	}
      } else if (ct == BuiltinInstCT(AOPVECTOREI) || (int)ct == AOPVECTOREI) {
	ATOpVectorElement e = (ATOpVectorElement) o;

	TRACE(trans, 2,
	      ("%#x is an abstract op vector element", e));
	TRACE(trans, 2, ("  id: %d name: \"%.*s\"", e->d.id, 
			 e->d.name->d.items, e->d.name->d.data));
	if (e->d.isFunction)
	  TRACE(trans, 2, ("  It is a function"));
	TRACE(trans, 2, ("  arguments: %#x, results: %#x",
			 e->d.arguments,
			 e->d.results));
      } else if (ct == BuiltinInstCT(APARAMLISTI) || (int)ct == APARAMLISTI) {
	int         i;
	ATTypeVector v = (ATTypeVector) o;

	TRACE(trans, 2, ("%#x is an abstract type vector with %d entries",
			 v, v->d.items));
	for (i = 0; i < v->d.items; i++) {
	  TRACE(trans, 2, ("    d[%d] = %#x", i, v->d.data[i]));
	}
	IFTRACE(ctinfo, 1) {
	  thissize = sizeofATTypeVector +
	    v->d.items * sizeof(AbstractType);
	}
      } else if (ct == BuiltinInstCT(STRINGI) || (int)ct == STRINGI) {
	String      s = (String) o;

	TRACE(trans, 2, ("%#x is a string (%d) \"%.*s\"",
			 s, s->d.items, s->d.items, 
			 s->d.data));
	IFTRACE(ctinfo, 1) {
	  thissize = sizeofString + s->d.items;
	}
      } else if (ct == BuiltinInstCT(SIGNATUREI) || (int)ct == SIGNATUREI) {
	AbstractType at = (AbstractType)o;
	TRACE(trans, 2,
	      ("%#x is a signature %#x \"%.*s\" \"%.*s\"", at,
	       OIDSeqOf((Object)at),
	       at->d.name->d.items,
	       at->d.name->d.data,
	       at->d.filename->d.items,
	       at->d.filename->d.data));
      } else if ((unsigned int)ct < NUMBUILTINS){
	TRACE(trans, 2, ("%#x has ct index %#x", o, ct));
      } else {
	TRACE(trans, 2, ("%#x has ct %#x, a %.*s",
			 o, ct, ct->d.name->d.items, 
			 ct->d.name->d.data));
	IFTRACE(ctinfo, 1) {
	  if (ct->d.instanceSize < 0) {
	    Vector      v = (Vector) o;
	    thissize = sizeofVector + -ct->d.instanceSize * v->d.items;
	  }
	}
      }
      IFTRACE(ctinfo, 1) {
	IIScBumpBy(ctToSizes, (int)ct, thissize);
	IIScBump(ctToNumber, (int)ct);
      }
    }
  }
  IFTRACE(ctinfo, 1) {
    ConcreteType ct;
    int number, size;
    IIScForEach(ctToSizes, ct, size) {
      number = IIScLookup(ctToNumber, (int)ct);
      ftrace("%4d instances of %.*s (%#x), total size = %d", 
	     number, ct->d.name->d.items, ct->d.name->d.data, ct, size);
    } IIScNext();
    IIScDestroy(ctToNumber);
    IIScDestroy(ctToSizes);
  }
}


/*
 * Read a signature from theStream into theSignature
 */
static void ReadSignature(Signature *theSignature, Stream theStream)
{
  Bits8 *theBuffer;
  Bits32 NumericSignature;
  int    i;

  theBuffer = ReadStream(theStream, filesizeofSignature);

  if (!theBuffer) { /* End of File */
    *theSignature = SigNone;
    return;
  }

  NumericSignature = *((Bits32 *) theBuffer);

  for (i = 0; i < NUM_SIGNATURES; i++)
    if (NumericSignature == *((Bits32 *) signatures[i])) {
      *theSignature = i;
      return;
    }

  TRACE(trans, 0, ("Unknown sig %x (%.4s)", NumericSignature, 
		   (char *)&NumericSignature));
  *theSignature = SigError;
}

static void ReadTheCheckpointStream(CheckpointData *theContents,
				    Stream theStream)
{
  u32         objectSize, idx, Done, flags;
  OID         oid, *oidp;
  Node  srv;
  Object      o;
  Signature   theSignature;
  int	      isnew;

  idx = 0;
  theContents->Objects = arrayCreate(2100);
  theContents->MakeObjects = arrayCreate(40);
  theContents->AbCons = arrayCreate(2);
  theContents->Externs = IOScCreate();
  Done = 0;
  while (!Done) {
    /* set up for adding to Objects */
    o = (Object)JNIL;
    /* read in the header */
    ReadSignature(&theSignature, theStream);
    TRACE(index, 3, ("%d: %.4s", idx, signatures[theSignature]));
    switch (theSignature) {
    case SigNone: /* End of file */
      Done = 1;
      continue;

    case Comment: /* This would be much faster if comments had length fields */
      {
	Bits8 *theBuffer;

	do {
	  theBuffer = ReadStream(theStream, 1);
	} while (*((char *) theBuffer) != '\n');
      }
      continue;

    case Stub:
    case VectorStub:
      /*
       * read in oid, concrete type index, location, and size.  Make a stub.
       */
      ReadOID(&oid, theStream);
      ExtractBits32(&objectSize, ReadStream(theStream, sizeof(Bits32)));
      ExtractBits32(&flags, ReadStream(theStream, sizeof(Bits32)));
      ReadNode(&srv, theStream);

      if (ISNIL(o = OIDFetch(oid))) {
	/*
	 * No distgc update needed.
	 */
	o = (Object) gc_malloc_old(objectSize, 0);
	o->flags = flags;
	IIScInsert(notHostedMap, (int)o, 1);
	CLEARRESDNT(o->flags);
	freeze(o, RRemote);
	UpdateOIDTables(oid, o);	
      } else {
	extern void forgetIsFixedHere(Object o);
	forgetIsFixedHere(o);
      }
#ifdef DISTRIBUTED
      if (!RESDNT(o->flags)) {
	updateLocation(o, srv);
	if (theSignature == VectorStub) {
	  int sizeinwords = objectSize / sizeof(u32);
	  setVectorSize(o, sizeinwords);
	}
      }
#endif

      TRACE(index, 3, ("\tOID: 0x%08x : 0x%02x : 0x%04x : 0x%08x",
		       oid.ipaddress, oid.port, oid.epoch, oid.Seq));

      break;

    case SQ:
      {
#ifdef DISTRIBUTED
	int numEntries, i;
	struct State *state;
	SQueue q;
	Node loc;

	ExtractBits32((u32 *)&numEntries, ReadStream(theStream, sizeof(Bits32)));
	q = SQueueCreate();
	for (i = 0; i < numEntries; i++) {
	  ReadOID(&oid, theStream);
	  ReadNode(&loc, theStream);
	  state = stateFetch(oid, loc);
	  SQueueInsert(q, state);
	}
	o = (Object) q;
#else
	assert(0);
#endif
      }
      break;
    case ObjectWithID:
    case ObjectWithoutID:
      /*
       * +OB+ --> read in length field and oid, maybe allocate space, read in object
       * +OB- --> read in length field, allocate space, read in object
       */
      ExtractBits32(&objectSize, ReadStream(theStream, sizeof(Bits32)));

      if (theSignature == ObjectWithID) {
	objectSize -= filesizeofOID;
	ReadOID(&oid, theStream);
      } else {
	oid = nooid;
      }
      if (theSignature == ObjectWithID && !ISNIL(o = OIDFetch(oid))) {
	isnew = 0;
	/* If is is a vector, then forget its size */
	if (CODEPTR(o->flags)->d.instanceSize < 0) {
	  TRACE(memory, 9, ("Vector %x became a non stub", o));
	  CLEARVZEROL(o->flags);
	}
      } else {
	o = (Object) gc_malloc_old(objectSize, 0);
	isnew = 1;
      }

      if (!isNoOID(oid)) {
	TRACE(index, 3, ("\tOID: 0x%08x : 0x%02x : 0x%04x : 0x%08x",
			 oid.ipaddress, oid.port,
			 oid.epoch, oid.Seq));
	if (isnew) UpdateOIDTables(oid, o);
      } else {
	TRACE(index, 3, ("\tNo OID"));
      }

      ReadObjectDescriptor(o, theStream);
      objectSize -= filesizeofObjectDescriptor;
      SETRESDNT(o->flags);
      IIScInsert(notHostedMap, (int)o, 1);

      if (objectSize) {
	ReadStreamToBuffer(theStream, objectSize, (StreamByte *)o->d);
      }

      TRACE(index, 3, ("\tLEN : %d o: %#x", objectSize, o)); 

      if (isNoOID(oid) && HASOID(o->flags)) {
	TRACE(index, 0, ("Having to clear the hasoid bit for %#x", o));
	CLEARHASOID(o->flags);
      }

      TRACE(trans, 4, ("\t\t{broken=%d,hasOID=%d,codePtr = %#x}",
		       BROKEN(o->flags), HASOID(o->flags)?1:0,
		       (int) CODEPTR(o->flags)));

      if (isBuiltinOID(oid)) {
	if (isBuiltinIT(oid.Seq)) {
	  BuiltinGA(oid.Seq & 0xff, B_IT) = o;
	} else if (isBuiltinITSAT(oid.Seq)) {
	  BuiltinGA(oid.Seq & 0xff, B_ITSAT) = o;
	} else if (isBuiltinITSCT(oid.Seq)) {
	  BuiltinGA(oid.Seq & 0xff, B_ITSCT) = o;
	} else if (isBuiltinINSTAT(oid.Seq)) {
	  BuiltinGA(oid.Seq & 0xff, B_INSTAT) = o;
	} else if (isBuiltinINSTCT(oid.Seq)) {
	  BuiltinGA(oid.Seq & 0xff, B_INSTCT) = o;
	  if ((oid.Seq & 0xff) == CONCRETETYPEI) {
	    ctct = (ConcreteType)o;
	  } else if ((oid.Seq & 0xff) == INTEGERI) {
	    intct = (ConcreteType)o;
	  }
	}
      }
      break;

    case Extern:
      /*
       * -OB- --> read a single OID external reference
       */
      ReadOID(&oid, theStream);
      TRACE(index, 3, ("\tOID: 0x%08x : 0x%02x : 0x%04x : 0x%08x",
		       oid.ipaddress, oid.port,
		       oid.epoch, oid.Seq));
      IOScInsert(theContents->Externs, idx, oid);
   
      break;

    case AbConObj:
    case MakeObject:
      /*
       * +AC+ or *OB* read in a pair of OID's
       */
      oidp = (OID *)vmMalloc(2 * sizeof(OID));
      ReadOID(oidp, theStream);
      ReadOID(oidp + 1, theStream);
      TRACE(index, 4, ("\t%s: 0x%08x : 0x%02x : 0x%04x : 0x%08x",
		       ((theSignature == AbConObj) ? "A" : "CT"), 
		       oidp[0].ipaddress, oidp[0].port, 
		       oidp[0].epoch, oidp[0].Seq));
      TRACE(index, 4, ("\t%s: 0x%08x : 0x%02x : 0x%04x : 0x%08x",
		       ((theSignature == AbConObj) ? "C" : "ME"), 
		       oidp[1].ipaddress, oidp[1].port, 
		       oidp[1].epoch, oidp[1].Seq));

      if (theSignature == AbConObj)
	arrayAppend(theContents->AbCons, (int)oidp);
      else
	arrayAppend(theContents->MakeObjects, (int)oidp);

      break;

    case SigError:
      TRACE(trans, 0, ("Unrecognized signature"));
      exit(1);
    }
    
    arrayAppend(theContents->Objects, (int)o);
    idx++;
  }

  assert(idx == (u32)ARRAYSIZE(theContents->Objects));
  TRACE(index, 1, ("objects: %d, externs: %d, abcons: %d, makeobs: %d\n",
		   idx - IOScSize(theContents->Externs) - 
		   ARRAYSIZE(theContents->AbCons) - 
		   ARRAYSIZE(theContents->MakeObjects),
		   IOScSize(theContents->Externs), 
		   ARRAYSIZE(theContents->AbCons),
		   ARRAYSIZE(theContents->MakeObjects)));

  return;
}

static void ProcessCheckpointStream(CheckpointData *theContents,
				    Stream theStream)
{
  ReadTheCheckpointStream(theContents, theStream);
  
  /*
   * Now, we translate all the indices, converting them into pointers.
   * Methodology: not really a depth-first-search, using an external set of
   * marks for visited nodes.
   */

  if (doCompression)
    foldObjects(theContents);

  translateTheCheckpointArray(theContents);
  TRACE(passes, 1, ("Doing MKOBs..."));
  doMakeObjects(theContents);
  doDistGCObjects(theContents);

  if (TRACING(ctinfo, 1) || TRACING(trans, 1)) {
    TRACE(passes, 1, ("Looking at Em..."));
    doLookAtEm(theContents);
  }
}

Object DoCheckpoint( Stream theFile, char *cpfile )
{
  CheckpointData theContents;

  ProcessCheckpointStream(&theContents, theFile);
  if (0 && beVerbose) {
    extern void displayCTs(void);
    displayCTs();
  }
  if (cpfile) DestroyStream(theFile);

  if( writeCP && cpfile ) {
    char       *newname = (char *)vmMalloc(strlen(cpfile) + 6);
    char       *bakname = (char *)vmMalloc(strlen(cpfile) + 6);

    strcpy(bakname, cpfile);
    strcat(bakname, ".bak");
    strcpy(newname, cpfile);
    strcat(newname, ".new");

    theFile = OpenCheckpointFile(newname);
    WriteTheCheckpointStream(theFile, &theContents);
    DestroyStream(theFile);
    rename(cpfile, bakname);
    rename(newname, cpfile);
    vmFree(newname);
    vmFree(bakname);
  }

  /*
   * another pass: for each object, determine from its concrete type whether
   * it has a recovery section, and if so, enter it into the "got's ta be
   * recovered" set.  Also, create objects from MKOB directives, and if they
   * have an initially section, enter it into initiallySet.
   */
  TRACE(passes, 1, ("Looking for recovery sections..."));
  findRecoveries(&theContents);
  TRACE(passes, 1, ("Looking for initially sections..."));
  findInitiallies(&theContents);

  arrayDestroy(theContents.Objects);
  arrayDestroy(theContents.MakeObjects); 
  arrayDestroy(theContents.AbCons);
  IOScDestroy(theContents.Externs);
  TRACE(passes, 1, ("Recovery passes completed..."));
  return (Object)JNIL;
}

Object ExtractObjects(Stream theFile, Node srv)
{
#if DISTRIBUTED
  Object o;
  CheckpointData theContents;
  OID ctoid;
  while (memcmp("CTID", PeekStream(theFile, 4), 4) == 0) {
    (void)ReadStream(theFile, 4);
    ReadOID(&ctoid, theFile);
    doObjectRequest(srv, &ctoid, ctct);
  }
  ProcessCheckpointStream(&theContents, theFile);

  o = (Object)ASUB(theContents.Objects, ARRAYSIZE(theContents.Objects) - 1);
  if (!wasGCMalloced(o)) {
    /* It must be the squeue, take the previous one */
    o = (Object)ASUB(theContents.Objects, ARRAYSIZE(theContents.Objects) - 2);
    assert(wasGCMalloced(o));
  }
  assert(ARRAYSIZE(theContents.MakeObjects) == 0);
  arrayDestroy(theContents.Objects);
  arrayDestroy(theContents.MakeObjects); 
  arrayDestroy(theContents.AbCons);
  IOScDestroy(theContents.Externs);
  return o;
#else
  assert(0);
  return (Object)JNIL;
#endif
}

void DoCheckpointFromFile(char *cpfile)
{
  Stream theFile;
  char buffer[1024];

  /*
   * begin by reading in the checkpoint file.
   */
  if (!cpfile) {
    char *root;

    root = getenv("EMERALDROOT");
    if (root == NULL)
      root = EMERALDROOT;
    sprintf(buffer, "%s%s", root, CPFILE);
    cpfile = buffer;
  }
  theFile = CreateStream(ReadFileStream, cpfile);
  if( theFile == NULL ) {
    TRACE(passes, 0, ("unable to read from '%s'", cpfile ));
    return;
  }

  TRACE(passes, 1, ("Reading checkpoint file \"%s\"...", cpfile));
  (void)DoCheckpoint( theFile, cpfile );
}
