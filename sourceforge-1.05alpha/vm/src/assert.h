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
#ifndef _EMERALD_ASSERT_H
#define _EMERALD_ASSERT_H

#ifdef linux
extern void myabort(void);
#define abort() myabort()
#endif

extern void FatalError(char *ErrorMessage);

# ifdef lint
#  define assert(ex) {int assert__x_; assert__x_ = (ex); assert__x_ = assert__x_;}
#  define _assert(ex) {int assert__x_; assert__x_ = (ex); assert__x_ = assert__x_;}
# else
#  ifndef NDEBUG
#   define assertMessage "Assertion failed: file %s, line %d"
#   define _assert(ex) {if (!(ex)){printf(assertMessage, __FILE__, __LINE__); abort();}}
#   define assert(ex) {if (!(ex)){printf(assertMessage, __FILE__, __LINE__);abort();}}
#  else
#   define _assert(ex) ;
#   define assert(ex) ;
#  endif
# endif
#endif
