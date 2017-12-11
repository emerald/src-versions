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
 * Jekyll types and constants
 */

#ifndef _EMERALD_TYPES_H
#define _EMERALD_TYPES_H 1
#include "streams.h"

#ifndef EMERALDROOT
#define EMERALDROOT "/usr/local"
#endif

/*
 * Jekyll NIL is just EMNIL, rehashed
 */
#define JNIL 0x80000000
#define ISNIL(x) ((int)(x) == JNIL)
#define ISNOTNIL(x) (!(ISNIL(x)))
#define VLen(v) (ISNIL(v) ? 0 : (v)->d.items)

/* Machine dependent type definitions.  Redefine for different architectures.
   Make sure that :
   sizeof(Bits32) == 4
   sizeof(Bits16) == 2
   sizeof(Bits8)  == 1 */
typedef unsigned int   Bits32;
typedef unsigned short Bits16;
typedef unsigned char  Bits8;

/* Forward declarations */

typedef struct ConcreteType *ConcreteType;
typedef struct Forward      *Forward;
#define StringRep VectorRep
#define CodeRep VectorRep
#define BitchunkRep VectorRep
#define TemplateRep VectorRep

/*****************************************************************************
				Object
*****************************************************************************/

/* Bits in the flags of a FirstThing */
#define BROKENBIT 0x80000000
#define HASOIDBIT 0x40000000
#define RESDNTBIT 0x20000000
#define REMSETBIT 0x10000000
#define DISTGCBIT 0x08000000
#define VZEROLBIT 0x04000000

/* Bits in the instanceFlags of a CT */
#define HASODPBIT 0x20000000
#define ISIMUTBIT 0x40000000

#define ALLBITS (BROKENBIT | HASOIDBIT | RESDNTBIT | REMSETBIT | DISTGCBIT | VZEROLBIT)

#define BROKEN(f)         ((f) &  BROKENBIT)
#define SETBROKEN(f)      ((f) |= BROKENBIT)
#define CLEARBROKEN(f)    ((f) &= ~BROKENBIT)

#define HASOID(f)         ((f) &  HASOIDBIT)
#define SETHASOID(f)      ((f) |= HASOIDBIT)
#define CLEARHASOID(f)    ((f) &= ~HASOIDBIT)

#ifdef DISTRIBUTED
#define RESDNT(f)         ((f) &  RESDNTBIT)
#define SETRESDNT(f)      ((f) |= RESDNTBIT)
#define CLEARRESDNT(f)    ((f) &= ~RESDNTBIT)
#else
#define RESDNT(f)         1
#define SETRESDNT(f)      
#define CLEARRESDNT(f)    abort()
#endif

#define REMSET(f)         ((f) &  REMSETBIT)
#define SETREMSET(f)      ((f) |= REMSETBIT)
#define CLEARREMSET(f)    ((f) &= ~REMSETBIT)

#define DISTGC(f)         ((f) &  DISTGCBIT)
#define SETDISTGC(f)      ((f) |= DISTGCBIT)
#define CLEARDISTGC(f)    ((f) &= ~DISTGCBIT)

#define VZEROL(f)         ((f) &  VZEROLBIT)
#define SETVZEROL(f)      ((f) |= VZEROLBIT)
#define CLEARVZEROL(f)    ((f) &= ~VZEROLBIT)

#define setVectorSize(v, size) (((size) == 2 ? SETVZEROL(((Object)(v))->flags) : (CLEARVZEROL(((Object)(v))->flags), ((int *)(v))[2] = (size))))
#define getVectorSize(v) (VZEROL(((Object)(v))->flags) ? 2 : ((int *)(v))[2])

#define HASODP(f)         ((f) &  HASODPBIT)
#define SETHASODP(f)      ((f) |= HASODPBIT)
#define CLEARHASODP(f)    ((f) &= ~HASODPBIT)

#define ISIMUT(f)         ((f) &  ISIMUTBIT)
#define SETISIMUT(f)      ((f) |= ISIMUTBIT)
#define CLEARISIMUT(f)    ((f) &= ~ISIMUTBIT)

#define CODEPTREXTRA 0
#ifdef mips
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x10000000
#endif
#ifdef alpha
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x14000000
#endif
#ifdef hp700
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x40000000
#endif
#ifdef ibm
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x20000000
#endif
#if defined(i386) && defined(linux)
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x40000000
#endif
#if defined(i386) && (!defined(linux) && defined(__svr4__))
#undef CODEPTREXTRA
#define CODEPTREXTRA 0x08000000
#endif

#define CODEPTRBITS (0xffffffff & ~ALLBITS)
#define CODEPTR(f)       ((ConcreteType)((((unsigned int)f) & CODEPTRBITS) | CODEPTREXTRA))
#define CODEPTRINDEX(f)  ((unsigned int)f & CODEPTRBITS)
#define SETCODEPTR(f,cp)  \
  ((f) = ((((unsigned int)f) & ~CODEPTRBITS)) | ((unsigned int)cp & ~CODEPTREXTRA))
#define SETCODEPTRINDEX(f,cp)  \
  ((f) = (((unsigned int)f) & ~CODEPTRBITS) | (unsigned int)cp)

typedef Bits32 FirstThing;

#define HOSTED(f)         (IIScIsNIL(IIScLookup(notHostedMap, (int)(f))))
#define SETHOSTED(f)	(IIScDelete(notHostedMap, (int)(f)))
#define CLEARHOSTED(f)    (abort())

struct ObjectDescriptor {
  FirstThing       flags;
  Bits32	   d[1];
};

typedef struct ObjectDescriptor *Object;

/*
 Almost all objects (the exceptions are builtins like Integer and Boolean)
 have ObjectDescriptors.  

 The Flags field is used as follows :

              Set                       Clear 
              ---                       -----
 BROKENBIT    The Object is broken      The Object is unbroken

 HASOIDBIT    The Object has been       The Object has not been assigned
              assigned an OID.          an OID.

 RESDNTBIT    The Object is resident    The Object is not resident on this
              on this node.             node.

 REMSETBIT    (not during gc)		This object is not in the remembered
	      This object is in the	set.
	      remembered set since it
	      is in the old generation
	      and (may) hold a 
	      reference to an object
	      in the new generation.
	      
	      (during gc)
	      This object is marked.	This object is not marked.

 DISTGCBIT    (Only defined during a distributed gc)
	      This object is Black	This object is White
	      (In a message (object header) since we never send refs to white objects)
	      This object is Black	This object is Grey

 VZEROL	      (Defined only for vector stubs)
	      The vector has 0 elements The vector has > 0 elements,
					the number of words taken in stored in
					the third word of the structure.

 The ct of the object is stored in the same 32 bit FirstThing, to save a
 word in every object.  This really is a good idea, although it is somewhat
 messy.

 The data portion of the object follows immediately after the first thing.

 If the object is not resident, then the first word of the object data area
 is a pointer to a noderecord indicating the best information we have about
 where the object might be.
 */

/****************************************************************************
	       Non-Object Types Used By The Virtual Machine
****************************************************************************/

typedef int Socket;

typedef struct Node {
  Bits32 ipaddress;
  Bits16 port;
  Bits16 epoch;
} Node;

typedef struct OID {
  Bits32 ipaddress;
  Bits16 port;
  Bits16 epoch;
  Bits32 Seq;
} OID;

#define isNoOID(oid)  (((oid).ipaddress == 0) \
		       && ((oid).port == 0) \
		       && ((oid).epoch == 0) \
		       && ((oid).Seq == 0))

#define isNoNode(oid) (((oid).ipaddress == 0) \
		       && ((oid).port == 0) \
		       && ((oid).epoch == 0))

#define sameOID(a,b) ((a).ipaddress == (b).ipaddress && \
		      (a).port == (b).port && \
		      (a).epoch == (b).epoch && \
		      (a).Seq == (b).Seq)
		      
#define isBuiltinOID(a) ((isNoNode(a)) && isBuiltin((a).Seq))

/*****************************************************************************
			   Object Subtypes

The following types are subtypes of object:

AbCon
AbstractType
ATOpVector
ATOpVectorElement
ATTypeVector
Bitchunk
Code
ConcreteType
Decoder
InterpreterState
JTime
OpVector
OpVectorElement
String
Template
Vector

****************************************************************************/

/* Macro to automatically declare subtypes of ObjectDescriptor */

#define OBJECTSUBTYPE(theType) \
  typedef struct theType {     \
  FirstThing		flags;         \
  struct theType##Rep	d;  \
  } *theType 

/****************************************************************************
			Object Representations

Internal representations for the various builtin types.
****************************************************************************/

/* Many of the following object representations contain a final slot which
   is an array of one element.  In reality, that array may have more than
   one slot.  Extra space is sometimes allocated beyond the end of the slot,
   and a field in the representation determines how big the array actually is.
   In practice, then, the sizeof operator is not accurate -- it does not
   know about the extra slots. */

struct VectorRep {
  int	items;
  Bits8 data[4];
};
OBJECTSUBTYPE(Vector);

OBJECTSUBTYPE(String);

struct ATOpVectorElementRep {
  unsigned int id;
  int	       isFunction;
  String       name;
  struct ATTypeVector *arguments;
  struct ATTypeVector *results;
};
OBJECTSUBTYPE(ATOpVectorElement);

struct ATOpVectorRep {
  int		    items;
  ATOpVectorElement data[1];
};
OBJECTSUBTYPE(ATOpVector);

#define AT_ISTYPEVARIABLE 1
#define AT_ISIMMUTABLE 2
#define AT_ISVECTOR 4

struct AbstractTypeRep {
  int	       flags;
  ATOpVector   ops;
  String       name;
  String       filename;
};
OBJECTSUBTYPE(AbstractType);

struct ATTypeVectorRep {
  int	       items;
  AbstractType data[1];
};
OBJECTSUBTYPE(ATTypeVector);

OBJECTSUBTYPE(Bitchunk);
OBJECTSUBTYPE(Code);

OBJECTSUBTYPE(Template);

typedef struct State *InterpreterState;

struct JTimeRep {
  int secs;
  int usecs;
};
OBJECTSUBTYPE(JTime);

/* 
  The first three elements of the OpVectorRep are not actually invocable
  operations.  They correspond to the initially, process, and recovery
  sections, respectively.
 */

#define OVE_INITIALLY 0
#define OVE_PROCESS   1
#define OVE_RECOVERY  2
#define OVE_FIRSTOP   3

#define HASINITIALLY(ct) \
   (ISNOTNIL(((ConcreteType)ct)->d.opVector->d.data[OVE_INITIALLY]))

#define HASRECOVERY(ct) \
   (ISNOTNIL(((ConcreteType)ct)->d.opVector->d.data[OVE_RECOVERY]))

#define HASPROCESS(ct) \
   (ISNOTNIL(((ConcreteType)ct)->d.opVector->d.data[OVE_PROCESS]))

#define ISCOMPILATION(ct) \
   (!strncmp((char*)ct->d.name->d.data, "Compilation", ct->d.name->d.items))

struct OpVectorElementRep {
  unsigned int id;
  int	       nargs;
  int	       nress;
  String       name;
  Template     template;
  Code         code;
};
OBJECTSUBTYPE(OpVectorElement);

struct OpVectorRep {       
  int		  items;
  OpVectorElement data[1];
};
OBJECTSUBTYPE(OpVector);

/*
 * Here is what the literal frame entries (LFE's) generated by the
 * compiler at the end of a code section look like:
 */
struct LFERep {
  OID    oid;
  Object ptr;
};

struct LFEVectorRep {
  int items;
  struct LFERep data[1];
};
OBJECTSUBTYPE(LFEVector);

/* The instanceFlags field of the concrete type indicates properties that
 * are true of every instance, currently just HASODP and ISIMUT.  If HASODP
 * is set, it indicates that the object is represented with an object
 * descriptor in the usual way.  If not set, then the object is simply a
 * 32-bit chunk of data.  This allows implementation of some builtin objects
 * like Integer and Boolean.  
 */

struct ConcreteTypeRep {
  int	       instanceSize; /* The amount of space to allocate for
				instances */
  Bits32       instanceFlags;
  OpVector     opVector;
  String       name;
  String       filename;
  Template     template;  /* A table describing the data fields of instances
                             to allow host-network translation */
  AbstractType type;
  LFEVector    literals;
};

/*
 * In a sane world, this would be defined using OBJECTSUBTYPE, but since I
 * need the ConcreteType typedef early, and since OBJECTSUBTYPE would attempt
 * to redo the typedef, and since C can't handle that we have to do it by hand.
 */
struct ConcreteType {
  FirstThing		flags;
  struct ConcreteTypeRep	d;
};

struct AbConRep {
  OID 		  abOID;
  OID 		  conOID;
  AbstractType    ab;
  ConcreteType    con;
  int 		  nops;        /* Number of operations */
  OpVectorElement ops[1];
};
OBJECTSUBTYPE(AbCon);

/****************************************************************************
		     sizeof and filesizeof macros
****************************************************************************/

/* Some of the above object representations declare one-element arrays.  In
   reality these arrays are of variable length.  The sizeof macros provide
   a means for referring to just the part of the representation that does
   not include the array.  Because of existing code, these macros add in
   sizeofObject (the size of an ObjectDescriptor without the Link field). */

#define sizeofObject       (sizeof(struct ObjectDescriptor) - sizeof(Bits32))
#define sizeofOpVector     (sizeofObject + sizeof(struct OpVectorRep) -     \
			    sizeof(OpVectorElement))
#define sizeofVector       (sizeofObject + sizeof(struct VectorRep) -       \
			    4 * sizeof(Bits8))
#define sizeofATOpVector   (sizeofObject + sizeof(struct ATOpVectorRep) -   \
			    sizeof(ATOpVectorElement))
#define sizeofATTypeVector (sizeofObject + sizeof(struct ATTypeVectorRep) - \
			    sizeof(AbstractType))
#define sizeofCode          sizeofVector
#define sizeofString        sizeofVector
#define sizeofAbCon	   (sizeofObject + sizeof(struct AbConRep) -        \
			    sizeof(OpVectorElement))

/* The sizeof macros give the size of objects in memory.  The filesizeof
   macros give the size of objects on disk or on the wire. */

#define filesizeofBits32    4
#define filesizeofBits16    2
#define filesizeofBits8     1
#define filesizeofNode      (filesizeofBits32 + 2 * filesizeofBits16)
#define filesizeofOID       (filesizeofNode + filesizeofBits32)

/****************************************************************************
			 Byte-swapping macros
****************************************************************************/

#endif /* _EMERALD_TYPES_H */
#include "codeptrextra.h"
