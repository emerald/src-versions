(*
 * YACC parser for modula-2
 *
 * Copyright 1987, LAB D0G software.
 *
 *)

CONST YYFLAG  = -1000;

(* Variables are assumed defined in PARSER.DEF !!!!
   VAR
      yyv:	 ARRAY [-1..YYMAXDEPTH] OF YYSTYPE;
      yychar:	 INTEGER;
      yynerrs:	 INTEGER;
      yyerrflag: INTEGER;

   CONST YYMAXDEPTH = 150;
*)

PROCEDURE yyclearin();
BEGIN
   yychar := -1;
END yyclearin;

PROCEDURE yyerrok();
BEGIN
   yyerrflag := 0;
END yyerrok;

(*
 *  parser for yacc output
 *)
PROCEDURE yyparse(): INTEGER;

VAR
   yys:      ARRAY [-1..YYMAXDEPTH] OF INTEGER;
   yyj:      INTEGER;
   yym:      INTEGER;
   yypvt:    INTEGER;
   yystate:  INTEGER;
   yyps:     INTEGER;
   yyn:      INTEGER;
   yypv:     INTEGER;
   yyxi:     INTEGER;
   newstate: BOOLEAN;	 (* hack LD *)
   error:    BOOLEAN;	 (* hack LD *)
   i:        INTEGER;

BEGIN
   yystate   := 0;
   yychar    :=-1;
   yynerrs   := 0;
   yyerrflag := 0;
   yyps      :=-1;
   yypv      :=-1;
   newstate  := FALSE;	  (* new state true => goto newstate: *)
   error     := FALSE;	  (* error =  true  => goto errlab: *)


   LOOP LOOP
(*   yystack:   put a state and value onto the stack *)
      io.Writef(io.output, "\nyystack: (yystate %d)\n",yystate);

      IF NOT error THEN

	 IF NOT newstate THEN
	    INC(yyps);
	    IF yyps >= YYMAXDEPTH THEN
		yyerror("yacc stack overflow"); RETURN(1);
	    END;
	    yys[yyps] := yystate;
	    INC(yypv);
	    yyv[yypv] := yyval;

	    io.Writef(io.output, "\nyyps %d\n\tindex\tval\n",yyps);
	    FOR i:=yyps to 0 BY -1 DO
		io.Writef(io.output, "\t%d\t%d\n", i, yys[i]);
	    END;
	 END;

(*  yynewstate: *)
	 newstate := FALSE;

	 yyn := yypact[yystate];
	 io.Writef(io.output, "yynewstate: (yyn <- %d)\n",yyn);

	 IF NOT (yyn <= YYFLAG ) THEN
	    IF (yychar < 0) THEN
	       yychar:=yylex();
	       IF (yychar < 0) THEN yychar:=0; END;
	    END;
	    yyn := yyn + yychar;
	    IF NOT ((yyn < 0) OR (yyn >= YYLAST)) THEN
	       yyn:=yyact[yyn];
	       IF (yychk[yyn] = yychar) THEN (* valid shift *)
			yychar  := -1;
			yyval   := yylval;
			yystate := yyn;
			IF (yyerrflag > 0) THEN DEC(yyerrflag); END;

			io.Writef(io.output,
				  "\tshift: yystate %d, yyval.int %d\n",
				  yystate, yyval.IntVal);

			EXIT;
			(* goto yystack *);
	       END;
	    END; (* if *)
	 END; (* if *)

(* yydefault:  default state action *)

	 yyn:=yydef[yystate];
	 io.Writef(io.output, "yydefault: (yyn <- %d)\n",yyn);

	 IF (yyn = -2) THEN
	    IF (yychar < 0) THEN
	       yychar:=yylex();
	       IF (yychar < 0) THEN yychar := 0; END;
	    END;
	    (*
	     *	look through exception table
	     *)
	    yyxi := 0;
	    WHILE (yyexca[yyxi] <> -1) OR (yyexca[yyxi+1] <> yystate) DO
	       yyxi := yyxi + 2;
	    END;

	    yyxi := yyxi + 2;
	    WHILE (yyexca[yyxi] >= 0) AND (yyexca[yyxi] <> yychar) DO
	       yyxi := yyxi + 2;
	    END;

	    yyn := yyexca[yyxi+1];
	    IF (yyn < 0) THEN RETURN(0); END;  (* accept *)
	 END;

      END; (* error hack *)

      IF (yyn = 0) OR error THEN (* error *)
	 (*
	  *  error ... attempt to resume parsing
	  *)
	 IF error THEN yyerrflag := 1; END;
	 CASE (yyerrflag) OF

	    0,1,2:
	       IF (yyerrflag = 0) THEN (* brand new error *)
		  yyerror( "syntax error" );
		  INC(yynerrs);
	       END;
(* errlab:   *)
	 io.Writef(io.output, "errlab:\n");
	       IF error THEN
		  error := FALSE;
		  INC(yynerrs);
	       END;
	       (*
		*  incompletely recovered error ... try again
		*)
		yyerrflag := 3;

		(* find a state where "error" is a legal shift action *)

		WHILE (yyps >= 0) DO
		   yyn := yypact[yys[yyps]] + ERRCODE;
		   IF (yyn >= 0) AND
			(yyn < YYLAST) AND (yychk[yyact[yyn]] = ERRCODE) THEN
		      yystate := yyact[yyn];  (* simulate a shift of "error" *)
		      EXIT; (* goto yystack; *)
		   END;
		   yyn := yypact[yys[yyps]];

		   (* the current yyps has no shift on "error", pop stack *)

		   DEC(yyps);
		   DEC(yypv);
		END;
		(*
		 * there is no state on the stack with an error shift ... abort
		 *)
		RETURN(1);


	    |3: (* no shift yet; clobber input char *)
		IF (yychar = 0) THEN RETURN(1); END; (* EOF ==> quit *)
		yychar	 := -1;
		newstate := TRUE;
		(* goto yynewstate; try again in the same state *)
		EXIT;
	 END;
      END;
      (*
       *  reduction by production yyn
       *)
	io.Writef(io.output, "\treducing by production (yyn %d)\n",yyn);
      yyps  := yyps - yyr2[yyn];
      yypvt := yypv;
      yypv  := yypv - yyr2[yyn];
      yyval := yyv[yypv+1];
      yym   :=yyn;
      (*
       *  consult goto table to find next state
       *)
      yyn := yyr1[yyn];
      yyj := yypgo[yyn] + yys[yyps] + 1;

	io.Writef(io.output, "\tnew yyn <- %d yields yyj <- %d\n", yyn, yyj);

      IF (yyj >= YYLAST) THEN
	 yystate := yyact[yypgo[yyn]];
      ELSE
	 yystate := yyact[yyj];
	 IF (yychk[yystate] <> -yyn) THEN
	    yystate := yyact[yypgo[yyn]];
	 END;
      END;
      CASE (yyreduce(yym, yypvt, yyv, yyval)) OF
	  -1: RETURN (1);    (* YYABORT; *)
	 | 0: RETURN (0);    (* YYACCEPT;*)
	 | 1: error := TRUE; (* YYERROR; *)
	 ELSE;
      END;

   END; END;   (* goto yystack;   stack new state and value *)

END yyparse;  (* end of yyparse *)

BEGIN (* start up code *)
$B
END parser.  (* end of module *)
