
(*
 * Copyright (c) 1986 Robert R. Henry
 *
 * @(#)yyredstart.h 1.2 1/8/87
 *
 * start of the yyreduce function
 *)
function yyreduce( yym: integer; yypvt: integer; var yyv: yysstack; var yyval: YYSTYPE): integer;
	var	yyreducevalue: integer;
begin
	(*
	 *	3 is magic default value to return indicating that
	 *	the production was OK
	 *)
	yyreducevalue := 3;
	case yym of

