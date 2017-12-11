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
 * @(#)trace.h	1.1  3/11/91
 */
#ifndef trace_h
#define trace_h

extern int 
		traceinit,
		traceparse,
		tracehelp;

extern void trace(int, char *, ...);

#ifdef lint
#   define IFTRACE(t, level) \
	if (level)
#   define TRACE0(t, level, format) \
	if (level) trace(level, format)
#   define TRACE1(t, level, format, arg1) \
	if (level) trace(level, format, arg1)
#   define TRACE2(t, level, format, arg1, arg2) \
	if (level) trace(level, format, arg1, arg2)
#   define TRACE3(t, level, format, arg1, arg2, arg3) \
	if (level) trace(level, format, arg1, arg2, arg3)
#   define TRACE4(t, level, format, arg1, arg2, arg3, arg4) \
	if (level) trace(level, format, arg1, arg2, arg3, arg4)
#   define TRACE5(t, level, format, arg1, arg2, arg3, arg4, arg5) \
	if (level) trace(level, format, arg1, arg2, arg3, arg4, arg5)
#else
#if defined(__ANSI__) || defined(__GNUC__) \
	|| defined(__STDC__) || defined(__EXTENSIONS__)
#   define IFTRACE(t, level) \
	if (trace##t >= level)
#   define TRACE0(t, level, format) \
	if (trace##t >= level) trace(level, format)
#   define TRACE1(t, level, format, arg1) \
	if (trace##t >= level) trace(level, format, arg1)
#   define TRACE2(t, level, format, arg1, arg2) \
	if (trace##t >= level) trace(level, format, arg1, arg2)
#   define TRACE3(t, level, format, arg1, arg2, arg3) \
	if (trace##t >= level) trace(level, format, arg1, arg2, arg3)
#   define TRACE4(t, level, format, arg1, arg2, arg3, arg4) \
	if (trace##t >= level) trace(level, format, arg1, arg2, arg3, arg4)
#   define TRACE5(t, level, format, arg1, arg2, arg3, arg4, arg5) \
	if (trace##t >= level) trace(level, format, arg1, arg2, arg3, arg4, arg5)
#else
#   define IFTRACE(t, level) \
	if (trace/**/t >= level)
#   define TRACE0(t, level, format) \
	if (trace/**/t >= level) trace(level, format)
#   define TRACE1(t, level, format, arg1) \
	if (trace/**/t >= level) trace(level, format, arg1)
#   define TRACE2(t, level, format, arg1, arg2) \
	if (trace/**/t >= level) trace(level, format, arg1, arg2)
#   define TRACE3(t, level, format, arg1, arg2, arg3) \
	if (trace/**/t >= level) trace(level, format, arg1, arg2, arg3)
#   define TRACE4(t, level, format, arg1, arg2, arg3, arg4) \
	if (trace/**/t >= level) trace(level, format, arg1, arg2, arg3, arg4)
#   define TRACE5(t, level, format, arg1, arg2, arg3, arg4, arg5) \
	if (trace/**/t >= level) trace(level, format, arg1, arg2, arg3, arg4, arg5)
#endif
#endif
#endif
