# include "dextern"

/* important local variables */

int lastred;			/* the number of the last reduction of a
				 * state */
int defact[NSTATES];		/* the default actions of states */
static int yyexcaCount;


/* print the output for the states */
output()
{
  int i, k, c;
  register struct wset *u, *v;

  if (M2FLAG) {
    yyexcaCount = 0;
  } else if (EMFLAG) {
    fprintf(ftable, "const yyexca <- {\n");
  } else {
    fprintf(ftable, "short yyexca[] ={\n");
  }
  SLOOP(i) {			/* output the stuff for state i */
    nolook = !(tystate[i] == MUSTLOOKAHEAD);
    closure(i);
    /* output actions */
    nolook = 1;
    aryfil(temp1, ntokens + nnonter + 1, 0);
    WSLOOP(wsets, u) {
      c = *(u->pitem);
      if (c > 1 && c < NTBASE && temp1[c] == 0) {
	WSLOOP(u, v) {
	  if (c == *(v->pitem))
	    putitem(v->pitem + 1, (struct looksets *) 0);
	}
	temp1[c] = state(c);
      } else if (c > NTBASE && temp1[(c -= NTBASE) + ntokens] == 0) {
	temp1[c + ntokens] = amem[indgo[i] + c];
      }
    }

    if (i == 1)
      temp1[1] = ACCEPTCODE;

    /* now, we have the shifts; look at the reductions */

    lastred = 0;
    WSLOOP(wsets, u) {
      c = *(u->pitem);
      if (c <= 0) {		/* reduction */
	lastred = -c;
	TLOOP(k) {
	  if (BIT(u->ws.lset, k)) {
	    if (temp1[k] == 0)
	      temp1[k] = c;
	    else if (temp1[k] < 0) {	/* reduce/reduce conflict */
	      if (foutput != NULL)
		fprintf(foutput,
		     "\n%d:reduce/reduce conflict (red'ns %d and %d) on %s",
			i, -temp1[k], lastred, symnam(k));
	      if (-temp1[k] > lastred)
		temp1[k] = -lastred;
	      ++zzrrconf;
	    } else {		/* potential shift/reduce conflict */
	      precftn(lastred, k, i);
	    }
	  }
	}
      }
    }
    wract(i);
  }

  if (M2FLAG) {
    fprintf(ftable, "VAR yyexca: ARRAY [0..%d] OF INTEGER;\n", yyexcaCount - 1);
  } else if (EMFLAG) {
    fprintf(ftable, "}\n");
  } else {
    fprintf(ftable, "\t};\n");
  }
  wdef("YYNPROD", nprod);
}

int pkdebug = 0;


/* pack state i from temp1 into amem */
apack(p, n)
int *p;
{
  int off;
  register *pp, *qq, *rr;
  int *q, *r;

  /*
   * we don't need to worry about checking because we we will only look
   * entries known to be there... 
   */

  /* eliminate leading and trailing 0's */
  q = p + n;
  for (pp = p, off = 0; *pp == 0 && pp <= q; ++pp, --off)	/* VOID */
    ;
  if (pp > q)
    return (0);			/* no actions */
  p = pp;

  /* now, find a place for the elements from p to q, inclusive */
  r = &amem[ACTSIZE - 1];
  for (rr = amem; rr <= r; ++rr, ++off) {	/* try rr */
    for (qq = rr, pp = p; pp <= q; ++pp, ++qq) {
      if (*pp != 0) {
	if (*pp != *qq && *qq != 0)
	  goto nextk;
      }
    }

    /* we have found an acceptable k */
    if (pkdebug && foutput != NULL)
      fprintf(foutput, "off = %d, k = %d\n", off, rr - amem);

    for (qq = rr, pp = p; pp <= q; ++pp, ++qq) {
      if (*pp) {
	if (qq > r)
	  error("action table overflow");
	if (qq > memp)
	  memp = qq;
	*qq = *pp;
      }
    }
    if (pkdebug && foutput != NULL) {
      for (pp = amem; pp <= memp; pp += 10) {
	fprintf(foutput, "\t");
	for (qq = pp; qq <= pp + 9; ++qq)
	  fprintf(foutput, "%d ", *qq);
	fprintf(foutput, "\n");
      }
    }
    return (off);

nextk:;
  }
  error("no space in action table");
  /* NOTREACHED */
}


/* output the gotos for the nontermninals */
go2out()
{
  int i, j, k, best, count, cbest, times;

  fprintf(ftemp, "$\n");	/* mark begining of gotos */

  for (i = 1; i <= nnonter; ++i) {
    go2gen(i);

    /* find the best one to make default */

    best = -1;
    times = 0;

    for (j = 0; j <= nstate; ++j) {	/* is j the most frequent */
      if (tystate[j] == 0)
	continue;
      if (tystate[j] == best)
	continue;

      /* is tystate[j] the most frequent */

      count = 0;
      cbest = tystate[j];

      for (k = j; k <= nstate; ++k)
	if (tystate[k] == cbest)
	  ++count;

      if (count > times) {
	best = cbest;
	times = count;
      }
    }

    /* best is now the default entry */

    zzgobest += (times - 1);
    for (j = 0; j <= nstate; ++j) {
      if (tystate[j] != 0 && tystate[j] != best) {
	fprintf(ftemp, "%d,%d,", j, tystate[j]);
	zzgoent += 1;
      }
    }

    /* now, the default */

    zzgoent += 1;
    fprintf(ftemp, "%d\n", best);
  }
}


int g2debug = 0;


/* output the gotos for nonterminal c */
go2gen(c)
{
  int i, work, cc;
  struct item *p, *q;

  /* first, find nonterminals with gotos on c */
  aryfil(temp1, nnonter + 1, 0);
  temp1[c] = 1;

  work = 1;
  while (work) {
    work = 0;
    PLOOP(0, i) {
      if ((cc = prdptr[i][1] - NTBASE) >= 0) {	/* cc is a nonterminal */
	if (temp1[cc] != 0) {	/* cc has a goto on c, thus... */
	  cc = *prdptr[i] - NTBASE;	/* the left side of production i does
					 * too */
	  if (temp1[cc] == 0) {
	    work = 1;
	    temp1[cc] = 1;
	  }
	}
      }
    }
  }

  /* now, we have temp1[c] = 1 if a goto on c in closure of cc */
  if (g2debug && foutput != NULL) {
    fprintf(foutput, "%s: gotos on ", nontrst[c].name);
    NTLOOP(i) if (temp1[i])
      fprintf(foutput, "%s ", nontrst[i].name);
    fprintf(foutput, "\n");
  }
  /* now, go through and put gotos into tystate */
  aryfil(tystate, nstate, 0);
  SLOOP(i) {
    ITMLOOP(i, p, q) {
      if ((cc = *p->pitem) >= NTBASE) {
	if (temp1[cc -= NTBASE]) {	/* goto on c is possible */
	  tystate[i] = amem[indgo[i] + c];
	  break;
	}
      }
    }
  }
}


/* decide a shift/reduce conflict by precedence.
 * r is a rule number, t a token number
 * the conflict is in state s
 * temp1[t] is changed to reflect the action
 */
precftn(r, t, s)
{
  int lp, lt, action;

  lp = levprd[r];
  lt = toklev[t];
  if (PLEVEL(lt) == 0 || PLEVEL(lp) == 0) {
    /* conflict */
    if (foutput != NULL)
      fprintf(foutput, "\n%d: shift/reduce conflict (shift %d, red'n %d) on %s",
	      s, temp1[t], r, symnam(t));
    ++zzsrconf;
    return;
  }
  if (PLEVEL(lt) == PLEVEL(lp))
    action = ASSOC(lt);
  else if (PLEVEL(lt) > PLEVEL(lp))
    action = RASC;		/* shift */
  else
    action = LASC;		/* reduce */

  switch (action) {
    case BASC:
      temp1[t] = ERRCODE;
      return;			/* error action */
    case LASC:
      temp1[t] = -r;
      return;			/* reduce */
  }
}


/* output state i */
wract(i)
{
  /* temp1 has the actions, lastred the default */
  int p, p0, p1, ntimes = 0, tred, count, j, flag;
  static int veryfirsttime = 1;

  /* find the best choice for lastred */

  lastred = 0;
  TLOOP(j) {
    if (temp1[j] >= 0)
      continue;
    if (temp1[j] + lastred == 0)
      continue;
    /* count the number of appearances of temp1[j] */
    count = 0;
    tred = -temp1[j];
    levprd[tred] |= REDFLAG;
    TLOOP(p) {
      if (temp1[p] + tred == 0)
	++count;
    }
    if (count > ntimes) {
      lastred = tred;
      ntimes = count;
    }
  }

  /*
   * for error recovery, arrange that, if there is a shift on the error
   * recovery token, `error', that the default be the error action 
   */
  if (temp1[1] > 0)
    lastred = 0;

  /* clear out entries in temp1 which equal lastred */
  TLOOP(p) if (temp1[p] + lastred == 0)
    temp1[p] = 0;

  wrstate(i);
  defact[i] = lastred;

  flag = 0;
  TLOOP(p0) {
    if ((p1 = temp1[p0]) != 0) {
      if (p1 < 0) {
	p1 = -p1;
	goto exc;
      } else if (p1 == ACCEPTCODE) {
	p1 = -1;
	goto exc;
      } else if (p1 == ERRCODE) {
	p1 = 0;
	goto exc;
    exc:
	if (M2FLAG) {
	  if (flag++ == 0) {
	    fprintf(fm2temp,
		    "yyexca[%d]:=-1;yyexca[%d]:=%d;\n",
		    yyexcaCount, yyexcaCount + 1, i);
	    yyexcaCount += 2;
	  }
	  fprintf(fm2temp,
		  "yyexca[%d]:=%d;yyexca[%d]:=%d;\n",
		  yyexcaCount, tokset[p0].value, yyexcaCount + 1, p1);
	  yyexcaCount += 2;
	} else if (EMFLAG) {
	  if (flag++ == 0) {
	    fprintf(ftable, "%s~1,%s%d\n", veryfirsttime ? "" : ",",
		    i < 0 ? "~" : "", iabs(i));
	  }
	  fprintf(ftable, ",%s%d,%s%d\n",
		  tokset[p0].value < 0 ? "~" : "", iabs(tokset[p0].value),
		  p1 < 0 ? "~" : "", iabs(p1));
	  veryfirsttime = 0;
	} else {
	  if (flag++ == 0)
	    fprintf(ftable, "-1, %d,\n", i);
	  fprintf(ftable, "\t%d, %d,\n", tokset[p0].value, p1);
	}
	++zzexcp;
      } else {
	fprintf(ftemp, "%d,%d,", tokset[p0].value, p1);
	++zzacent;
      }
    }
  }
  if (flag) {
    defact[i] = -2;
    if (M2FLAG) {
      fprintf(fm2temp,
	      "yyexca[%d]:=-2;yyexca[%d]:=%d;\n",
	      yyexcaCount, yyexcaCount + 1, lastred);
      yyexcaCount += 2;
    } else if (EMFLAG) {
      fprintf(ftable, ",~2,%s%d\n", lastred < 0 ? "~" : "", iabs(lastred));
      yyexcaCount += 2;
    } else {
      fprintf(ftable, "\t-2, %d,\n", lastred);
    }
  }
  fprintf(ftemp, "\n");
  return;
}


/* writes state i */
wrstate(i)
{
  register j0, j1;
  register struct item *pp, *qq;
  register struct wset *u;

  if (foutput == NULL)
    return;
  fprintf(foutput, "\nstate %d\n", i);
  ITMLOOP(i, pp, qq) fprintf(foutput, "\t%s\n", writem(pp->pitem));
  if (tystate[i] == MUSTLOOKAHEAD) {
    /* print out empty productions in closure */
    WSLOOP(wsets + (pstate[i + 1] - pstate[i]), u) {
      if (*(u->pitem) < 0)
	fprintf(foutput, "\t%s\n", writem(u->pitem));
    }
  }
  /* check for state equal to another */

  TLOOP(j0) if ((j1 = temp1[j0]) != 0) {
    fprintf(foutput, "\n\t%s  ", symnam(j0));
    if (j1 > 0) {		/* shift, error, or accept */
      if (j1 == ACCEPTCODE)
	fprintf(foutput, "accept");
      else if (j1 == ERRCODE)
	fprintf(foutput, "error");
      else
	fprintf(foutput, "shift %d", j1);
    } else
      fprintf(foutput, "reduce %d", -j1);
  }
  /* output the final production */

  if (lastred)
    fprintf(foutput, "\n\t.  reduce %d\n\n", lastred);
  else
    fprintf(foutput, "\n\t.  error\n\n");

  /* now, output nonterminal actions */

  j1 = ntokens;
  for (j0 = 1; j0 <= nnonter; ++j0) {
    if (temp1[++j1])
      fprintf(foutput, "\t%s  goto %d\n", symnam(j0 + NTBASE), temp1[j1]);
  }
}



/* in order to free up the mem and amem arrays for the optimizer,
 * and still be able to output yyr1, etc., after the sizes of
 * the action array is known, we hide the nonterminals
 * derived by productions in levprd.
 */
hideprod()
{
  register i, j = 0;

  levprd[0] = 0;
  PLOOP(1, i) {
    if (!(levprd[i] & REDFLAG)) {
      ++j;
      if (foutput != NULL) {
	fprintf(foutput, "Rule not reduced:   %s\n", writem(prdptr[i]));
      }
    }
    levprd[i] = *prdptr[i] - NTBASE;
  }
  if (j)
    fprintf(stdout, "%d rules never reduced\n", j);
}
