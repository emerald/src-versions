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

#ifndef _EMERALD_SYSTEM_H
#define _EMERALD_SYSTEM_H

#if !defined(EMERALD_MYRINET)
#if defined(WIN32)
#pragma warning(disable: 4068)
#endif

#if defined(alpha)
#pragma pointer_size long
#endif

#include <stdio.h>

#if !defined(E_NEEDS_STDIO_ONLY)
#include <stdlib.h>
#endif

#if defined(E_NEEDS_FILE) || defined(E_NEEDS_STAT) || defined(E_NEEDS_NTOH) || defined(E_NEEDS_SOCKET) || defined(E_NEEDS_NETDB) || defined(E_NEEDS_SELECT)
#    include <sys/types.h>
#endif

#if defined(E_NEEDS_FILE) || defined(E_NEEDS_NETDB)
#  if !defined(WIN32)
#    include <unistd.h>
#  endif
#endif

#include <time.h>
#ifdef WIN32
#  include <sys/timeb.h>
#  define E_NEEDS_SOCKET
#else
#  include <sys/time.h>
#  include <sys/times.h>
#endif

#if defined(E_NEEDS_FILE)
#  include <fcntl.h>
#  ifdef WIN32
#    include <io.h>
#  else /* not WIN32 */
#    include <unistd.h>
#    include <sys/file.h>
#  endif /* not WIN32 */
#  ifdef __svr4__
#    include <sys/fcntl.h>
#  endif
#ifndef O_BINARY
#  define O_BINARY 0
#endif
#endif

#if defined(E_NEEDS_STAT)
#  include <sys/stat.h>
#endif

#if defined(E_NEEDS_STRING)
#  include <string.h>
#  if (defined(sun) && !defined(__svr4__))
     extern char *sys_errlist[];
#    define strerror(n) (sys_errlist[(n)])
#  endif
#endif

#if defined(E_NEEDS_ERRNO)
#  ifndef WIN32
#    include <sys/errno.h>
#  else
#    define EINTR 999
#    define ETIMEDOUT 999
#  endif
extern int errno;
#endif

#if defined(E_NEEDS_NTOH)
#  ifdef WIN32
#    define E_NEEDS_SOCKET
#  else
#    include <netinet/in.h>
#    ifdef sgi
#      include <sys/endian.h>
#    endif
#  endif
#endif

#if defined(E_NEEDS_SOCKET)
#  ifdef WIN32
#    ifdef MSVC40
#      include "winsock.h"
#    else
#      include "winsock2.h"
#    endif
#  else
#    include "sys/socket.h"
#  endif
#endif

#if defined(E_NEEDS_NETDB)
#  ifndef WIN32
#    include <netinet/in.h>
#    include <netdb.h>
#    include <arpa/inet.h>
#  endif
#endif

#if defined(E_NEEDS_VARARGS)
#  ifdef STDARG_WORKS
#    include <stdarg.h>
#  endif
#endif

#if defined(E_NEEDS_SIGNAL)
#  include <signal.h>
#endif

#ifdef E_NEEDS_IOV
#  if defined(WIN32)
     struct iovec {
       char *iov_base;
       int   iov_len;
     };
#  else
#    include <sys/uio.h>
#  endif
#endif

#if defined(E_NEEDS_CTYPE)
#  include <ctype.h>
#endif

#if defined(E_NEEDS_MATH)
#  include <math.h>
#endif

#if defined(E_NEEDS_TCP)
#  ifndef WIN32
#    include "netinet/tcp.h"
#  endif
#endif

#if defined(E_NEEDS_SELECT)
#  if defined(hp700) || defined(__NeXT__) || defined(WIN32) || (defined(sun) && !defined(__svr4__)) || defined(linux)
     /*
      * The select stuff is in unistd.h
      */
#  else
#    include <sys/select.h>
#  endif
#endif

#if defined(WIN32) || (defined(sun) && !defined(__svr4__)) || defined(__NeXT__)
#  define ssize_t size_t
#endif

#ifdef alpha
#  pragma pointer_size short
#endif

#else  /* EMERALD_MYRINET */
#  include "baselib.h"
#  if defined(E_NEEDS_CTYPE)
#    include <ctype.h>
#  endif
#endif /* EMERALD_MYRINET */

#endif /* _EMERALD_SYSTEM_H */
