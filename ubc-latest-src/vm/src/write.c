#define E_NEEDS_STRING
#define E_NEEDS_NTOH
#include "system.h"

#include "types.h"
#include "array.h"
#include "builtins.h"
#include "filestr.h"
#include "globals.h"
#include "iisc.h"
#include "oidtoobj.h"
#include "read.h"
#include "streams.h"
#include "trace.h"
#include "write.h"
#include "insert.h"
#include "assert.h"
#include "vm_exp.h"
#include "gc.h"

#define EMXNAME "emx"

int checkpointBuiltins = 0;
void (*checkpointCallback)(Object);
void (*checkpointCTCallback)(Object);
void (*checkpointCTIntermediateCallback)(int (*)(IISc, Object), IISc);

static void traverse(Object o, array todo, IISc map);
static int  figureHisLength(Object o, ConcreteType ct);
static void WriteSignature(Signature theSignature, Stream theStream);
static int writeone(Object o, Stream theStream, IISc map, int maxI);
static void writeem(Stream theStream, array todo, IISc map);
static int doEmAll = 0, writingToFile = 0;
static int startedWithACT = 0;

#define abs(x) ((x) < 0 ? -(x) : (x))
static inline int getindex(Object o, IISc map, int maxI)
{
  int index = IIScLookup(map, (int)o);
  index = abs(index);
  return maxI - index;
}

static void foundone(char *what, Object o, array todo, IISc map, 
			    int attached)
{
  int traverseThisOne = 0;
  ConcreteType ct;
  if (ISNIL(o)) return;
  if (!IIScIsNIL(IIScLookup(map, (int)o))) return;
  /*
   * We traverse this one when we get to it if:
   *	1.  We are doing everything, or
   *	2.  It is attached, or
   *	3.  It is not a concrete type and is immutable
   */
  ct = CODEPTR(o->flags);

  if (checkpointCTCallback) checkpointCTCallback((Object)ct);

  traverseThisOne = doEmAll || 
    attached ||
    (ct != ctct && ISIMUT(ct->d.instanceFlags)) ||
    (startedWithACT && ct == ctct && !isABuiltin(o));

  TRACE(checkpoint, 5, ("%3d: Found a %s %s %#x", ARRAYSIZE(todo),
			traverseThisOne ? "attached " : "", what, o));
  IIScInsert(map, (int)o, traverseThisOne ? ARRAYSIZE(todo): -ARRAYSIZE(todo));
  arrayAppend(todo, (int)o);
}

static void foundsqueue(SQueue q, array todo, IISc map)
{
  IIScInsert(map, (int)q, -ARRAYSIZE(todo));
  arrayAppend(todo, (int)q);
  TRACE(checkpoint, 5, ("Found an squeue with %d processes", SQueueSize(q)));
}

int isABuiltin(Object o)
{
  OID oid = OIDOf(o);
  return  isBuiltinOID(oid);
}

static int misdigit(int c)
{
  return ('0' <= c && c <= '9');
}

static void traverse(Object oxx, array todo, IISc map)
{
  char *t;
  Object o = oxx;
  ConcreteType ct;

  ct = CODEPTR(o->flags);
  TRACE(checkpoint, 3, ("Traversing %#x a %.*s", o,
			ct->d.name->d.items, ct->d.name->d.data));
  if (isABuiltin(o) && !checkpointBuiltins) {
    TRACE(checkpoint, 4, ("It is a builtin."));
    return;
  }

  foundone("concrete type", (Object)ct, todo, map, 0);

  t = findHisTemplate(ct);
  if (!RESDNT(o->flags)) {
    TRACE(checkpoint, 4, ("It is not resident"));
    return;
  }
  if (t) {
    Bits32 *p;
    int count, rounded, isAnArray;
    char c;

    TRACE(checkpoint, 4, ("His template is \"%s\"", t));

    p = (Bits32 *) o->d;
    while(1) {
      switch (c = *t++) {
      case '%':
	count = isAnArray = 0;
	while (misdigit(c = *t++)) {
	  count = count * 10 + c-'0';
	}
	if (!count) count = 1;
	if (c == '*') {
	  assert(count == 1);
	  isAnArray = 1;
	  c = *t++;
	  count = *p++;
	}
	switch (c) {
	case 'l':
	case 'L':
	  assert(isAnArray);
	  p += count;
	  break;
	case 'x':
	case 'X':
	  while (count--) {
	    foundone("reference", (Object)*p, todo, map, c == 'X');
	    p++;
	  }
	  break;
	case 'v':
	case 'V':
	  while (count--) {
	    ConcreteType ct = (ConcreteType)p[1];
	    foundone("variable ct", (Object)ct, todo, map, 0);
	    if (!ISNIL(ct) && HASODP(ct->d.instanceFlags)) {
	      if (ISNIL((Object)p[0])) {
		p[1] = JNIL;
	      } else {
		foundone("variable data", (Object)p[0], todo, map, c == 'V');
	      }
	    }
	    p += 2;
	  }
	  break;
	case 'f':
	case 'F':
	case 'd':
	case 'D':
	  p += count;
	  break;
	case 'c':
	case 'C':
	case 'b':
	case 'B':
	  if (isAnArray) {
	    rounded = ROUNDUP(count);
	    p = (Bits32 *) ((int) p + rounded);
	  } else {
	    p += count;
	  }
	  break;
	case 'm':
	  if (doEmAll) {
	    /* Just skip the monitor information.  It will be initialized on
	     * recovery. */
	  } else if (SQueueSize(((monitor *)p)->waiting) == 0) {
	    /* no waiters, no problem */
	  } else {
	    SQueue q = ((monitor *)p)->waiting;
	    foundsqueue(q, todo, map);
	  }
	  p += 2;
	  break;
	case 'q':
	  assert(count == 1);
	  if (doEmAll) {
	    /* Just skip the queue.  It will be initialized on recovery. */
	  } else if (SQueueSize((SQueue)*p) == 0) {
	    /* no waiters, no problem */
	  } else {
	    foundsqueue((SQueue)*p, todo, map);
	  }
	  p++;
	  break;
	default:
	  printf("Invalid template character '%c'\n", c);
	  assert(0);
	  break;
	}
	break;
      case '\0':
	return;
      default:
	break;
      }
    }
  }
}

/*
 * Figures the size of an object, with the following definition of size:
 * 
 * The size of an object is the sum of :
 *   the size of the Flags field in the object descriptor
 *   the size of the object representation
 *       (Note that for vectors the 4 dummy bytes in the Data field are not
 *         counted twice)
 */
static int figureHisLength(Object o, ConcreteType ct)
{
  assert(ct);

  if ((unsigned int) ct < NUMBUILTINS) {
    assert(0);
    return sizeofObject;
  } else if (ct->d.instanceSize >= 0) {
    return ct->d.instanceSize + sizeofObject;
  } else {
    if (RESDNT(o->flags)) {
      int count = ((Vector)o)->d.items;
      count *= -ct->d.instanceSize;
      return ROUNDUP(count) + sizeofVector;
    } else {
      return getVectorSize(o) * sizeof(u32);
    }
  }
}

/*
 * Write an OID to a stream
 */

void WriteOID(OID *oid, Stream theStream)
{
  Bits8 *theBuffer;
  
  theBuffer = WriteStream(theStream, filesizeofOID);
  InsertOID(oid, theBuffer);
}

/*
 * Write a signature to a stream
 */

static void WriteSignature(Signature theSignature, Stream theStream)
{
  WriteStreamFromBuffer(theStream, filesizeofSignature, (StreamByte*)signatures[theSignature]);
}

static int writeone(Object o, Stream theStream, IISc map, int maxI)
{
  ConcreteType ct = CODEPTR(o->flags);
  unsigned int length, lengthWritten = 0, id;
  int count, isAnArray, rounded, index, writeOIDOnly, writeStub;
  char *t, c;
  Bits32 *p, Flags, busy, ctindex;
  OID oid;
  Bits8 *theBuffer;

  oid = OIDOf(o);
  id = oid.Seq;

  writeOIDOnly = isBuiltinOID(oid) && !checkpointBuiltins;
  writeStub = !RESDNT(o->flags) || IIScLookup(map, (int)o) < 0;

  TRACE(checkpoint, 5, ("Writing %s %#x, a %.*s", 
			writeOIDOnly ? "no-ob" : writeStub ? "stub" : "object",
			o, ct->d.name->d.items, 
			ct->d.name->d.data));

  if ((writeOIDOnly || writeStub || ISIMUT(ct->d.instanceFlags)) && !writingToFile) {
    /* Since we are writing an external reference, we need to assign an OID */
    /* if the object doesn't already have one */
    if (isNoOID(oid)) {
      NewOID( &oid ); 
      OIDInsert( oid, (Object) o );
      TRACE(checkpoint, 5, ("Assigning id %s to a %.*s", OIDString(oid), ct->d.name->d.items, ct->d.name->d.data));
    }
  }
  if (writeOIDOnly) {
    WriteSignature(Extern, theStream);
    WriteOID(&oid, theStream);
    return 0;
  }
  length = figureHisLength(o, ct);
  if (writeStub) {
    Node srv = getLocFromObj(o);
    WriteSignature(ct->d.instanceSize < 0 ?  VectorStub : Stub, theStream);
    WriteOID(&oid, theStream);      
    InsertBits32(&length, WriteStream(theStream, sizeof(Bits32)));
    TRACE(checkpoint, 11, ("Wrote length %d", length));
    Flags = getindex((Object)ct, map, maxI) | distGCBitToSend(o);;
    TRACE(checkpoint, 10, ("Writing flags %x for stub %s", Flags, OIDString(oid)));
    InsertBits32(&Flags, WriteStream(theStream, sizeof(Bits32)));
    WriteNode(&srv, theStream);
    return 0;
  } else {
    if (isNoOID(oid)) {
      WriteSignature(ObjectWithoutID, theStream);
      InsertBits32(&length, WriteStream(theStream, sizeof(Bits32)));
    } else {
      WriteSignature(ObjectWithID, theStream);
      length += filesizeofOID;
      InsertBits32(&length, WriteStream(theStream, sizeof(Bits32)));
      WriteOID(&oid, theStream);
      lengthWritten += filesizeofOID;
    }

    TRACE(checkpoint, 11, ("Wrote length %d", length));
    ctindex = getindex((Object)ct, map, maxI);
    Flags = (HASOID(o->flags)) | distGCBitToSend(o) | ctindex;

    TRACE(checkpoint, 10, ("Writing flags %x for stub %s", Flags, OIDString(oid)));

    theBuffer = WriteStream(theStream, sizeof(Bits32));
    InsertBits32(&Flags, theBuffer);
    lengthWritten += sizeof(Bits32);

    t = findHisTemplate(ct);

    if (!t) return 1;
    p = (Bits32 *) o->d;
    while(*t) {
      switch (*t++) {
      case '%':
	count = isAnArray = 0;
	while (misdigit(c = *t++)) {
	  count = count * 10 + c-'0';
	}
	if (!count) count = 1;
	if (c == '*') {
	  assert(count == 1);
	  isAnArray = 1;
	  c = *t++;
	  count = *p++;
	  theBuffer = WriteStream(theStream, sizeof(Bits32));
	  InsertBits32((Bits32 *)&count, theBuffer);
	  lengthWritten += sizeof(Bits32);
	}	
	switch (c) {
	case 'b':
	case 'B':
	case 'c':
	case 'C':
	  if (isAnArray) {
	    rounded = ROUNDUP(count);
	    WriteStreamFromBuffer(theStream, rounded, (StreamByte *)p); 
	    lengthWritten += rounded;
	    p += (rounded / 4);
	    break;
	  } else {
	    /* fall through */
	  }
	case 'f':
	case 'F':
	  while (count--) {
	    theBuffer = WriteStream(theStream, sizeof(Bits32));
	    *(int *)theBuffer = htonl(*(int *)p);
	    lengthWritten += sizeof(Bits32);
	    p++;
	  }
	  break;

	case 'd':
	case 'D':
	  while (count--) {
	    theBuffer = WriteStream(theStream, sizeof(Bits32));
	    InsertBits32(p, theBuffer);
	    lengthWritten += sizeof(Bits32);
	    p++;
	  }
	  break;
	case 'l':
	case 'L':
	  while (count--) {
	    theBuffer = WriteStream(theStream, sizeof(Bits32));
	    InsertBits32(p, theBuffer);
	    lengthWritten += sizeof(Bits32);
	    p++;
	  }
	  break;
	case 'x':
	case 'X':
	  while (count--) {
	    if (ISNIL(*p)) {
	      theBuffer = WriteStream(theStream, sizeof(Bits32));
	      InsertBits32(p, theBuffer);
	      lengthWritten += sizeof(Bits32);
	    } 
	    else {
	      index = getindex((Object)*p, map, maxI);
	      assert(index >= 0);
	      theBuffer = WriteStream(theStream, sizeof(Bits32));
	      InsertBits32((Bits32 *)&index, theBuffer);
	      lengthWritten += sizeof(Bits32);
	    }
	    p++;
	  }
	  break;
	case 'v':
	case 'V':
	  while (count--) {
	    if (ISNIL(p[1]) && !ISNIL(p[0])) {
	      p[1] = (Bits32)CODEPTR(((Object)p[0])->flags);
	    }
	    if (ISNIL(p[1])) {
	      assert(ISNIL(p[0]));
	      theBuffer = WriteStream(theStream, sizeof(Bits32));
	      InsertBits32(p, theBuffer);
	      theBuffer = WriteStream(theStream, sizeof(Bits32));
	      InsertBits32(p, theBuffer);
	    } else {
	      if (HASODP(((ConcreteType)p[1])->d.instanceFlags)) {
		index = getindex((Object)*p, map, maxI);
		assert(index >= 0);
		theBuffer = WriteStream(theStream, sizeof(Bits32));
		InsertBits32((Bits32 *)&index, theBuffer);
	      } else {
		theBuffer = WriteStream(theStream, sizeof(Bits32));
		InsertBits32(p, theBuffer);
	      }
	      index = getindex((Object)p[1], map, maxI);
	      assert(index >= 0);
	      theBuffer = WriteStream(theStream, sizeof(Bits32));
	      InsertBits32((Bits32 *)&index, theBuffer);
	    }
	    p += 2;
	    lengthWritten += 2 * sizeof(Bits32);
	  }
	  break;
	case 'm':
	  assert(count == 1);
	  busy = doEmAll ? 0 : ((monitor *)p)->busy;
	  theBuffer = WriteStream(theStream, sizeof(Bits32));
	  InsertBits32((Bits32 *)&busy, theBuffer);
	  if (doEmAll || SQueueSize(((monitor *)p)->waiting) == 0) {
	    int zero = JNIL;
	    theBuffer = WriteStream(theStream, sizeof(Bits32));
	    InsertBits32((Bits32 *)&zero, theBuffer); 
	  } else {
	    SQueue sq = ((monitor *)p)->waiting;
	    index = getindex((Object)sq, map, maxI);
	    WriteInt(index, theStream);
	  }
	  lengthWritten += 2 * sizeof(Bits32);
	  p += 2;
	  break;
	case 'q':
	  assert(count == 1);
	  if (doEmAll || SQueueSize((SQueue)(*p)) == 0) {
	    int zero = JNIL;
	    theBuffer = WriteStream(theStream, sizeof(Bits32));
	    InsertBits32((Bits32 *)&zero, theBuffer);
	  } else {
	    SQueue sq = (SQueue)(*p);
	    index = getindex((Object)sq, map, maxI);
	    WriteInt(index, theStream);
	  }
	  p++;
	  lengthWritten += sizeof(Bits32);
	  break;
	default:
	  assert(0);
	  break;
	}
	break;
      default:
	break;
      }
    }
    assert(length == lengthWritten);
  }
  return 1;
}

static void writeem(Stream theStream, array todo, IISc map)
{
  int i, obs = 0, noobs = 0, maxI = ARRAYSIZE(todo) - 1;
  Object o;
  for (i = maxI; i >= 0; i--) {
    o = (Object)ASUB(todo, i);
    if (!wasGCMalloced(o)) {
      /* Write an squeue */
      SQueue sq = (SQueue) o;
      State *state;
      OID oid;  Node loc;

      /* We need to write the squeue, too */
      WriteSignature(SQ, theStream);
      assert(SQueueSize(sq) != 0);
      WriteInt(SQueueSize(sq), theStream);
      SQueueForEach(sq, state) {
	oid = OIDOf(state);
	loc = getLocFromObj((Object)state);
	WriteOID(&oid, theStream);
	WriteNode(&loc, theStream);
      } SQueueNext();
    } else if (writeone(o, theStream, map, maxI)) {
      obs++;
      if (i != 0 && checkpointCallback && !ISIMUT(CODEPTR(o->flags)->d.instanceFlags)) {
	checkpointCallback(o);
      }
    } else {
      noobs++;
    }
  }
  TRACE(checkpoint, 1, ("Wrote %d objects, %d references", obs, noobs));
}

void doCTLiterals(ConcreteType ct, array todo, IISc map)
{
  int i, n;
  OID oid;
  struct LFERep *lfe = &ct->d.literals->d.data[0];

  n = ct->d.literals->d.items / (sizeof(struct LFERep) / sizeof(int));
  for (i = 0; i < n; i++) {
    if (isBuiltinOID(lfe->oid)) {
      /* ignore it */
    } else if (lfe->ptr && !ISNIL(lfe->ptr)) {
      foundone("literal element", lfe->ptr, todo, map, 1);
      oid = OIDOf(lfe->ptr);

      if (oid.Seq != lfe->oid.Seq) {
	TRACE(checkpoint, 0, ("Expected %#08x (-> %#x) found %#x id %#08x",
			      lfe->oid.Seq,
			      OIDFetch(lfe->oid),
			      lfe->ptr, oid.Seq));
	/* This results in the object not being written with its OID in the */
	/* checkpoint file, so it will never be found later.  This error */
	/* should be fatal somehow. */
	  
      }
    } else {
      TRACE(checkpoint, 2, ("Can't find literal element %#08x",
			    lfe->oid.Seq));
    }
    lfe++;
  }
}    

int isscheduled(IISc map, Object o)
{
  return (IIScLookup(map, (int)o) > 0);
}

void Checkpoint(Object o, ConcreteType ct, Stream theFile)
{
  array todo;
  IISc map;

  if (HASODP(ct->d.instanceFlags)) {
    int i;
    todo = arrayCreate(100);
    map = IIScCreateN(100);
    foundone("The original", o, todo, map, 1);
    startedWithACT = ct == ctct;
    for (i = 0; i < ARRAYSIZE(todo); i++) {
      Object x = (Object) ASUB(todo, i);
      if (!wasGCMalloced(x)) {
	/* It is an squeue, no traversal needed */
      } else if (IIScLookup(map, (int)x) >= 0) {
	if (CODEPTR(x->flags) == ctct) {
	  doCTLiterals((ConcreteType)x, todo, map);
	}
	traverse(x, todo, map);
      } else if (!isABuiltin(x)) {
	foundone("concrete type", (Object)CODEPTR(x->flags), todo, map, 0);
      }
    }
    TRACE(checkpoint, 1, ("Checkpoint found %d objects", ARRAYSIZE(todo)));
    if (checkpointCTIntermediateCallback) checkpointCTIntermediateCallback(isscheduled, map);
    resetBreakpoints();
    writeem(theFile, todo, map);
    setBreakpoints();
    startedWithACT = 0;
    IIScDestroy(map);
    arrayDestroy(todo);
  }
}

void CheckpointToFile(Object o, ConcreteType ct, String file)
{
  Stream theFile;
  char *filename;

  TRACE( checkpoint, 1,
	( "Checkpoint of a %.*s %#x to file \"%.*s\"", 
	 ct->d.name->d.items, ct->d.name->d.data, o,
	 file->d.items, file->d.data ) );
  filename = (char*) vmMalloc(file->d.items + 1);
  memmove(filename, file->d.data, file->d.items);
  filename[file->d.items] = '\0';
  theFile = OpenCheckpointFile(filename);
  doEmAll = 1;
  writingToFile = 1;
  Checkpoint( o, ct, theFile );
  doEmAll = 0;
  writingToFile = 0;
  vmFree(filename); DestroyStream(theFile);
}

Stream OpenCheckpointFile(char *cpfile)
{
  int         len;
  Stream      theFile;
  Bits8      *theBuffer;

  theFile = CreateStream(WriteFileStream, cpfile);

  len = 4 + strlen(EMXNAME);
  theBuffer = WriteStream(theFile, ROUNDUP(len + 1));
  sprintf((char *)theBuffer, "#!  %s", EMXNAME);
  while (len % 4 != 3) {
    theBuffer[len] = ' ';
    len++;
  }
  theBuffer[len] = '\n';

  return theFile;
}

/*
 * Write all the objects in the object array back to f.  This is used only
 * by the code that compresses a checkpoint file, and not by the regular
 * uses of checkpointing.
 *	1.  Build a new array of entries that must be written to the
 *	    checkpoint file.  The roots for this array are those entries in
 *	    the object array which have OIDs that have not been
 *	    redefined by later objects.  All objects reachable from here
 *	    must also be written out.  We create a separate array of externs.
 *	2.  While building this array, also construct a map that maps each
 *	    object into an index (for faster search).
 */
void WriteTheCheckpointStream(Stream theStream, CheckpointData *theContents)
{
  array       todo;
  IISc        map;
  int         i, size;
  OID        *oid;
  Object      o;
  int         whereami = 0;

  doEmAll = 1;
  writingToFile = 1;
  size = ARRAYSIZE(theContents->Objects);

  todo = arrayCreate(size);
  map = IIScCreateN(100);

  for (i = 0; i < size; i++) {
    o = (Object) ASUB(theContents->Objects, i);

    if (ISNIL(o))
      continue;

    /* if it has an OID but doesn't appear in the object table, ignore it */
    /* I think this whole if clause can go as it simply confirms that 
       there is a one-to-one mapping between objects and OIDs */
    if (HASOID(o->flags)) {
      OID oid;
      Object othero;

      oid = OIDOf(o);
      assert(!isNoOID(oid));

      othero = OIDFetch(oid); 
      if (othero != o) continue;
    }

    foundone("An original", o, todo, map, 1);

    while (whereami < ARRAYSIZE(todo)) {
      Object x = (Object) ASUB(todo, whereami);
      traverse(x, todo, map);
      whereami++;
    }
  }

  TRACE(checkpoint, 1, ("Checkpoint found %d objects", ARRAYSIZE(todo)));
  writeem(theStream, todo, map);

  IIScDestroy(map);
  arrayDestroy(todo);

  size = ARRAYSIZE(theContents->MakeObjects);
  for (i = 0; i < size; i++) {
    oid = (OID *) ASUB(theContents->MakeObjects, i);
    WriteSignature(MakeObject, theStream);
    WriteOID(oid, theStream);
    WriteOID(oid + 1, theStream);
  }
  doEmAll = 0;
  writingToFile = 0;
}
