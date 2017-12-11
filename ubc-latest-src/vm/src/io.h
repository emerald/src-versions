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
