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

#ifndef _EMERALD_BUILTINS_H
#define _EMERALD_BUILTINS_H

#define NUMBUILTINS			43
#define BUILTINOBJECTBASE 		(0x01000)
#define ATOFBUILTINOBJECTBASE 		(0x01200)
#define CTOFBUILTINOBJECTBASE		(0x01400)
#define INSTATOFBUILTINOBJECTBASE 	(0x01600)
#define INSTCTOFBUILTINOBJECTBASE 	(0x01800)

#define FIRSTBUILTININDEX	0
#define ABSTRACTTYPEI		0
#define ANYI			1
#define ARRAYI			2
#define BOOLEANI		3
#define CHARACTERI		4
#define CONDITIONI		5
#define INTEGERI		6
#define NILI			7
#define NODEI			8
#define SIGNATUREI		9
#define REALI			0xa
#define STRINGI			0xb
#define VECTORI			0xc
#define TIMEI			0xd
#define NODELISTELEMENTI	0xe
#define NODELISTI		0xf
#define INSTREAMI		0x10
#define OUTSTREAMI		0x11
#define IMMUTABLEVECTORI	0x12
#define BITCHUNKI		0x13
#define RISCI			0x14
#define HANDLERI		0x15
#define VECTOROFCHARI		0x16
#define RDIRECTORYI		0x17
#define CONCRETETYPEI		0x18
#define COPVECTORI		0x19
#define COPVECTOREI		0x1a
#define AOPVECTORI		0x1b
#define AOPVECTOREI		0x1c
#define APARAMLISTI		0x1d
#define VECTOROFINTI		0x1e
#define INTERPRETERSTATEI	0x1f
#define DIRECTORYI		0x20
#define IVECTOROFANYI		0x21
#define RISAI			0x22
#define IVECTOROFINTI		0x23
#define SEQUENCEI               0x24
#define STUBI	                0x25
#define DIRECTORYGAGGLEI	0x26
#define LITERALLISTI		0x27
#define VECTOROFANYI		0x28
#define IVECTOROFSTRINGI	0x29
#define VECTOROFSTRINGI		0x2a

#define LASTBUILTININDEX	VECTOROFSTRINGI

typedef enum { B_IT, B_ITSAT, B_ITSCT, B_INSTAT, B_INSTCT } B_Tag;
#define OIDOfBuiltin(tag, i) \
	((unsigned) 0x1000 + ((unsigned) tag * 0x200) + (unsigned) i)

#define NUMTAGS 5

#define isBuiltin(x) ((unsigned)(x) < 0x8000 && ((x) & 0x7000))
#define isBuiltinIT(x) (((x) & 0xffff1f00) == BUILTINOBJECTBASE)
#define isBuiltinITSAT(x) (((x) & 0xffff1f00) == ATOFBUILTINOBJECTBASE)
#define isBuiltinITSCT(x) (((x) & 0xffff1f00) == CTOFBUILTINOBJECTBASE)
#define isBuiltinINSTAT(x) (((x) & 0xffff1f00) == INSTATOFBUILTINOBJECTBASE)
#define isBuiltinINSTCT(x) (((x) & 0xffff1f00) == INSTCTOFBUILTINOBJECTBASE)

extern struct ConcreteType *ctct, *intct;
#endif /* _EMERALD_BUILTINS_H */
