#define E_NEEDS_STRING
#define E_NEEDS_CTYPE
#include "system.h"

#include "types.h"
#include "string.h"

int charIsAlpha( int ch )
{
  return isalpha(ch);
}

int charIsUpper( int ch )
{
  return isupper(ch);
}

int charIsLower( int ch )
{
  return islower(ch);
}

int charIsDigit( int ch )
{
  return isdigit(ch);
}

int charIsXdigit( int ch )
{
  return isxdigit(ch);
}

int charIsAlnum( int ch )
{
  return isalnum(ch);
}

int charIsSpace( int ch )
{
  return isspace(ch);
}

int charIsPunct( int ch )
{
  return ispunct(ch);
}

int charIsPrint( int ch )
{
  return isprint(ch);
}

int charIsGraph( int ch )
{
  return isgraph(ch);
}

int charIsCntrl( int ch )
{
  return iscntrl(ch);
}

int charToUpper( int ch )
{
  return toupper(ch);
}

int charToLower( int ch )
{
  return tolower(ch);
}

int stringIndex( String s, int ch )
{
  int i;
  for (i = 0; i < s->d.items; i++) {
    if (s->d.data[i] == ch) return i;
  }
  return JNIL;
}

int stringRIndex( String s, int ch )
{
  int i;
  for (i = s->d.items - 1; i >= 0; i--) {
    if (s->d.data[i] == ch) return i;
  }
  return JNIL;
}

extern void *memset(void *b, int c, size_t len);

static void prepare(char bits[256], String t)
{
  int i;
  memset(bits, 0, 256 * sizeof(char));
  for (i = 0; i < t->d.items; i++) {
    bits[t->d.data[i]] = 1;
  }
}
  
int stringSpan( String s, String t)
{
  char bits[256];
  int i;

  prepare(bits, t);
  for (i = 0; i < s->d.items; i++) {
    if (!bits[s->d.data[i]]) return i;
  }
  return i;
}

int stringCSpan( String s, String t)
{
  char bits[256];
  int i;

  prepare(bits, t);
  for (i = 0; i < s->d.items; i++) {
    if (bits[s->d.data[i]]) return i;
  }
  return i;
}

int stringStr(String s, String t)
{
  int i;
  
  if (t->d.items == 0) return 0;
  for (i = 0; i <= s->d.items - t->d.items; i++) {
    if (s->d.data[i] == t->d.data[0] && 
	s->d.data[i + t->d.items - 1] == t->d.data[t->d.items - 1] &&
	(t->d.items <= 2 || 
	 !memcmp(&s->d.data[i+1], &t->d.data[1], t->d.items - 2))) {
      return i;
    }
  }
  return JNIL;
}

void stringTok(String s, String brk, int *startp, int *endp)
{
  char bits[256];
  int start, end;
  prepare(bits, brk);
  for (start = 0; start < s->d.items; start++) {
    if (!bits[s->d.data[start]]) break;
  }
  
  if (start < s->d.items) {
    for (end = start + 1; end < s->d.items; end++) {
      if (bits[s->d.data[end]]) break;
    }
  } else {
    end = start;
  }
  *startp = start;
  *endp = end;
}
