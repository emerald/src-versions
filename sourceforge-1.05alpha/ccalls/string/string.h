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
/* string.h - Norm Hutchinson <norm@cs.ubc.ca> 95Mar14 */
#include "types.h"

#ifndef CCALL
#define CCALL( func, subcode, argstring )
#endif /* CCALL */

int charIsAlpha( int ch );
CCALL( charIsAlpha, EMCH_ISALPHA, "bi" )

int charIsUpper( int ch );
CCALL( charIsUpper, EMCH_ISUPPER, "bi" )

int charIsLower( int ch );
CCALL( charIsLower, EMCH_ISLOWER, "bi" )

int charIsDigit( int ch );
CCALL( charIsDigit, EMCH_ISDIGIT, "bi" )

int charIsXdigit( int ch );
CCALL( charIsXdigit, EMCH_ISXDIGIT, "bi" )

int charIsAlnum( int ch );
CCALL( charIsAlnum, EMCH_ISALNUM, "bi" )

int charIsSpace( int ch );
CCALL( charIsSpace, EMCH_ISSPACE, "bi" )

int charIsPunct( int ch );
CCALL( charIsPunct, EMCH_ISPUNCT, "bi" )

int charIsPrint( int ch );
CCALL( charIsPrint, EMCH_ISPRINT, "bi" )

int charIsGraph( int ch );
CCALL( charIsGraph, EMCH_ISGRAPH, "bi" )

int charIsCntrl( int ch );
CCALL( charIsCntrl, EMCH_ISCNTRL, "bi" )

int charToUpper( int ch );
CCALL( charToUpper, EMCH_TOUPPER, "ii" )

int charToLower( int ch );
CCALL( charToLower, EMCH_TOLOWER, "ii" )

int stringIndex( String s, int ch );
CCALL(stringIndex, EMST_INDEX, "ipi")

int stringRIndex( String s, int ch );
CCALL(stringRIndex, EMST_RINDEX, "ipi")

int stringSpan( String s, String t);
CCALL(stringSpan, EMST_SPAN, "ipp")

int stringCSpan( String s, String t);
CCALL(stringCSpan, EMST_CSPAN, "ipp")

int stringStr(String s, String t);
CCALL(stringStr, EMST_STR, "ipp")
/* EOF */
