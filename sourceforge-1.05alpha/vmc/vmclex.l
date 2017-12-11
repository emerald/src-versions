%{
#include "defs.h"
#include "vmcpar.h"

char *strsave(), *strsavestrip();
int linenumber = 1;
#undef YYLMAX
#define YYLMAX (20 * 8192)
%}
L [A-Za-z_]
Z [A-Za-z0-9_]
D [0-9]
Q ([^\\"]|\\.)
%%
"@".*"\n"		{ /* ignore comments */ linenumber ++; }
{L}{Z}*			{ yylval.string = strsave(yytext); return ID; }
\"{Q}*\"		{ yylval.string = strsavestrip(yytext); return STRING; }
"{"			{ getString("{", 0); return CODE; }
[ \t]			;
[\n]			{ linenumber ++; }
^State:			{ return KSTATE; }
^Interrupts:		{ return KINTERRUPTS; }
^Instructions:		{ return KINSTRUCTIONS; }
%%
getString(start, comment)
char *start;
int comment;
{
  int level = 1, c, i = 0, last = '.';
  char buffer[YYLMAX];
  while (*start) {
    assert(i < YYLMAX);
    buffer[i++] = *start++;
  }
  while (comment || level >= 1) {
    assert(i < YYLMAX);
    buffer[i++] = c = input();
    if (c == '\n') linenumber ++;
    if (!c) break;
    if (c == '{') level++;
    if (c == '}') if (--level < 1 && !comment) break;
    if (comment && last == '*' && c == '/') break;
    last = c;
  }
  buffer[i] = '\0';
  yylval.string = strsavestrip(buffer);
}

lexInit()
{

}

char *strsave(s)
char *s;
{
  char *t = malloc(strlen(s)+1);
  strcpy(t, s);
  return t;
}

char *strsavestrip(s)
char *s;
{
  int len = strlen(s);
  char *t = malloc(len-1);
  sprintf(t, "%.*s", len-2, s+1);
  return t;
}
