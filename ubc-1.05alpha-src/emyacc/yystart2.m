operation yyreduce(
  yym: integer;
  yypvt: integer;
  var yyv: yysstack;
  var yyval: YYSTYPE) : integer;

var	yyreducevalue: integer;

%
%	3 is magic default value to return indicating that
%	the production was OK
%
	yyreducevalue := 3;
