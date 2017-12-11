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

#ifndef _EMERALD_IO_H
#define _EMERALD_IO_H

/*
 * This should only happen when cxref is processing the file.
 */
#ifndef _EMERALD_SYSTEM_H
#include "system.h"
#endif

#ifndef _EMERALD_DIST_H
#include "dist.h"
#endif

#ifdef WIN32
#define ssize_t size_t
#endif

#ifdef FAKE_SELECT
#define real_select selecx
#define io_select select
#else
#define real_select select
#endif

#ifdef SELECT_USES_INT
#define EM_SELECT_T int 
#define S_A(x) &((x).fds_bits)
#else
#define EM_SELECT_T fd_set
#define S_A(x) &(x)
#endif 
typedef enum { EIO_Read, EIO_Write, EIO_Except } EDirection;
typedef void (*IoHandler)(int fd, EDirection direction, void *state);

typedef struct readBuffer {
  char *buffer;
  int nread, goal, acceptless;
  ssize_t (*reader)(int, void *, size_t);
} readBuffer;

extern void setupReadBuffer(readBuffer *rb, void *buf, int goal, int acceptless,
		     ssize_t (*reader)(int, void *, size_t));
extern int tryReading(readBuffer *rb, int s);

extern void IOInit(void);
extern void checkForIO(int wait);
extern ssize_t readFromSocket(int, void *, size_t);
extern ssize_t writeToSocket(int, void *, size_t);
extern ssize_t readFromSocketN(int, void *, size_t);
extern ssize_t writeToSocketN(int, void *, size_t);
extern void setHandler(int fd, IoHandler h, EDirection direction, void *state);
extern void resetHandler(int fd, EDirection direction);
extern ssize_t io_read(int, void *, size_t);
#endif
