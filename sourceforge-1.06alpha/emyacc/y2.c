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
#ifndef lint
static char sccsid[] = "@(#)y2.c	1.2    5/23/87";

#endif

#include <string.h>
#include "dextern"
#define IDENTIFIER 257
#define MARK 258
#define TERM 259
#define LEFT 260
#define RIGHT 261
#define BINARY 262
#define PREC 263
#define LCURLY 264
#define C_IDENTIFIER 265	/* name followed by colon */
#define NUMBER 266
#define START 267
#define TYPEDEF 268
#define TYPENAME 269
#define UNION 270
#define ENDFILE 0


/* communication variables between various I/O routines */

extern char *yyroot;
char *infile;			/* input file name */
int numbval;			/* value of an input number */
char tokname[NAMESIZE];		/* input token name */


/* storage of names */

char cnames[CNAMSZ];		/* place where token and nonterminal names
				 * are stored */
int cnamsz = CNAMSZ;		/* size of cnames */
char *cnamp = cnames;		/* place where next name is to be put in */
int ndefout = 3;		/* number of defined symbols output */


/* storage of types */
int ntypes;			/* number of types defined */
char *typeset[NTYPES];		/* pointers to type tags */


/* symbol tables for tokens and nonterminals */
int ntokens = 0;
struct toksymb tokset[NTERMS];
int toklev[NTERMS];
int nnonter = -1;
struct ntsymb nontrst[NNONTERM];
int start;			/* start symbol */


/* assigned token type values */
int extval = 0;


/* input and output file descriptors */
FILE
* finput,			/* yacc input file */
*faction,			/* file for saving actions */
*fdefine,			/* file for # defines */
*ftable,			/* y.tab.c file */
*ftemp,				/* tempfile to pass 2 */
*foutput,			/* y.output file */
*freduce,			/* reduce action output file */
*fm2temp,			/* M2 FULL output temp file */
*fm2pdef,
*fm2rdef;

char
    *pchParse = M2TABLE, *pchReduce = M2REDUCE, *pchLex = M2LEX, *pchError = M2ERROR;


/* storage for grammar rules */
int mem0[MEMSIZE];		/* production storage */
int
   *mem = mem0, nprod = 1,	/* number of productions */
   *prdptr[NPROD],		/* pointers to descriptions of productions */
    levprd[NPROD];		/* precedence levels for the productions */


int short
      M2FLAG = 0,		/* FULL modula2 flag */
      MFLAG = 0,		/* C modula2 flag */
      PFLAG = 0,		/* pascal flag */
      EMFLAG = 0;		/* emerald flag */


/*
 *  Give needed help
 */
Help()
{
  fprintf(stderr, "YACC [-evdhpmor] [-m2] [-<MODNAME> <module>] <grammar>\n\n");
  fprintf(stderr, "  -e  generate emerald code to a file ytab.m\n");
  fprintf(stderr, "  -v  verbose mode, generate file youtput\n");
  fprintf(stderr, "  -d  generate ytab.h with #define's for token values\n");
  fprintf(stderr, "  -p  accept semantic actions in Pascal (* .. *) also\n");
  fprintf(stderr, "  -m  accept semantic actions in Modula-2 (* .. *) also\n");
  fprintf(stderr, "  -m2 same as -m but generate a Modula-2 parser\n\n");
  fprintf(stderr, "  -<MODNAME> <module>  sets a module name used with -m2\n");
  fprintf(stderr, "    MODNAME is one of the following:(defaults in parens)\n");
  fprintf(stderr, "          yylex    - Module where yylex() can be found.       (scan)\n");
  fprintf(stderr, "          yyerror  - Module where yyerror() can be found.     (scan)\n");
  fprintf(stderr, "          yyparse  - Module where yyparse() will be created.  (parser)\n");
  fprintf(stderr, "          yyreduce - Module where yyreduce() will be created. (reduce)\n");
}


static int bExported = 0;

ExportSmag()
{
  if (!bExported) {
    if (M2FLAG) {
      fprintf(fm2pdef,
	      "EXPORT QUALIFIED %sYYMAXDEPTH,YYSSTACK,yyerrflag,yychar\n",
	      fdefine ? "" : "Token,");
      fprintf(fm2pdef,
	      "\t\t   ,yylval,yyparse,YYSTYPE,yyclearin,yyerrok%s;\n",
	      fdefine ? "" : ",YYBASE");
    }
    bExported = 1;
  }
}


setup(argc, argv)
int argc;
char *argv[];

{
  int i, j, lev, t, ty, c, *p;
  char actname[8], *pch, str[128];	/* hope it is enough */

  foutput = NULL;
  fdefine = NULL;
  i = 1;
  while (argc >= 2 && argv[1][0] == '-') {
    if (argv[1][1] == 'y' || argv[1][1] == 'Y') {
      if (!strcmp("yylex", argv[1] + 1)) {
	pchLex = argv[2];
      } else if (!strcmp("yyerror", argv[1] + 1)) {
	pchError = argv[2];
      } else if (!strcmp("yyparse", argv[1] + 1)) {
	pchParse = argv[2];
      } else if (!strcmp("yyreduce", argv[1] + 1)) {
	pchReduce = argv[2];
      } else
	error("illegal option: %s", argv[1]);
      argv += 2;
      argc -= 2;
      continue;
    }
    while (*++(argv[1])) {
      switch (*argv[1]) {

	case 'v':
	case 'V':
	  foutput = fopen(FILEU, "w");
	  if (foutput == NULL)
	    error("cannot open y.output");
	  continue;

	case 'D':
	case 'd':
	  if (!fdefine) fdefine = fopen(FILED, "w");
	  continue;

	case 'e':
	case 'E':
	  MFLAG = EMFLAG = 1;
	  if (!fdefine) fdefine = fopen(FILED, "w");
	  continue;

	case 'h':
	case 'H':
	  Help();
	  continue;

	case 'p':
	case 'P':
	  PFLAG = 1;
	  continue;

	case 'm':
	case 'M':
	  MFLAG = 1;
	  if (*(argv[1] + 1) == '2') {
	    argv[1]++;
	    M2FLAG = 1;
	  }
	  continue;

	case 'o':
	case 'O':
	  fprintf(stderr, "`o' flag now default in yacc\n");
	  continue;

	case 'r':
	case 'R':
	  error("Ratfor Yacc is dead!!!\n");

	default:
	  Help();
	  error("illegal option: %c", *argv[1]);
      }
    }
    argv++;
    argc--;
  }

  if (M2FLAG) {
    strcpy(str, pchParse);
    strcat(str, M2MOD);
  } else if (EMFLAG) {
    strcpy(str, pchParse);
    strcat(str, EMEXT);
  }
  pch = M2FLAG ? str : (EMFLAG ? str : OFILE);
  ftable = fopen(pch, "w");
  if (ftable == NULL)
    error("cannot open table file: %s", pch);

  if (PFLAG || MFLAG) {
    if (M2FLAG) {
      strcpy(str, pchReduce);
      strcat(str, M2MOD);
      freduce = fopen(str, "w");
    } else if (EMFLAG) {
      strcpy(str, pchReduce);
      strcat(str, EMEXT);
      freduce = fopen(str, "w");
    } else
      freduce = fopen(PFLAG ? ACTIONPAS : ACTIONMOD, "w");
    if (freduce == NULL)
      error("cannot open semantic action file");
  }
  if (M2FLAG) {
    fm2temp = fopen(M2TEMP, "w");
    if (fm2temp == NULL)
      error("cannot open M2 temp file: %s", M2TEMP);
    fprintf(freduce, "IMPLEMENTATION MODULE %s;\n", pchReduce);
    fprintf(freduce, "  FROM %s IMPORT yyparse,yylval,yyerrflag,yychar,YYSSTACK,YYSTYPE;\n", pchParse);
    fprintf(ftable, "IMPLEMENTATION MODULE %s;\n", pchParse);
    fprintf(ftable, "  IMPORT io;\n", pchError);
    fprintf(ftable, "  FROM %s IMPORT yyreduce;\n", pchReduce);
    fprintf(ftable, "  FROM %s IMPORT yylex;\n", pchLex);
    fprintf(ftable, "  FROM %s IMPORT yyerror;\n", pchError);
  } else if (EMFLAG) {
    fm2temp = fopen(M2TEMP, "w");
    if (fm2temp == NULL)
      error("cannot open M2 temp file: %s", M2TEMP);
  } else {
    fprintf(freduce, "#include \"%s\"\n", PFLAG ? STARTPAS : START1MOD);
  }

  ftemp = fopen(TEMPNAME, "w");
  faction = fopen(ACTNAME, "w");
  if (ftemp == NULL || faction == NULL)
    error("cannot open temp file");
  if (argc < 2 || ((finput = fopen(yyroot = infile = argv[1], "r")) == NULL)) {
    error("cannot open input file");
  }
  if (M2FLAG) {
    strcpy(str, pchReduce);
    strcat(str, M2DEF);
    fm2rdef = fopen(str, "w");
    strcpy(str, pchParse);
    strcat(str, M2DEF);
    fm2pdef = fopen(str, "w");
    fprintf(fm2rdef, "DEFINITION MODULE %s;\n", pchReduce);
    fprintf(fm2rdef, "   FROM %s IMPORT YYSSTACK,YYSTYPE,yyclearin,yyerrok;\n",
	    pchParse);
    fprintf(fm2rdef, "   EXPORT QUALIFIED yyreduce;\n");
    fprintf(fm2rdef, "   PROCEDURE yyreduce(yym: INTEGER; yypvt: INTEGER; VAR yyv: YYSSTACK; VAR yyval: YYSTYPE): INTEGER;\n");
    fprintf(fm2rdef, "END %s.\n", pchReduce);
    fclose(fm2rdef);

    fprintf(fm2pdef, "DEFINITION MODULE %s;\n", pchParse);
  } else if (EMFLAG) {
    strcpy(str, pchParse);
    strcat(str, M2DEF);
    fm2pdef = fopen(str, "w");
  }
  cnamp = cnames;
  defin(0, "$end");
  extval = 0400;
  defin(0, "error");
  defin(1, "$accept");
  mem = mem0;
  lev = 0;
  ty = 0;
  i = 0;

  /*
   * sorry -- no yacc parser here..... we must bootstrap somehow... 
   */

  for (t = gettok(); t != MARK && t != ENDFILE;) {
    switch (t) {
      case ';':
	t = gettok();
	break;

      case START:
	if ((t = gettok()) != IDENTIFIER) {
	  error("bad %%start construction");
	}
	start = chfind(1, tokname);
	t = gettok();
	continue;

      case TYPEDEF:
	if ((t = gettok()) != TYPENAME)
	  error("bad syntax in %%type");
	ty = numbval;
	for (;;) {
	  t = gettok();
	  switch (t) {

	    case IDENTIFIER:
	      if ((t = chfind(1, tokname)) < NTBASE) {
		j = TYPE(toklev[t]);
		if (j != 0 && j != ty) {
		  error("type redeclaration of token %s",
			tokset[t].name);
		} else
		  SETTYPE(toklev[t], ty);
	      } else {
		j = nontrst[t - NTBASE].tvalue;
		if (j != 0 && j != ty) {
		  error("type redeclaration of nonterminal %s",
			nontrst[t - NTBASE].name);
		} else
		  nontrst[t - NTBASE].tvalue = ty;
	      }
	    case ',':
	      continue;

	    case ';':
	      t = gettok();
	      break;
	    default:
	      break;
	  }
	  break;
	}
	continue;

      case UNION:
	/* copy the union declaration to the output */
	ExportSmag();
	cpyunion(1);
	t = gettok();
	continue;

      case LEFT:
      case BINARY:
      case RIGHT:
	++i;
      case TERM:
	lev = t - TERM;		/* nonzero means new prec. and assoc. */
	ty = 0;

	/* get identifiers so defined */

	t = gettok();
	if (t == TYPENAME) {	/* there is a type defined */
	  ty = numbval;
	  t = gettok();
	}
	for (;;) {
	  switch (t) {
	    case ',':
	      t = gettok();
	      continue;

	    case ';':
	      break;

	    case IDENTIFIER:
	      j = chfind(0, tokname);
	      if (lev) {
		if (ASSOC(toklev[j]))
		  error("redeclaration of precedence of %s", tokname);
		SETASC(toklev[j], lev);
		SETPLEV(toklev[j], i);
	      }
	      if (ty) {
		if (TYPE(toklev[j]))
		  error("redeclaration of type of %s", tokname);
		SETTYPE(toklev[j], ty);
	      }
	      if ((t = gettok()) == NUMBER) {
		tokset[j].value = numbval;
		if (j < ndefout && j > 2) {
		  error("please define type number of %s earlier",
			tokset[j].name);
		}
		t = gettok();
	      }
	      continue;

	  }

	  break;
	}

	continue;

      case LCURLY:
	defout();
	cpycode(1);
	t = gettok();
	continue;

      default:
	error("syntax error");

    }
  }

  if (t == ENDFILE) {
    error("unexpected EOF before %%");
  }
  /* t is MARK */

  defout();

  if (MFLAG && !M2FLAG && !EMFLAG) {
    fprintf(freduce, "#include \"%s\"\n", START2MOD);
  }
  if (M2FLAG) {
    fprintf(freduce, "PROCEDURE yyreduce( yym: INTEGER; yypvt: INTEGER; VAR yyv: YYSSTACK; VAR yyval: YYSTYPE): INTEGER;\n");
    fprintf(freduce, "        VAR     yyreducevalue: INTEGER;\n");
    fprintf(freduce, "BEGIN\n");
    fprintf(freduce, "        (*\n");
    fprintf(freduce, "         *  3 is magic default value to return\n");
    fprintf(freduce, "         *  indicating that the production was OK\n");
    fprintf(freduce, "         *)\n");
    fprintf(freduce, "        yyreducevalue := 3;\n");
    fprintf(freduce, "        CASE (yym) OF\n");
  } else if (EMFLAG) {
    fprintf(freduce, "operation yyreduce[ yym:integer, yypvt: integer] ->\n");
    fprintf(freduce, "        [yyreducevalue: integer, yyval:YYSTYPE]\n");
    fprintf(freduce, "        %%\n");
    fprintf(freduce, "        %%   3 is magic default value to return\n");
    fprintf(freduce, "        %%   indicating that the production was OK\n");
    fprintf(freduce, "        %%\n");
    fprintf(freduce, "        yyreducevalue <- 3\n\n");
    fprintf(freduce, "        if yym = ");
  }
  if (!M2FLAG && !EMFLAG) {
    fprintf(ftable, "#define yyclearin yychar = -1\n");
    fprintf(ftable, "#define yyerrok yyerrflag = 0\n");
    fprintf(ftable, "extern int yychar;\nextern short yyerrflag;\n");
    fprintf(ftable, "#ifndef YYMAXDEPTH\n#define YYMAXDEPTH 150\n#endif\n");
    if (!ntypes) {
      fprintf(ftable, "#ifndef YYSTYPE\n#define YYSTYPE int\n#endif\n");
    }
    fprintf(ftable, "YYSTYPE yylval, yyval;\n");
  }
  prdptr[0] = mem;
  /* added production */
  *mem++ = NTBASE;
  *mem++ = start;		/* if start is 0, we will overwrite with the
				 * lhs of the first rule */
  *mem++ = 1;
  *mem++ = 0;
  prdptr[1] = mem;

  while ((t = gettok()) == LCURLY) {
    cpycode(0);
  }

  if (t != C_IDENTIFIER)
    error("bad syntax on first rule");

  if (!start)
    prdptr[0][1] = chfind(1, tokname);

  /* read rules */

  while (t != MARK && t != ENDFILE) {

    /* process a rule */

    if (t == '|') {
      *mem++ = *prdptr[nprod - 1];
    } else if (t == C_IDENTIFIER) {
      *mem = chfind(1, tokname);
      if (*mem < NTBASE)
	error("token illegal on LHS of grammar rule");
      ++mem;
    } else
      error("illegal rule: missing semicolon or | ?");

    /* read rule body */

    t = gettok();
more_rule:
    while (t == IDENTIFIER) {
      *mem = chfind(1, tokname);
      if (*mem < NTBASE)
	levprd[nprod] = toklev[*mem];
      ++mem;
      t = gettok();
    }

    if (t == PREC) {
      if (gettok() != IDENTIFIER)
	error("illegal %%prec syntax");
      j = chfind(2, tokname);
      if (j >= NTBASE)
	error("nonterminal %s illegal after %%prec", nontrst[j - NTBASE].name);
      levprd[nprod] = toklev[j];
      t = gettok();
    }
    if (PFLAG) {
      fprintf(faction, "\n\n  %d:", nprod);
    }
    if (MFLAG) {
      if (EMFLAG) {
	fprintf(faction, "%s %d then ",
		nprod > 1 ? "\n\n\telseif yym = " : " ", nprod);
      } else {
	fprintf(faction, "\n\n%s %d:", nprod > 1 ? ";|" : " ", nprod);
      }
    }
    if (t == '=') {
      levprd[nprod] |= ACTFLAG;
      if (CFLAG)
	fprintf(faction, "\ncase %d:", nprod);
      cpyact(mem - prdptr[nprod] - 1);
      if (CFLAG)
	fprintf(faction, " break;");
      if ((t = gettok()) == IDENTIFIER) {
	/* action within rule... */

	sprintf(actname, "$$%d", nprod);
	j = chfind(1, actname);	/* make it a nonterminal */

	/* the current rule will become rule number nprod+1 */

	/* move the contents down, and make room for the null */
	for (p = mem; p >= prdptr[nprod]; --p)
	  p[2] = *p;
	mem += 2;

	/* enter null production for action */
	p = prdptr[nprod];

	*p++ = j;
	*p++ = -nprod;

	/* update the production information */
	levprd[nprod + 1] = levprd[nprod] & ~ACTFLAG;
	levprd[nprod] = ACTFLAG;

	if (++nprod >= NPROD)
	  error("more than %d rules", NPROD);
	prdptr[nprod] = p;

	/* make the action appear in the original rule */
	*mem++ = j;

	/* get some more of the rule */

	goto more_rule;
      }
    }
    if (PFLAG)
      fprintf(faction, " ;");

    while (t == ';')
      t = gettok();

    *mem++ = -nprod;

    /* check that default action is reasonable */

    if (ntypes && !(levprd[nprod] & ACTFLAG) &&
	nontrst[*prdptr[nprod] - NTBASE].tvalue) {

      /* no explicit action, LHS has value */
      register tempty;

      tempty = prdptr[nprod][1];
      if (tempty < 0)
	error("must return a value, since LHS has a type");
      else if (tempty >= NTBASE)
	tempty = nontrst[tempty - NTBASE].tvalue;
      else
	tempty = TYPE(toklev[tempty]);
      if (tempty != nontrst[*prdptr[nprod] - NTBASE].tvalue) {
	error("default action causes potential type clash");
      }
    }
    if (++nprod >= NPROD)
      error("more than %d rules", NPROD);
    prdptr[nprod] = mem;
    levprd[nprod] = 0;
  }

  /* end of all rules */
  finact();
  if (t == MARK) {
    if (!EMFLAG) {
      fprintf(ftable, "\n# line %d \"%s\"\n", lineno, infile);
    }
    while ((c = getc(finput)) != EOF)
      putc(c, ftable);
  }
  fclose(finput);
}


/* finish action routine */
finact()
{
  fclose(faction);

  WRITECONST("ERRCODE", tokset[2].value, ftable);
  if (EMFLAG)
    fprintf(ftable, "const vi <- vector.of[integer]\n");
}


/* define s to be a terminal if t=0 or a nonterminal if t=1 */
defin(t, s)
register char *s;
{
  register val;

  if (t) {
    if (++nnonter >= NNONTERM)
      error("too many nonterminals, limit %d", NNONTERM);
    nontrst[nnonter].name = cstash(s);
    return (NTBASE + nnonter);
  }
  /* must be a token */
  if (++ntokens >= NTERMS)
    error("too many terminals, limit %d", NTERMS);
  tokset[ntokens].name = cstash(s);

  /* establish value for token */

  if (s[0] == ' ' && s[2] == '\0')	/* single character literal */
    val = s[1];
  else if (s[0] == ' ' && s[1] == '\\') {	/* escape sequence */
    if (s[3] == '\0') {		/* single character escape sequence */
      switch (s[2]) {
	  /* character which is escaped */
	case 'n':
	  val = '\n';
	  break;
	case 'r':
	  val = '\r';
	  break;
	case 'b':
	  val = '\b';
	  break;
	case 't':
	  val = '\t';
	  break;
	case 'f':
	  val = '\f';
	  break;
	case '\'':
	  val = '\'';
	  break;
	case '"':
	  val = '"';
	  break;
	case '\\':
	  val = '\\';
	  break;
	default:
	  error("invalid escape");
      }
    } else if (s[2] <= '7' && s[2] >= '0') {	/* \nnn sequence */
      if (s[3] < '0' || s[3] > '7' || s[4] < '0' ||
	  s[4] > '7' || s[5] != '\0')
	error("illegal \\nnn construction");
      val = 64 * s[2] + 8 * s[3] + s[4] - 73 * '0';
      if (val == 0)
	error("'\\000' is illegal");
    }
  } else {
    val = extval++;
  }
  tokset[ntokens].value = val;
  toklev[ntokens] = 0;
  return (ntokens);
}

/* write out the defines (at the end of the declaration section) */
defout()
{
  register int i, c;
  register char *cp;

  if (EMFLAG) outputEmeraldObject();
  if (ntokens < ndefout)
    return;
  if (M2FLAG && fdefine == NULL) {
    fprintf(fm2pdef, "  CONST YYBASE = %d;\n", tokset[ndefout].value);
    fprintf(fm2pdef, "  TYPE Token = (\n");
  } else if (EMFLAG) {
    fprintf(fm2pdef, "  const YYBASE <- %d\n", tokset[ndefout].value);
    fprintf(fm2pdef, "  const Token <- integer\n");
  }
  for (i = ndefout; i <= ntokens; ++i) {
    cp = tokset[i].name;
    if (*cp == ' ')
      ++cp;			/* literals */

    for (; (c = *cp) != '\0'; ++cp) {
      if (isalnum(c) || c == '_');	/* VOID */
      else
	goto nodef;
    }

    if (M2FLAG) {
      if (fdefine == NULL) {
	if (i != ndefout)
	  fprintf(fm2pdef, ",");
	fprintf(fm2pdef, "%s", tokset[i].name);
	if ((i - ndefout + 1) % 10 == 0)
	  fprintf(fm2pdef, "\n");
      }
    } else if (EMFLAG) {
      /* we know fdefine is non null */
      fprintf(fdefine, "\tconst %s <- %d\n", tokset[i].name, i - ndefout);
    } else {
      fprintf(ftable, "#define %s %d\n", tokset[i].name, tokset[i].value);
      if (fdefine != NULL)
	fprintf(fdefine, "#define %s %d\n", tokset[i].name, tokset[i].value);
    }

nodef:;
  }

  ndefout = ntokens + 1;
  if (M2FLAG && fdefine == NULL)
    fprintf(fm2pdef, ");\n");
  if (!EMFLAG) 
    cpyunion(0);
}

char *cstash(s)
register char *s;
{
  char *temp;

  temp = cnamp;
  do {
    if (cnamp >= &cnames[cnamsz])
      error("too many characters in id's and literals");
    else
      *cnamp++ = *s;
  } while (*s++);
  return (temp);
}


gettok()
{
  register i, base;
  static int peekline;		/* number of '\n' seen in lookahead */
  register c, match, reserve;

begin:
  reserve = 0;
  lineno += peekline;
  peekline = 0;
  c = getc(finput);
  while (isspace(c)) {
    if (c == '\n')
      ++lineno;
    c = getc(finput);
  }
  if (c == '/' && (CFLAG || EMFLAG)) {	/* skip comment */
    lineno += skipcom('/');
    goto begin;
  }
  if (c == '(' && (PFLAG || MFLAG)) {	/* skip comment */
    lineno += skipcom(')');
    goto begin;
  }
  switch (c) {
    case EOF:
      return (ENDFILE);
    case '{':
      ungetc(c, finput);
      return ('=');		/* action ... */
    case '<':			/* get, and look up, a type name (union
				 * member name) */
      i = 0;
      while ((c = getc(finput)) != '>' && c >= 0 && c != '\n') {
	tokname[i] = c;
	if (++i >= NAMESIZE)
	  --i;
      }
      if (c != '>')
	error("unterminated < ... > clause");
      tokname[i] = '\0';
      for (i = 1; i <= ntypes; ++i) {
	if (!strcmp(typeset[i], tokname)) {
	  numbval = i;
	  return (TYPENAME);
	}
      }
      typeset[numbval = ++ntypes] = cstash(tokname);
      return (TYPENAME);

    case '"':
    case '\'':
      match = c;
      tokname[0] = ' ';
      i = 1;
      for (;;) {
	c = getc(finput);
	if (c == '\n' || c == EOF)
	  error("illegal or missing ' or \"");
	if (c == '\\') {
	  c = getc(finput);
	  tokname[i] = '\\';
	  if (++i >= NAMESIZE)
	    --i;
	} else if (c == match)
	  break;
	tokname[i] = c;
	if (++i >= NAMESIZE)
	  --i;
      }
      break;

    case '%':
    case '\\':

      switch (c = getc(finput)) {

	case '0':
	  return (TERM);
	case '<':
	  return (LEFT);
	case '2':
	  return (BINARY);
	case '>':
	  return (RIGHT);
	case '%':
	case '\\':
	  return (MARK);
	case '=':
	  return (PREC);
	case '{':
	  return (LCURLY);
	default:
	  reserve = 1;
      }

    default:

      if (isdigit(c)) {		/* number */
	numbval = c - '0';
	base = (c == '0') ? 8 : 10;
	for (c = getc(finput); isdigit(c); c = getc(finput)) {
	  numbval = numbval * base + c - '0';
	}
	ungetc(c, finput);
	return (NUMBER);
      } else if (isalpha(c) || c == '_' || c == '.' || c == '$') {
	i = 0;
	while (isalnum(c) || c == '_' || c == '.' || c == '$') {
	  tokname[i] = c;
	  if (reserve && isupper(c))
	    tokname[i] += 'a' - 'A';
	  if (++i >= NAMESIZE)
	    --i;
	  c = getc(finput);
	}
      } else
	return (c);

      ungetc(c, finput);
  }

  tokname[i] = '\0';

  if (reserve) {		/* find a reserved word */
    if (!strcmp(tokname, "term"))
      return (TERM);
    if (!strcmp(tokname, "token"))
      return (TERM);
    if (!strcmp(tokname, "left"))
      return (LEFT);
    if (!strcmp(tokname, "nonassoc"))
      return (BINARY);
    if (!strcmp(tokname, "binary"))
      return (BINARY);
    if (!strcmp(tokname, "right"))
      return (RIGHT);
    if (!strcmp(tokname, "prec"))
      return (PREC);
    if (!strcmp(tokname, "start"))
      return (START);
    if (!strcmp(tokname, "type"))
      return (TYPEDEF);
    if (!strcmp(tokname, "union"))
      return (UNION);
    error("invalid escape, or illegal reserved word: %s", tokname);
  }
  /* look ahead to distinguish IDENTIFIER from C_IDENTIFIER */

  c = getc(finput);
  while (isspace(c) || c == '/') {
    if (c == '\n')
      ++peekline;
    else if (c == '/' && (CFLAG || EMFLAG)) {	/* look for comments */
      peekline += skipcom('/');
    } else if (c == '(' /* ) */ && (PFLAG || MFLAG)) {
      peekline += skipcom( /* ( */ ')');
    }
    c = getc(finput);
  }
  if (c == ':')
    return (C_IDENTIFIER);
  ungetc(c, finput);
  return (IDENTIFIER);
}


/* determine the type of a symbol */
fdtype(t)
{
  register v;

  if (t >= NTBASE)
    v = nontrst[t - NTBASE].tvalue;
  else
    v = TYPE(toklev[t]);
  if (v <= 0)
    error("must specify type for %s", (t >= NTBASE) ? nontrst[t - NTBASE].name :
	  tokset[t].name);
  return (v);
}


chfind(t, s)
register char *s;
{
  int i;

  if (s[0] == ' ')
    t = 0;
  TLOOP(i) if (!strcmp(s, tokset[i].name))
    return i;
  NTLOOP(i) if (!strcmp(s, nontrst[i].name))
    return (i + NTBASE);

  /* cannot find name */
  if (t > 1)
    error("%s should have been defined earlier", s);
  return (defin(t, s));
}


outputEmeraldObject()
{
  static int done = 0;
  if (done || !EMFLAG) return;
  done = 1;
  fprintf(fm2pdef,
       "const parsercreator <- immutable object parsercreator\n");
  fprintf(fm2pdef, "  const parser <- typeobject parser\n");
  fprintf(fm2pdef, "    operation parse [ yylextype ] -> [integer]\n");
  fprintf(fm2pdef, "  end parser\n");
  fprintf(fm2pdef, "  export function getSignature -> [r:signature]\n");
  fprintf(fm2pdef, "    r <- parser\n");
  fprintf(fm2pdef, "  end getSignature\n");
  fprintf(fm2pdef,
      "  export operation create [environment:ENVIRON] -> [r:parser]\n");
  fprintf(fm2pdef, "    r <- object aYYParser\n");
}

/* copy the union declaration to the output, and the define file if present */
cpyunion(really)
int really;
{
  int level, c;
  FILE *outf;
  static int done = 0;
  outf = M2FLAG ? fm2pdef : EMFLAG ? (FILE *)NULL : ftable;

  if (!really) {
    if(!done) {
      if (M2FLAG) {
	if (outf) fprintf(outf, "   TYPE YYSTYPE = INTEGER\n");
	if (fdefine) fprintf(fdefine, "   TYPE YYSTYPE == INTEGER\n");
      } else if (EMFLAG) {
	if (outf) fprintf(outf, "   const YYSTYPE <- Tree\n");
	if (fdefine) fprintf(fdefine, "   const YYSTYPE <- Tree\n");
      } else {
	if (outf) fprintf(outf, "\n# line %d \"%s\"\n", lineno, infile);
	if (outf) fprintf(outf, "typedef int YYSTYPE;\nextern YYSTYPE yylval\n");
	if (fdefine) 
	  fprintf(fdefine, "typedef int YYSTYPE;\nextern YYSTYPE yylval\n");
      }
    }
    return;
  }
  done = 1;
  if (M2FLAG) {
    if (outf) fprintf(outf, "   TYPE YYSTYPE = RECORD\n");
    if (fdefine) fprintf(fdefine, "   TYPE YYSTYPE == RECORD\n");
  } else if (EMFLAG) {
    if (outf) fprintf(outf, "   const YYSTYPE <- record YYSTYPE\n");
    if (fdefine) fprintf(fdefine, "   const YYSTYPE <- record YYSTYPE\n");
  } else {
    if (outf) fprintf(outf, "\n# line %d \"%s\"\n", lineno, infile);
    if (outf) fprintf(outf, "typedef union ");
    if (fdefine) fprintf(fdefine, "\ntypedef union ");
  }
  level = 0;
  for (;;) {
    if ((c = getc(finput)) < 0)
      error("EOF encountered while processing %%union");
    if (!(M2FLAG || EMFLAG) || !(c == '}' || c == '{')) {
      if (outf) putc(c, outf);
      if (fdefine) putc(c, fdefine);
    }
    switch (c) {
      case '\n':
	++lineno;
	break;
      case '{':
	++level;
	break;
      case '}':
	--level;
	if (level == 0) {	/* we are finished copying */
	  if (EMFLAG) {
	    if (outf) fprintf(outf, "\n end YYSTYPE\n");
	    if (fdefine) fprintf(fdefine, "\n end YYSTYPE\n");
	  } else if (M2FLAG) {
	    if (fdefine) fprintf(fdefine, "\n END;\n");
	    if (outf) fprintf(outf, "\n END;\n");
	  } else {
	    if (outf) fprintf(outf, " YYSTYPE;\n");
	    if (fdefine) 
	      fprintf(fdefine, " YYSTYPE;\nextern YYSTYPE yylval;\n");
	  }
	  return;
	}
    }
  }
}


/* copies code between \{ and \} */
cpycode(context)
int context;
{
  int FLAG;
  FILE *outf;
  int c;
  long l;
  static int firstcode = 1;

  outf = (CFLAG || (EMFLAG && context)) ? ftable : freduce;
  if (EMFLAG && !firstcode) outputEmeraldObject();
  firstcode = 0;
  FLAG = M2FLAG && !bExported;
  c = getc(finput);
  if (c == '\n') {
    c = getc(finput);
    lineno++;
  }
  if (M2FLAG || EMFLAG)
    WRITELINENUMBER(lineno, infile, fm2pdef);
  WRITELINENUMBER(lineno, infile, outf);
  while (c >= 0) {
    if (c == '\\')
      if ((c = getc(finput)) == '}')
	return;
      else {
	putc('\\', outf);
	if (FLAG)
	  putc('\\', fm2pdef);
      }
    if (c == '%')
      if ((c = getc(finput)) == '}')
	return;
      else {
	putc('%', outf);
	if (FLAG)
	  putc('%', fm2pdef);
      }
    putc(c, outf);
    if (c == '\n')
      ++lineno;
    if (FLAG)
      putc(c, fm2pdef);
    c = getc(finput);
  }
  error("eof before %%}");
}


/* skip over comments */
skipcom(end)
{
  register c, i = 0;		/* i is the number of lines skipped */

  /* skipcom is called after reading a / */

  if (getc(finput) != '*')
    error("illegal comment");
  c = getc(finput);
  while (c != EOF) {
    while (c == '*') {
      c = getc(finput);
      if ((c == end && (!(PFLAG | MFLAG))) || (c == end && (PFLAG || MFLAG)))
	return (i);
    }
    if (c == '\n')
      ++i;
    c = getc(finput);
  }
  error("EOF inside comment");
  /* NOTREACHED */
}


/* copy C action to the next ; or closing } */
cpyact(offset)
{
  int brac = 0, c, match, j, s, tok;

  WRITELINENUMBER(lineno, infile, faction);

loop:
  c = getc(finput);
swt:
  switch (c) {

    case ';':
      if (brac == 0) {
	putc(c, faction);
	return;
      }
      goto lcopy;

    case '{':
      brac++;
      if (PFLAG || MFLAG)
	if (brac == 1) {
	  if (PFLAG)
	    fprintf(faction, " begin ");
	  goto loop;
	}
      if (CFLAG || EMFLAG)
	goto lcopy;

    case '$':
      s = 1;
      tok = -1;
      c = getc(finput);
      if (c == '<') {		/* type description */
	ungetc(c, finput);
	if (gettok() != TYPENAME)
	  error("bad syntax on $<ident> clause");
	tok = numbval;
	c = getc(finput);
      }
      if (c == '$') {
	fprintf(faction, "yyval");
	if (ntypes) {		/* put out the proper tag... */
	  if (tok < 0)
	    tok = fdtype(*prdptr[nprod]);
	  if (EMFLAG) {
	    /* do nothing */
	  } else {
	    fprintf(faction, ".%s", typeset[tok]);
	  }
	}
	goto loop;
      }
      if (c == '-') {
	s = -s;
	c = getc(finput);
      }
      if (isdigit(c)) {
	j = 0;
	while (isdigit(c)) {
	  j = j * 10 + c - '0';
	  c = getc(finput);
	}

	j = j * s - offset;
	if (j > 0) {
	  error("Illegal use of $%d", j + offset);
	}
	if (ntypes && EMFLAG) fprintf(faction, "(view ");
	if (CFLAG)
	  fprintf(faction, "yypvt[-%d]", -j);
	if (EMFLAG) {
	  fprintf(faction, "yyv[yypvt-%d]", -j);
	} else if (PFLAG || MFLAG) {
	  fprintf(faction, "yyv[yypvt-%d]", -j);
	}
	if (ntypes) {		/* put out the proper tag */
	  if (j + offset <= 0 && tok < 0)
	    error("must specify type of $%d", j + offset);
	  if (tok < 0)
	    tok = fdtype(prdptr[nprod][j + offset]);
	  if (EMFLAG) {
	    fprintf(faction, " as %s)", typeset[tok]);
	  } else {
	    fprintf(faction, ".%s", typeset[tok]);
	  }
	}
	goto swt;
      }
      putc('$', faction);
      if (s < 0)
	putc('-', faction);
      goto swt;

    case '}':
      if (--brac)
	goto lcopy;
      if (PFLAG)
	fprintf(faction, " end");
      if (MFLAG) {
	if (!EMFLAG)
	  fprintf(faction, ";");
      } else
	putc(c, faction);
      return;


    case '/':			/* look for comments */
      putc(c, faction);
      c = getc(finput);
      if (c != '*')
	goto swt;

      /* it really is a comment */

      putc(c, faction);
      c = getc(finput);
      while (c != EOF) {
	while (c == '*') {
	  putc(c, faction);
	  if ((c = getc(finput)) == '/')
	    goto lcopy;
	}
	putc(c, faction);
	if (c == '\n')
	  ++lineno;
	c = getc(finput);
      }
      error("EOF inside comment");

    case '\'':			/* character constant */
      match = '\'';
      goto string;

    case '"':			/* character string */
      match = '"';

  string:

      putc(c, faction);
      while (c = getc(finput)) {
	if (c == '\\') {
	  putc(c, faction);
	  c = getc(finput);
	  if (c == '\n')
	    ++lineno;
	} else if (c == match)
	  goto lcopy;
	else if (c == '\n')
	  error("newline in string or char. const.");
	putc(c, faction);
      }
      error("EOF in string or character constant");

    case EOF:
      error("action does not terminate");

    case '\n':
      ++lineno;
      goto lcopy;

  }

lcopy:
  putc(c, faction);
  goto loop;
}
