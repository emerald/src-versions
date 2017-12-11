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
