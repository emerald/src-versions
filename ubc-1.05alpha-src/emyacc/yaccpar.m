% yacc parser for emerald
  
const yyflag : integer <- ~1000
const yymaxdepth <- 150

var yyv:	 vector.of[YYSTYPE] <-
                 vector.of[YYSTYPE].create [YYMAXDEPTH+1]
var yychar:	 integer
var yynerrs:	 integer
var yyerrflag:   integer
var yylval:      YYSTYPE
var yyval:       YYSTYPE

operation yyclearin
   yychar <- ~1
end yyclearin

operation yyerrok
   yyerrflag <- 0
end yyerrok

%
%	parser for yacc output
%
export operation parse[lex : YYLEXTYPE] ->
	[yyparsevalue : integer]

const yys <-  vi.create[YYMAXDEPTH+2]

var yyj:      integer
var yym:      integer
var yypvt:    integer
var yystate:  integer
var yyps:     integer
var yyn:      integer
var yypv:     integer
var yyxi:     integer
var bozo:     integer
var newstate: boolean	% hack ld
var error:    boolean	% hack ld
var i :       Integer
yystate   <-	0
yychar    <-	~1
yynerrs   <-	0
yyerrflag <-	0
yyps      <-	~1
yypv      <-	~1
newstate  <-	false	% new state true => goto newstate:
error     <-	false	% error =  true  => goto errlab:

loop
	loop
%   yystack:   put a state and value onto the stack
%		xx.printf["\nyystack: (yystate %d)\n",
%					{ yystate }]

		if !error then

			if !newstate then
				yyps <- yyps + 1
				if yyps>yymaxdepth then
					environment.error["yacc stack overflow"]
					yyparsevalue <- 1
					return
				end if
				yys[yyps] <- yystate
				yypv <- yypv + 1
				yyv[yypv] <- yyval

%				xx.printf["\nyyps %d\n\tindex\tval\n",{yyps}]
%				for (i <- yyps : i >= 0: i <- i - 1)
%					xx.printf["\t%d\t%d\n", {i, yys[i]}]
%				end for

			end if

%  yynewstate:
			newstate <- false

			yyn <- yypact[yystate]
%			xx.printf["yynewstate: (yyn <- %d)\n",{yyn}]

			if (yyn > yyflag) then
				if yychar < 0 then
					yychar, yylval <- lex.lex
					if yychar < 0 then
						yychar <- 0
					end if
				end if
				yyn <- yyn + yychar
				if (yyn >= 0) and (yyn < yylast) then
					yyn <- yyact[yyn]
					if yyn >= 0 and yychk[yyn] == yychar then % valid shift
						yychar  <- ~1
						yyval   <- yylval
						yystate <- yyn
						if yyerrflag > 0 then
							yyerrflag <- yyerrflag - 1
						end if

%			xx.printf["\tshift: yystate %d, yyval.int %d\n",
%				  {yystate, yyval$IntVal}]

						exit  % goto yystack
					end if
				end if
			end if

% yydefault:  default state action %

			 yyn <- yydef[yystate]
%			 xx.printf["yydefault: (yyn <- %d)\n",{yyn}]
			 if yyn == ~2 then
				if yychar < 0 then
					yychar, yylval <- lex.lex
					if yychar < 0 then
						yychar <- 0
					end if
				end if
%
%		look through exception table
%
				yyxi <- 0
				loop
				      exit when (yyexca[yyxi] == ~1) and (yyexca[yyxi+1] == yystate)
				      yyxi <- yyxi + 2
				end loop

				yyxi <- yyxi + 2
				loop
					exit when (yyexca[yyxi] < 0) or (yyexca[yyxi] == yychar)
					yyxi <- yyxi + 2
				end loop

	    			yyn <- yyexca[yyxi+1]
				if yyn < 0 then
					yyparsevalue <- 0
					return
				end if  % accept
			end if

		end if % error hack

		if ((yyn == 0) or error) then % error...attempt to resume parsing

			if error then
				yyerrflag <- 1
			 end if

			if 0 <= yyerrflag and yyerrflag <= 2 then
				if yyerrflag == 0 then % brand new error
					environment.error["syntax error"]
					yynerrs <- yynerrs + 1
				end if
% errlab:
%				xx.printf["errlab:\n", nil]
				if error then
					error <- false
					yynerrs <- yynerrs + 1
				end if
%
%		incompletely recovered error ... try again
%
				yyerrflag <- 3

%		find a state where "error" is a legal shift action %

				loop
					exit when yyps < 0
					yyn <- yypact[yys[yyps]] + errcode
					if (yyn>=0) and
					   (yyn<yylast) and
					   (yychk[yyact[yyn]] == errcode)
					then
						yystate <- yyact[yyn]  % simulate a shift of "error"
						exit % goto yystack
					end if
					yyn <- yypact[yys[yyps]]

%			the current yyps has no shift on "error", pop stack

					yyps <- yyps - 1
					yypv <- yypv - 1
				end loop
%
%		there is no state on the stack with an error shift ... abort
%
				yyparsevalue <- 1
				return

			elseif yyerrflag == 3 then % no shift yet clobber input char
	    
				if yychar == 0 then
					yyparsevalue <- 1
					return % don't discard eof, quit
				end if
				yychar	 <- ~1
				newstate <- true % goto yynewstate try again in the same state
				exit
			 end if
		end if
%
%	reduction by production yyn
%
%		xx.printf["\treducing by production (yyn %d)\n",{ yyn }]
		yyps  <- yyps - yyr2[yyn]
		yypvt <- yypv
		yypv  <- yypv - yyr2[yyn]
		yyval <- yyv[yypv+1]
		yym   <- yyn
%
%	consult goto table to find next state
%
		yyn <- yyr1[yyn]
		yyj <- yypgo[yyn] + yys[yyps] + 1

%		xx.printf["\tnew yyn <- %d yields yyj <- %d\n",{yyn, yyj}]

		if (yyj >= yylast) then
			yystate <- yyact[yypgo[yyn]]
		else
			yystate <- yyact[yyj]
			if (yystate >= 0 and yychk[yystate] != ~yyn) then
				yystate <- yyact[yypgo[yyn]]
			end if
		end if
  	        bozo, yyval <- self.yyreduce[yym, yypvt]
	        if bozo == ~1 then
			yyparsevalue <- 1
			return		% yyabort
		elseif bozo == 0 then
			yyparsevalue <- 0
			return		% yyaccept
		elseif bozo == 1 then
			error <- true	% yyerror
		end if
	end loop
end loop  % goto yystack   stack new state and value
end parse

$B
