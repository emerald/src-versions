export YYSTYPE, YYLEXTYPE, parsercreator
const YYSTYPE <- Tree
const YYLEXTYPE <- typeobject YYLEXTYPE
operation lex -> [integer, YYSTYPE]
end YYLEXTYPE
const ENVIRON <- typeobject ENVIRON
  operation error[String]
end ENVIRON
	const TEOF <- 0
	const TIDENTIFIER <- 1
	const TOPERATOR <- 2
	const TLPAREN <- 3
	const TRPAREN <- 4
	const TLSQUARE <- 5
	const TRSQUARE <- 6
	const TLCURLY <- 7
	const TRCURLY <- 8
	const TDOLLAR <- 9
	const TDOT <- 10
	const TDOTSTAR <- 11
	const TDOTQUESTION <- 12
	const TCOMMA <- 13
	const TCOLON <- 14
	const TSEMI <- 15
	const TINTEGERLITERAL <- 16
	const TREALLITERAL <- 17
	const TCHARACTERLITERAL <- 18
	const TSTRINGLITERAL <- 19
	const OAND <- 20
	const OASSIGN <- 21
	const OCONFORMSTO <- 22
	const ODIVIDE <- 23
	const OEQUAL <- 24
	const OGREATER <- 25
	const OGREATEREQUAL <- 26
	const OIDENTITY <- 27
	const OLESS <- 28
	const OLESSEQUAL <- 29
	const OMINUS <- 30
	const OMOD <- 31
	const ONEGATE <- 32
	const ONOT <- 33
	const ONOTEQUAL <- 34
	const ONOTIDENTITY <- 35
	const OOR <- 36
	const OPLUS <- 37
	const ORETURNS <- 38
	const OTIMES <- 39
	const KAND <- 40
	const KAS <- 41
	const KASSERT <- 42
	const KAT <- 43
	const KAWAITING <- 44
	const KATTACHED <- 45
	const KBEGIN <- 46
	const KBUILTIN <- 47
	const KBY <- 48
	const KCHECKPOINT <- 49
	const KCLOSURE <- 50
	const KCODEOF <- 51
	const KCLASS <- 52
	const KCONST <- 53
	const KELSE <- 54
	const KELSEIF <- 55
	const KEND <- 56
	const KENUMERATION <- 57
	const KEXIT <- 58
	const KEXPORT <- 59
	const KEXTERNAL <- 60
	const KFAILURE <- 61
	const KFALSE <- 62
	const KFIELD <- 63
	const KFIX <- 64
	const KFOR <- 65
	const KFORALL <- 66
	const KFROM <- 67
	const KFUNCTION <- 68
	const KIF <- 69
	const KIMMUTABLE <- 70
	const KINITIALLY <- 71
	const KISFIXED <- 72
	const KISLOCAL <- 73
	const KLOCATE <- 74
	const KLOOP <- 75
	const KMONITOR <- 76
	const KMOVE <- 77
	const KNAMEOF <- 78
	const KNEW <- 79
	const KNIL <- 80
	const KOBJECT <- 81
	const KOP <- 82
	const KOPERATION <- 83
	const KOR <- 84
	const KPRIMITIVE <- 85
	const KPROCESS <- 86
	const KRECORD <- 87
	const KRECOVERY <- 88
	const KREFIX <- 89
	const KRESTRICT <- 90
	const KRETURN <- 91
	const KRETURNANDFAIL <- 92
	const KSELF <- 93
	const KSIGNAL <- 94
	const KSUCHTHAT <- 95
	const KSYNTACTICTYPEOF <- 96
	const KTHEN <- 97
	const KTO <- 98
	const KTRUE <- 99
	const KTYPEOBJECT <- 100
	const KTYPEOF <- 101
	const KUNFIX <- 102
	const KUNAVAILABLE <- 103
	const KVAR <- 104
	const KVIEW <- 105
	const KVISIT <- 106
	const KWAIT <- 107
	const KWHEN <- 108
	const KWHILE <- 109
	const KWHERE <- 110
const parsercreator <- immutable object parsercreator
  const parser <- typeobject parser
    operation parse [ yylextype ] -> [integer]
  end parser
  export function getSignature -> [r:signature]
    r <- parser
  end getSignature
  export operation create [environment:ENVIRON] -> [r:parser]
    r <- object aYYParser

% #line 2 "em_ecomp.y" 

% #line 5 "em_ecomp.y" 
  const YYBASE <- 0
  const Token <- integer

% #line 2 "em_ecomp.y" 
%  imports go here

% #line 5 "em_ecomp.y" 

const MYENVT <- typeobject MYENVT
  operation done [yystype]
  operation error [String]
  operation SemanticError [Integer, String, RISA]
  operation errorf [String, RISA]
  operation warningf [String, RISA]
  operation printf [String, RISA]
  function getln -> [Integer]
  operation checknames[yystype, yystype]
  operation checknamesbyid[Ident, Ident]
  function getFileName -> [Tree]
  operation distribute [TreeMaker, Tree, Tree, Tree] -> [Tree]
  operation getITable -> [IdentTable]
end MYENVT
const env <- view environment as MYENVT

const ERRCODE <- 256
const vi <- vector.of[integer]

const yyexca <- {
~1,1
,0,~1
,~2,0
,~1,238
,310,68
,317,68
,320,68
,361,68
,~2,83
,~1,304
,271,268
,~2,267
,~1,315
,313,114
,318,114
,~2,68
,~1,335
,270,130
,278,130
,~2,132
,~1,444
,313,122
,~2,5
,~1,445
,311,120
,312,120
,313,120
,~2,5
}
const YYNPROD <- 269
const YYLAST <- 1772
const yyact %%1771
 <- {
176,489,291,9,402,46,62,377,221,292,
3,242,117,10,146,363,360,321,290,307,
25,21,17,74,313,214,193,4,94,95,
96,97,98,99,100,101,102,103,104,105,
236,39,259,6,263,216,148,243,112,268,
253,175,18,174,239,147,189,150,16,179,
412,58,118,15,241,184,13,44,366,496,
225,116,13,459,380,497,125,126,127,128,
129,130,131,132,133,134,135,136,137,138,
139,140,141,142,143,438,468,365,385,194,
11,495,280,68,494,483,386,466,12,274,
467,111,364,224,480,491,277,492,493,276,
279,113,114,172,478,17,191,280,296,93,
15,245,192,11,196,245,229,219,420,417,
477,470,68,204,464,198,199,77,14,87,
91,81,83,85,79,84,86,89,92,462,
275,82,80,75,88,460,90,78,119,120,
121,122,123,124,182,171,461,190,205,206,
93,93,203,70,210,73,186,187,450,204,
72,449,443,446,212,447,215,217,192,441,
222,91,91,227,440,217,200,439,89,92,
92,76,225,19,69,88,437,90,90,436,
71,404,8,223,238,246,215,431,264,19,
248,201,202,68,208,13,252,232,411,237,
232,226,240,190,410,220,230,409,247,399,
238,235,234,398,235,234,228,395,232,375,
285,231,384,217,288,237,372,217,109,106,
107,108,235,234,369,367,191,356,350,256,
256,278,303,270,257,293,294,295,255,255,
254,254,250,309,215,349,308,308,348,286,
283,315,297,287,311,305,355,310,218,289,
306,282,245,251,185,213,238,361,209,180,
361,197,371,173,183,249,374,368,301,110,
115,237,378,335,23,379,20,8,387,388,
389,390,391,7,383,396,397,359,358,357,
352,353,354,394,57,56,149,406,405,45,
42,392,403,403,26,400,30,486,472,393,
454,336,382,418,12,376,298,299,408,413,
373,302,329,328,327,425,419,118,326,192,
325,414,415,324,323,322,351,320,423,427,
319,318,432,222,401,434,433,317,314,370,
312,403,262,435,261,260,448,22,378,273,
272,335,335,444,445,442,271,426,269,451,
452,453,67,381,424,195,284,456,64,63,
457,362,455,281,458,244,233,488,463,66,
465,210,188,65,192,192,211,24,5,2,
1,0,0,0,0,471,469,0,0,0,
0,0,474,0,10,416,0,0,473,0,
0,481,482,0,0,0,335,335,475,490,
0,192,192,487,479,0,330,0,11,498,
47,0,0,490,61,407,0,0,264,0,
0,0,335,50,51,49,48,232,335,0,
265,0,0,335,335,0,0,0,0,0,
0,235,234,0,0,267,0,266,0,337,
0,0,191,342,0,0,0,70,0,73,
0,0,0,485,72,334,0,0,0,53,
0,339,333,0,0,0,331,59,0,0,
0,0,332,60,338,0,43,55,69,0,
0,0,343,0,71,0,340,0,346,347,
54,345,0,0,0,0,52,68,330,341,
11,0,47,0,344,93,61,0,0,0,
0,0,0,0,0,50,51,49,48,0,
0,0,0,77,0,87,91,81,83,85,
79,84,86,89,92,0,0,82,80,75,
88,337,90,78,191,342,430,0,0,70,
0,73,0,0,0,484,72,334,0,0,
0,53,0,339,333,0,0,0,331,59,
0,0,0,0,332,60,338,0,43,55,
69,0,0,0,343,0,71,76,340,0,
346,347,54,345,0,0,0,0,52,68,
330,341,11,0,47,0,344,93,61,0,
0,0,0,0,0,0,0,50,51,49,
48,0,0,0,0,77,0,87,91,81,
83,85,79,84,86,89,92,0,0,82,
80,75,88,337,90,78,191,342,429,0,
0,70,0,73,0,0,0,422,72,334,
0,0,0,53,0,339,333,0,0,0,
331,59,0,0,0,0,332,60,338,0,
43,55,69,0,0,0,343,0,71,76,
340,0,346,347,54,345,0,0,0,0,
52,68,330,341,11,0,47,0,344,93,
61,0,0,0,0,0,0,0,0,50,
51,49,48,0,0,0,0,77,0,87,
91,81,83,85,79,84,86,89,92,0,
0,82,80,75,88,337,90,78,191,342,
0,0,0,70,0,73,0,0,0,0,
72,334,0,0,0,53,0,339,333,0,
0,0,331,59,0,0,0,0,332,60,
338,0,43,55,69,0,0,0,343,0,
71,76,340,0,346,347,54,345,0,0,
0,0,52,68,421,341,316,330,0,11,
344,47,0,0,93,61,181,0,0,0,
0,0,0,0,50,51,49,48,0,0,
0,0,77,0,87,91,81,83,85,79,
84,86,89,92,0,0,82,80,75,88,
337,90,78,191,342,0,0,0,70,0,
73,0,0,0,0,72,334,0,0,0,
53,0,339,333,0,0,0,331,59,0,
0,0,0,332,60,338,0,43,55,69,
0,0,0,343,0,71,76,340,0,346,
347,54,345,0,0,0,300,52,68,264,
341,11,0,47,0,344,207,61,232,258,
0,265,264,0,0,0,50,51,49,48,
0,232,235,234,265,0,267,0,266,0,
41,0,40,27,0,235,234,0,0,267,
0,266,0,0,32,0,0,0,0,0,
70,33,73,0,0,0,0,72,0,0,
0,0,53,0,0,0,0,0,0,0,
59,0,38,37,31,0,60,177,34,43,
55,69,0,0,0,0,0,71,0,0,
29,0,11,54,47,0,36,0,61,52,
68,35,0,0,0,28,178,50,51,49,
48,0,0,0,0,0,0,0,0,0,
0,41,0,40,27,0,0,0,0,0,
0,0,0,0,0,32,0,0,0,0,
0,70,33,73,0,0,0,0,72,0,
0,0,0,53,0,0,0,0,0,0,
0,59,0,38,37,31,0,60,177,34,
43,55,69,0,0,0,0,0,71,0,
0,29,0,11,54,47,0,36,0,61,
52,68,35,0,0,0,28,178,50,51,
49,48,0,0,0,0,0,0,0,0,
0,0,41,0,40,27,0,0,0,0,
0,0,0,0,0,0,32,0,0,0,
0,0,70,33,73,0,0,0,0,72,
0,0,0,0,53,0,0,0,0,0,
0,0,59,0,38,37,31,0,60,0,
34,43,55,69,0,0,0,0,0,71,
0,0,29,0,304,54,47,0,36,0,
61,52,68,35,0,0,0,28,0,50,
51,49,48,0,0,0,0,0,0,0,
0,0,0,41,0,40,27,0,0,0,
0,0,0,0,0,0,0,32,0,0,
0,0,0,70,33,73,0,0,0,0,
72,0,0,0,0,53,0,0,0,0,
0,0,0,59,0,38,37,31,0,60,
0,34,43,55,69,0,0,0,0,0,
71,0,0,29,0,11,54,47,0,36,
0,61,52,68,35,0,0,0,28,0,
50,51,49,48,0,0,11,0,47,0,
0,0,61,0,0,0,0,0,0,0,
0,50,51,49,48,0,0,0,0,0,
0,0,0,0,70,0,73,0,0,0,
0,72,0,0,0,0,53,0,0,0,
0,0,0,0,59,70,0,73,0,0,
60,0,72,43,55,69,0,53,0,0,
0,71,0,0,0,59,0,54,0,0,
0,60,0,52,68,55,69,0,93,0,
0,0,71,0,0,0,0,0,54,0,
0,0,0,0,52,68,77,0,87,91,
81,83,85,79,84,86,89,92,93,0,
82,80,75,88,0,90,78,0,0,0,
0,0,0,0,0,0,77,0,87,91,
81,83,85,79,84,86,89,92,0,0,
82,80,75,88,0,90,78,0,0,0,
0,0,0,0,0,0,0,0,0,93,
76,0,0,0,0,0,0,0,0,0,
0,0,0,0,428,0,0,77,0,87,
91,81,83,85,79,84,86,89,92,93,
76,82,80,75,88,0,90,78,0,0,
0,0,0,0,145,476,0,77,0,87,
91,81,83,85,79,84,86,89,92,0,
0,82,80,75,88,93,90,78,144,0,
0,0,0,0,0,0,0,0,0,0,
0,76,0,77,0,87,91,81,83,85,
79,84,86,89,92,170,151,82,80,75,
88,0,90,78,0,0,0,0,0,0,
0,76,0,0,153,0,169,165,154,156,
158,167,157,159,163,166,160,161,155,168,
152,162,0,164,170,151,0,0,0,0,
0,0,0,0,0,0,0,76,0,0,
0,0,0,153,0,93,165,154,156,158,
0,157,159,163,166,160,161,155,0,152,
162,0,164,77,93,87,91,81,83,85,
79,84,86,89,92,0,0,82,80,0,
88,0,90,78,87,91,81,83,85,79,
84,86,89,92,0,0,82,80,0,88,
0,90
}
const yypact %%498
 <- {
~1000,~1000,27,~1000,~1000,~1000,~1000,~125,~23,~207,
~1000,~1000,~42,~1000,60,~125,56,~1000,~1000,935,
~1000,~1000,935,~1000,~1000,1366,~1000,935,935,935,
935,935,935,935,935,935,935,935,935,2,
~1000,~1000,67,1138,~1000,~1000,~1000,935,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~124,
~124,935,~1000,~1000,~1000,~1000,~1000,~1000,~23,~23,
~23,~23,~23,~23,1366,935,935,935,935,935,
935,935,935,935,935,935,935,935,935,935,
935,935,935,935,1475,1330,1249,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,1397,1138,1397,65,
844,57,655,~1000,~1000,~42,~1000,54,1366,10,
10,10,~26,~23,61,1456,1456,1475,1475,~79,
~79,~79,~79,~79,~79,~79,~79,~79,~78,~78,
~1000,~1000,~1000,~1000,935,935,57,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,57,57,~1000,~81,~1000,1366,935,935,~1000,
753,~1000,53,935,~1000,42,~1000,46,~176,~1000,
~138,~1000,~1000,~200,~1000,46,~1000,~125,1366,1366,
~1000,~1000,~1000,~1000,844,1366,1366,~1000,~127,~1000,
1366,~67,~1000,~1000,~26,~1000,~1000,~1000,~199,~125,
~1000,~23,~1000,~1000,~125,~23,10,52,~1000,~1000,
~125,~1000,1436,1436,~1000,~1000,706,~1000,~1000,~201,
~26,~1000,~143,~1000,9,~1000,~1000,~58,~1000,~1000,
~1000,~1000,~1000,46,~1000,~1000,~1000,46,~125,~1000,
~1000,~1000,~1000,~1000,~85,~1000,~1000,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~192,~23,~23,~23,693,~1000,
~22,1026,~1000,~1000,~4,~1000,~2,~2,~1000,~1000,
~9,546,~1000,~15,~18,~35,~23,~58,~42,~42,
~125,~1000,6,1366,~1000,~88,~26,~255,~1000,13,
~255,~54,~52,~1000,~1000,~1000,~3,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,935,~1000,~186,~103,2,~172,935,935,935,
935,935,~1000,~93,935,935,~1000,~1000,~92,~94,
1397,~42,~57,~57,~1000,~1000,935,~1000,~1000,192,
~1000,~1000,~255,~1000,~11,~14,~20,~203,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~23,~173,~1000,550,444,
1117,~42,~1000,~1000,935,1117,935,1366,1219,448,
346,1366,~86,~138,~1000,~1000,1366,1366,~1000,~1000,
~1000,~57,~1000,~1000,935,~1000,1366,~125,~1000,~59,
~63,~1000,~1000,~168,~106,~109,~64,935,~121,~1000,
~1000,~1000,~139,~76,~87,1366,2,~82,935,935,
935,~1000,~1000,~1000,1366,~1000,935,~254,~1000,~153,
~184,~1000,~1000,~167,651,651,~1000,935,~222,935,
935,1366,1366,1366,~166,~1000,1366,~1000,~1000,~215,
~1000,~1000,~1000,~130,935,1366,~1000,~1000,~125,~1000,
1117,1300,~123,~1000,~140,~137,1117,~164,~1000,~1000,
~157,342,240,~158,~218,~221,~194,~1000,~195,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~158,~1000
}
const yypgo %%104
 <- {
0,460,459,9,458,43,3,58,52,457,
0,6,99,65,456,5,453,452,56,54,
8,26,449,1,447,49,50,45,19,16,
446,11,47,445,443,441,15,440,439,25,
40,438,436,42,435,432,24,428,426,420,
419,417,4,416,415,414,412,44,18,14,
2,410,409,408,407,401,400,397,17,395,
394,393,390,388,384,383,382,380,375,7,
373,372,371,41,12,370,369,368,367,366,
364,360,67,59,53,359,57,55,46,356,
51,355,354,330,61
}
const yyr1 %%268
 <- {
0,1,2,2,2,3,4,4,7,7,
8,9,11,16,17,17,18,22,21,21,
6,6,23,23,23,23,24,24,14,14,
25,25,30,30,27,27,27,31,31,33,
33,34,34,32,32,28,28,28,29,29,
35,35,36,36,36,13,13,38,41,42,
42,42,44,44,45,39,39,19,19,46,
47,47,47,47,51,49,49,5,50,52,
52,53,48,40,40,40,40,40,43,43,
57,58,54,55,56,60,60,60,63,63,
63,63,63,63,63,63,63,63,63,63,
63,63,77,77,61,61,62,62,78,78,
79,80,80,64,66,66,65,67,81,81,
82,82,68,68,69,70,70,70,70,71,
75,76,85,85,85,86,86,20,20,72,
87,87,88,88,73,74,84,84,89,89,
10,10,10,10,10,10,10,10,10,10,
10,10,10,10,10,10,10,10,10,10,
10,10,10,10,10,10,10,10,10,10,
10,10,90,83,83,83,83,83,91,91,
91,91,91,91,91,92,92,92,26,26,
26,97,96,98,98,98,98,98,98,98,
98,98,98,98,98,98,98,98,99,99,
99,59,59,59,59,93,93,94,94,100,
100,100,95,95,95,95,95,95,95,95,
95,95,102,103,103,103,37,37,101,101,
101,104,104,104,104,104,104,15,12
}
const yyr2 %%268
 <- {
0,2,1,2,2,0,4,2,1,1,
2,1,6,5,1,2,4,5,1,3,
1,3,1,1,1,1,1,3,1,2,
5,5,1,1,1,2,3,1,3,1,
0,1,0,5,3,1,3,4,1,1,
1,2,4,4,2,0,2,7,8,1,
3,3,1,3,10,1,2,1,1,2,
1,1,1,1,1,4,5,5,3,1,
2,2,4,1,2,2,2,2,1,2,
4,3,4,4,4,1,2,2,1,1,
1,1,1,1,1,1,1,1,1,1,
1,1,1,3,1,5,1,4,1,3,
3,1,2,5,11,11,4,2,1,2,
1,3,1,3,2,4,4,4,2,3,
1,1,1,2,2,1,1,1,1,11,
1,1,1,1,2,2,1,3,1,1,
1,3,3,3,3,2,3,3,3,3,
3,3,3,3,3,4,4,3,3,3,
3,3,3,2,2,2,2,2,2,2,
2,2,1,1,2,3,3,3,1,3,
4,3,4,4,4,1,1,3,1,1,
1,1,1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,1,1,
1,1,1,1,1,2,3,1,3,1,
2,2,1,1,1,1,1,1,1,1,
1,1,4,1,1,2,1,2,1,2,
2,1,1,1,1,1,1,1,1
}
const yychk %%498
 <- {
~1000,~1,~2,~3,0,~4,~5,316,310,~6,
~15,258,~12,258,355,270,~7,~3,~8,271,
276,~15,~51,278,~9,~10,~90,290,362,347,
~89,331,301,308,335,358,353,330,329,~83,
289,287,~91,336,~92,~95,~15,260,276,275,
273,274,356,319,350,337,~101,~102,~104,327,
333,264,~11,~38,~41,~16,~22,~45,357,338,
307,344,314,309,~10,293,341,277,297,284,
292,281,291,282,285,283,286,279,294,287,
296,280,288,259,~10,~10,~10,~10,~10,~10,
~10,~10,~10,~10,~10,~10,267,268,269,266,
262,~92,~10,~104,~104,~103,~3,~84,~10,~12,
~12,~12,~12,~12,~12,~10,~10,~10,~10,~10,
~10,~10,~10,~10,~10,~10,~10,~10,~10,~10,
~10,~10,~10,~10,298,355,~59,~97,~98,~99,
~96,259,293,277,281,291,282,285,283,286,
289,290,294,287,296,280,288,284,292,279,
258,~92,~59,258,~94,~100,~10,334,363,~93,
262,261,~7,270,~13,304,~13,~13,~17,~18,
~19,302,~3,~21,~12,~44,~3,260,~10,~10,
~93,~93,~93,263,270,~10,~10,263,~94,265,
~10,~14,~3,273,~39,~3,~27,~3,262,313,
~18,~20,~3,361,313,270,~27,~15,~100,263,
313,~25,325,~30,340,339,~40,~46,~3,~19,
~39,263,~31,~32,~33,334,~15,~21,~15,~12,
~13,261,~15,~26,~96,~97,~98,~26,313,~43,
~54,~55,~56,~57,316,328,345,343,~25,~47,
~5,~48,~49,~50,310,361,320,317,~40,263,
270,~34,302,~8,~42,~3,~27,~27,~15,~57,
~58,~60,~3,~58,~58,~58,320,~21,~12,~12,
313,~32,~12,~10,258,309,~39,~28,~3,295,
~28,313,~61,~46,~63,~3,360,~64,~65,~66,
~67,~68,~69,~70,~71,~72,~73,~74,~75,~76,
256,326,332,322,315,~83,~82,299,334,321,
346,359,303,342,364,351,348,349,313,313,
313,~12,~8,~8,~8,~15,271,~5,~43,~40,
~29,~3,~35,~36,367,352,323,262,~29,328,
~62,~3,318,~77,~3,262,~78,~79,~10,~60,
260,~12,~81,~3,365,270,278,~10,~10,~10,
~10,~10,~58,~86,~3,350,~10,~10,345,343,
~59,~8,~52,~3,278,~52,~10,313,~36,258,
258,258,263,~31,~58,~58,~12,312,~80,~3,
311,354,313,~68,~8,~10,~83,~84,355,300,
300,313,~20,~52,~10,~15,278,279,263,313,
313,263,~79,313,~60,~60,332,271,~53,278,
270,~10,~10,~10,~85,~3,~10,~37,~11,327,
318,360,326,~10,366,~10,273,276,262,~11,
271,~10,~87,~3,~6,~68,305,263,261,~68,
278,~60,~60,262,313,313,~88,~3,~24,~23,
~15,273,275,276,322,322,263,270,~23
}
const yydef %%498
 <- {
5,~2,0,2,1,3,4,0,0,7,
20,267,5,268,0,0,0,8,9,0,
6,21,0,74,10,11,160,0,0,0,
0,0,0,0,0,0,0,0,0,192,
158,159,193,0,198,205,206,0,242,243,
244,245,246,247,248,249,250,251,258,0,
0,5,261,262,263,264,265,266,0,0,
0,0,0,0,77,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,165,0,0,183,184,185,
186,187,188,189,190,191,0,0,0,0,
0,194,0,259,260,5,253,254,156,55,
55,55,5,0,5,161,162,163,164,166,
167,168,169,170,171,172,173,174,177,178,
179,180,181,182,0,0,195,231,232,233,
234,211,213,214,215,216,217,218,219,220,
221,222,223,224,225,226,227,228,229,230,
212,196,197,201,0,237,239,0,0,199,
0,207,0,255,5,0,5,5,5,14,
5,67,68,0,18,5,62,0,175,176,
202,203,204,200,0,240,241,235,0,252,
157,0,28,56,5,65,5,34,40,0,
15,0,147,148,0,0,55,0,238,236,
0,29,0,0,32,33,0,66,~2,0,
5,35,0,37,42,39,13,0,17,19,
5,63,12,5,208,209,210,5,0,84,
85,86,87,88,0,5,5,5,5,69,
70,71,72,73,0,0,0,0,0,36,
40,0,41,16,5,59,5,5,57,89,
0,5,95,0,0,0,0,0,0,0,
0,38,0,44,~2,0,5,5,45,0,
5,0,5,96,97,~2,5,98,99,100,
101,102,103,104,105,106,107,108,109,110,
111,0,5,0,5,~2,0,0,0,0,
0,0,5,5,0,0,140,141,0,0,
0,0,5,5,78,58,0,60,61,0,
30,48,49,50,0,0,0,40,31,92,
91,116,5,5,112,0,5,118,0,5,
0,0,127,128,0,0,0,134,0,0,
0,138,0,5,145,146,154,155,93,94,
90,5,82,79,0,75,43,0,51,0,
0,54,46,0,0,0,0,0,0,121,
5,5,0,0,0,129,131,133,0,0,
0,139,5,76,80,64,0,0,47,0,
0,113,119,0,~2,~2,126,0,0,0,
0,135,136,137,0,142,52,53,256,0,
117,115,123,0,0,81,143,144,5,257,
0,0,0,150,151,0,0,0,5,5,
0,5,5,5,0,0,0,152,153,26,
22,23,24,25,124,125,149,0,27
}
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


operation yyreduce[ yym:integer, yypvt: integer] ->
        [yyreducevalue: integer, yyval:YYSTYPE]
        %
        %   3 is magic default value to return
        %   indicating that the production was OK
        %
        yyreducevalue <- 3

        if yym =   1 then 
% #line 146 "em_ecomp.y" 
 yyval <- comp.create[env$ln - 1, env$fileName, nil, nil, yyv[yypvt-1]] env.done[yyval] 

	elseif yym =  2 then 
% #line 150 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  3 then 
% #line 152 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  4 then 
% #line 154 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  5 then 
% #line 157 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  6 then 
% #line 161 "em_ecomp.y" 
 yyval <- xexport.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  7 then 
% #line 164 "em_ecomp.y" 
 yyval <- xexport.create[env$ln, yyv[yypvt-0], nil] 

	elseif yym =  8 then 
% #line 167 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  9 then 
% #line 168 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  10 then 
% #line 172 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  11 then 
% #line 175 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  12 then 
% #line 179 "em_ecomp.y" 
 const a : ATLit <- atlit.create[env$ln, env$fileName, yyv[yypvt-4], yyv[yypvt-2] ]
		  env.checkNames[yyv[yypvt-4], yyv[yypvt-0]]
		  yyval <- a
		  if yyv[yypvt-3] !== nil then
		    a.setBuiltinID[yyv[yypvt-3]]
		  end if 

	elseif yym =  13 then 
% #line 188 "em_ecomp.y" 
 env.checkNames[yyv[yypvt-3], yyv[yypvt-0]]
	      yyval <- recordlit.create[env$ln, env$fileName, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  14 then 
% #line 193 "em_ecomp.y" 
 yyval <- seq.create[env$ln] yyval.rappend[yyv[yypvt-0]] 

	elseif yym =  15 then 
% #line 195 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rappend[yyv[yypvt-0]] 

	elseif yym =  16 then 
% #line 199 "em_ecomp.y" 

		const s <- env.distribute[vardecl, yyv[yypvt-1], yyv[yypvt-0], nil]
		if yyv[yypvt-3] !== nil then
		  if s$isseq then
		    const limit <- s.upperbound
		    for i : Integer <- s.lowerbound while i <= limit by i<-i+1
		      const x <- s[i]
% If doing move/visit
		      const y <- view x as Attachable
		      y$isAttached <- TRUE
		    end for
		  else
% If doing move/visit
		    const y <- view s as Attachable
		    y$isAttached <- TRUE
		  end if
		end if
		yyval <- s
	      

	elseif yym =  17 then 
% #line 221 "em_ecomp.y" 

		  env.checkNames[yyv[yypvt-3], yyv[yypvt-0]]
		  yyval <- enumlit.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]]
		

	elseif yym =  18 then 
% #line 228 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  19 then 
% #line 230 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  20 then 
% #line 234 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  21 then 
% #line 236 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  22 then 
% #line 240 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  23 then 
% #line 242 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  24 then 
% #line 244 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  25 then 
% #line 246 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  26 then 
% #line 250 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  27 then 
% #line 252 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  28 then 
% #line 256 "em_ecomp.y" 
 yyval <- seq.create[env$ln] 

	elseif yym =  29 then 
% #line 258 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] newid.reset 

	elseif yym =  30 then 
% #line 262 "em_ecomp.y" 
 const x : OpSig <- opsig.create[env$ln, (view yyv[yypvt-3] as hasIdent)$id, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]]
		  x$isFunction <- true
		  yyval <- x
		

	elseif yym =  31 then 
% #line 268 "em_ecomp.y" 
 yyval <- opsig.create[env$ln, (view yyv[yypvt-3] as hasIdent)$id, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  32 then 

	elseif yym =  33 then 

	elseif yym =  34 then 
% #line 275 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  35 then 
% #line 277 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  36 then 
% #line 279 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  37 then 
% #line 283 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  38 then 
% #line 285 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  39 then 

	elseif yym =  40 then 

	elseif yym =  41 then 

	elseif yym =  42 then 

	elseif yym =  43 then 
% #line 297 "em_ecomp.y" 

		  const p : Param <- param.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]]
% If doing move/visit
%		  p$isMove <- yyv[yypvt-4] !== nil
		  if yyv[yypvt-3] !== nil then p$isAttached <- true end if
		  yyval <- p
		

	elseif yym =  44 then 
% #line 305 "em_ecomp.y" 

  		  const id <- newid.newid
		  const asym : Sym <- sym.create[env$ln, id]
		  const p : Param <- param.create[env$ln, asym, yyv[yypvt-0]]
% If doing move/visit
%		  p$isMove <- yyv[yypvt-2] !== nil
		  if yyv[yypvt-1] !== nil then p$isAttached <- true end if
		  yyval <- p
		

	elseif yym =  45 then 
% #line 316 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  46 then 
% #line 318 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  47 then 
% #line 320 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  48 then 
% #line 323 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  49 then 
% #line 325 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  50 then 
% #line 329 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  51 then 
% #line 331 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  52 then 
% #line 335 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-2], 1, yyv[yypvt-0]] 

	elseif yym =  53 then 
% #line 337 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-2], 2, yyv[yypvt-0]] 

	elseif yym =  54 then 
% #line 339 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-0], 3, nil] 

	elseif yym =  55 then 
% #line 342 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  56 then 
% #line 344 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  57 then 
% #line 348 "em_ecomp.y" 
 const x : Oblit <- oblit.create[env$ln, env$fileName, yyv[yypvt-5], yyv[yypvt-3], yyv[yypvt-2]]
		  env.checkNames[yyv[yypvt-5], yyv[yypvt-0]]
		  if yyv[yypvt-4] !== nil then
		    x.setBuiltinID[yyv[yypvt-4]]
		  end if 
		  yyval <- x 

	elseif yym =  58 then 
% #line 357 "em_ecomp.y" 
 const x : Oblit <- oblit.create[env$ln,env$fileName, yyv[yypvt-6], yyv[yypvt-3], yyv[yypvt-2]]

		  % solve the setq problem.  Each of the symbols in the
		  % parameter clause needs to be turned into a setq with an 
		  % undefined outer.  Hmmmm.....
		  % Nope.  We need another thing for explicit parameters,
		  % cause they need types.

		  x$xparam <- yyv[yypvt-4]

		  x$generateOnlyCT <- true
		  env.checkNames[yyv[yypvt-6], yyv[yypvt-0]]
		  if yyv[yypvt-5] !== nil then
		    x.setBuiltinID[yyv[yypvt-5]]
		  end if 
		  yyval <- x 

	elseif yym =  59 then 
% #line 376 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  60 then 
% #line 378 "em_ecomp.y" 
 if yyv[yypvt-2] == nil then yyval <- seq.pair[seq.singleton[yyv[yypvt-0]], seq.create[env$ln]] else yyval <- yyv[yypvt-2] yyval[0].rcons[yyv[yypvt-0]] end if 

	elseif yym =  61 then 
% #line 381 "em_ecomp.y" 
 if yyv[yypvt-2] == nil then yyval <- seq.pair[seq.create[env$ln], seq.singleton[yyv[yypvt-0]]] else yyval <- yyv[yypvt-2] yyval[1].rcons[yyv[yypvt-0]] end if 

	elseif yym =  62 then 
% #line 384 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  63 then 
% #line 386 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  64 then 
% #line 390 "em_ecomp.y" 
 
		  env.checkNames[yyv[yypvt-8], yyv[yypvt-0]]
		  const c <- xclass.create[env$ln, env$fileName, yyv[yypvt-8], yyv[yypvt-7], yyv[yypvt-6], yyv[yypvt-4], yyv[yypvt-3], yyv[yypvt-2]]
		  if yyv[yypvt-5] !== nil then c.setbuiltinid[yyv[yypvt-5]] end if
		  yyval <- c
		

	elseif yym =  65 then 
% #line 399 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  66 then 
% #line 401 "em_ecomp.y" 
 if yyv[yypvt-1] == nil then yyval <- sseq.singleton[yyv[yypvt-0]] else yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] end if 

	elseif yym =  67 then 
% #line 405 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  68 then 
% #line 406 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  69 then 
% #line 410 "em_ecomp.y" 

		if yyv[yypvt-1] !== nil then
		  const s : Tree <- yyv[yypvt-0]
		  if s$isseq then
		    const limit <- s.upperbound
		    for i : Integer <- s.lowerbound while i <= limit by i <- i+1
		      const x : Tree <- s[i]
% If doing move/visit
		      const t <- view x as Attachable
		      t$isattached <- true
		    end for
		  else
% If doing move/visit
		    const t <- view s as Attachable
		    t$isAttached <- true
		  end if
		end if
		yyval <- yyv[yypvt-0]
	      

	elseif yym =  70 then 
% #line 431 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  71 then 
% #line 432 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  72 then 
% #line 433 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  73 then 
% #line 434 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  74 then 

	elseif yym =  75 then 
% #line 441 "em_ecomp.y" 
 yyval <- fielddecl.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  76 then 
% #line 443 "em_ecomp.y" 
 const f : FieldDecl <- fielddecl.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]]
		  f$isConst <- true
		  yyval <- f 

	elseif yym =  77 then 
% #line 449 "em_ecomp.y" 
 yyval <- constdecl.create[env$ln, yyv[yypvt-3], yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  78 then 
% #line 453 "em_ecomp.y" 
 yyval <- extdecl.create[env$ln, yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  79 then 
% #line 456 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  80 then 
% #line 458 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  81 then 
% #line 462 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  82 then 
% #line 466 "em_ecomp.y" 
 yyval <- env.distribute[vardecl, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  83 then 
% #line 470 "em_ecomp.y" 
 yyval <- seq.create[env$ln]
		  yyval.rcons[nil] yyval.rcons[nil] yyval.rcons[nil] 

	elseif yym =  84 then 
% #line 473 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  85 then 
% #line 475 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 
		  if yyval.getElement[0] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one initially definition is allowed", nil]
		  else
		    yyval.setElement[0, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  86 then 
% #line 483 "em_ecomp.y" 
 yyval <- yyv[yypvt-1]
		  if yyval.getElement[1] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one recovery definition is allowed", nil]
		  else
		    yyval.setElement[1, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  87 then 
% #line 491 "em_ecomp.y" 
 yyval <- yyv[yypvt-1]
		  if yyval.getElement[2] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one process definition is allowed", nil]
		  else
		    yyval.setElement[2, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  88 then 
% #line 501 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  89 then 
% #line 503 "em_ecomp.y" 
 (view yyv[yypvt-0] as OpDef)$isExported <- true yyval <- yyv[yypvt-0] 

	elseif yym =  90 then 
% #line 507 "em_ecomp.y" 
 const sig <- view yyv[yypvt-3] as OpSig
		  env.checkNamesByID[sig$name, (view yyv[yypvt-0] as hasIdent)$id]
		  sig.isInDefinition
		  yyval <- opdef.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  91 then 
% #line 514 "em_ecomp.y" 
 yyval <- block.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  92 then 
% #line 518 "em_ecomp.y" 
 yyval <- initdef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  93 then 
% #line 522 "em_ecomp.y" 
 yyval <- recoverydef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  94 then 
% #line 526 "em_ecomp.y" 
 yyval <- processdef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  95 then 
% #line 530 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  96 then 
% #line 532 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  97 then 
% #line 534 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  98 then 
% #line 537 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  99 then 
% #line 538 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  100 then 
% #line 539 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  101 then 
% #line 540 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  102 then 
% #line 541 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  103 then 
% #line 542 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  104 then 
% #line 543 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  105 then 
% #line 544 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  106 then 
% #line 545 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  107 then 
% #line 546 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  108 then 
% #line 547 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  109 then 
% #line 548 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  110 then 
% #line 549 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  111 then 

	elseif yym =  112 then 
% #line 553 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  113 then 
% #line 555 "em_ecomp.y" 
 yyval <- vardecl.create[env$ln, yyv[yypvt-1], sym.create[env$ln, env$itable.Lookup["any", 999]], nil] 

	elseif yym =  114 then 
% #line 558 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  115 then 
% #line 560 "em_ecomp.y" 
 yyval <- xunavail.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  116 then 
% #line 563 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  117 then 
% #line 565 "em_ecomp.y" 
 yyval <- xfailure.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  118 then 
% #line 569 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  119 then 
% #line 571 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  120 then 
% #line 575 "em_ecomp.y" 
 yyval <- ifclause.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  121 then 
% #line 578 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  122 then 
% #line 580 "em_ecomp.y" 
 yyval <- elseclause.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  123 then 
% #line 584 "em_ecomp.y" 
 yyval <- ifstat.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  124 then 
% #line 588 "em_ecomp.y" 
 const inv : Invoc <- invoc.create[env$ln, yyv[yypvt-6], opname.literal["!"], nil]
		  const ex : ExitStat <- exitstat.create[env$ln, inv]
		  var s : Tree <- sseq.create[env$ln]
		  var l : Tree
		  s.rcons[ex]
		  s.rcons[block.create[env$ln, yyv[yypvt-2], nil, nil]]
		  s.rcons[yyv[yypvt-4]]
		  l <- loopstat.create[env$ln, s]
		  s <- sseq.create[env$ln]
		  s.rcons[yyv[yypvt-8]]
		  s.rcons[l]
		  yyval <- block.create[env$ln, s, nil, nil] 

	elseif yym =  125 then 
% #line 601 "em_ecomp.y" 
 const inv : Invoc <- invoc.create[env$ln, yyv[yypvt-5], opname.literal["!"], nil]
		  const ex : ExitStat <- exitstat.create[env$ln, inv]
		  var s : Tree <- sseq.create[env$ln]
		  var l : Tree
		  s.rcons[ex]
		  s.rcons[block.create[env$ln, yyv[yypvt-2], nil, nil]]
		  s.rcons[yyv[yypvt-3]]
		  l <- loopstat.create[env$ln, s]
		  s <- sseq.create[env$ln]
		  s.rcons[vardecl.create[env$ln, yyv[yypvt-9], yyv[yypvt-8], yyv[yypvt-7]]]
		  s.rcons[l]
		  yyval <- block.create[env$ln, s, nil, nil] 

	elseif yym =  126 then 
% #line 616 "em_ecomp.y" 
 yyval <- loopstat.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  127 then 
% #line 620 "em_ecomp.y" 
 yyval <- exitstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  128 then 
% #line 623 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  129 then 
% #line 625 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  130 then 
% #line 629 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  131 then 
% #line 631 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  132 then 
% #line 635 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  133 then 
% #line 637 "em_ecomp.y" 
 yyval <- assignstat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  134 then 
% #line 641 "em_ecomp.y" 
 yyval <- assertstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  135 then 
% #line 645 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["move"]] 

	elseif yym =  136 then 
% #line 647 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["fix"]] 

	elseif yym =  137 then 
% #line 649 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["refix"]] 

	elseif yym =  138 then 
% #line 651 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-0], nil, opname.literal["unfix"]] 

	elseif yym =  139 then 
% #line 655 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  140 then 
% #line 659 "em_ecomp.y" 
 yyval <- returnstat.create[env$ln] 

	elseif yym =  141 then 
% #line 663 "em_ecomp.y" 
 yyval <- returnandfailstat.create[env$ln] 

	elseif yym =  142 then 
% #line 666 "em_ecomp.y" 
 yyval <- seq.create[env$ln] 

	elseif yym =  143 then 
% #line 668 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  144 then 
% #line 670 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  145 then 
% #line 673 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  146 then 
% #line 674 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  147 then 
% #line 677 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  148 then 
% #line 678 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  149 then 
% #line 682 "em_ecomp.y" 
 yyval <- primstat.create[env$ln, yyv[yypvt-9], yyv[yypvt-8], yyv[yypvt-7], yyv[yypvt-5], yyv[yypvt-1]] 

	elseif yym =  150 then 
% #line 685 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  151 then 
% #line 686 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  152 then 
% #line 689 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  153 then 
% #line 690 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  154 then 
% #line 694 "em_ecomp.y" 
 yyval <- waitstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  155 then 
% #line 698 "em_ecomp.y" 
 yyval <- signalstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  156 then 
% #line 702 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  157 then 
% #line 704 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  158 then 
% #line 707 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  159 then 
% #line 708 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  160 then 
% #line 711 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  161 then 
% #line 713 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  162 then 
% #line 715 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], opname.literal["or"], yyv[yypvt-0]]

	elseif yym =  163 then 
% #line 717 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  164 then 
% #line 719 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], opname.literal["and"], yyv[yypvt-0]]

	elseif yym =  165 then 
% #line 721 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-0], (view yyv[yypvt-1] as hasIdent)$id, nil] 

	elseif yym =  166 then 
% #line 723 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  167 then 
% #line 725 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  168 then 
% #line 727 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  169 then 
% #line 729 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  170 then 
% #line 731 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  171 then 
% #line 733 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  172 then 
% #line 735 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  173 then 
% #line 737 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  174 then 
% #line 739 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  175 then 
% #line 741 "em_ecomp.y" 
 yyval <- xview.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  176 then 
% #line 743 "em_ecomp.y" 
 yyval <- xview.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  177 then 
% #line 745 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  178 then 
% #line 747 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  179 then 
% #line 749 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  180 then 
% #line 751 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  181 then 
% #line 753 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  182 then 
% #line 755 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  183 then 
% #line 757 "em_ecomp.y" 

		  const x : Tree <- yyv[yypvt-0]
		  const s <- nameof x
		  
		  if s = "aliteral" and (view x as Literal)$index = IntegerIndex then
		    const il : Literal <- view x as Literal
		    const old : String <- il$str
		    if old[0] = '-' then
		      il$str <- old[1, old.length - 1]
		    else
		      il$str <- "-" || old
		    end if
		    yyval <- x
		  else
		    yyval <- invoc.create[env$ln, yyv[yypvt-0], (view yyv[yypvt-1] as hasIdent)$id, nil]
		  end if
		

	elseif yym =  184 then 
% #line 775 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln, opname.literal["locate"],yyv[yypvt-0]]

	elseif yym =  185 then 
% #line 777 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln, opname.literal["awaiting"],yyv[yypvt-0]]

	elseif yym =  186 then 
% #line 779 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["codeof"],yyv[yypvt-0]]

	elseif yym =  187 then 
% #line 781 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["nameof"],yyv[yypvt-0]]

	elseif yym =  188 then 
% #line 783 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["typeof"],yyv[yypvt-0]]

	elseif yym =  189 then 
% #line 785 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["syntactictypeof"],yyv[yypvt-0]]

	elseif yym =  190 then 
% #line 787 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["islocal"],yyv[yypvt-0]]

	elseif yym =  191 then 
% #line 789 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["isfixed"],yyv[yypvt-0]]

	elseif yym =  192 then 
% #line 792 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  193 then 
% #line 796 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  194 then 
% #line 798 "em_ecomp.y" 
 yyval <- newExp.create[env$ln, yyv[yypvt-0], nil] 

	elseif yym =  195 then 
% #line 800 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-0] as hasIdent)$id, nil] 

	elseif yym =  196 then 
% #line 802 "em_ecomp.y" 
 yyval <- starinvoc.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], nil] 

	elseif yym =  197 then 
% #line 804 "em_ecomp.y" 
 yyval <- questinvoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-0] as hasIdent)$id, nil] 

	elseif yym =  198 then 
% #line 808 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  199 then 
% #line 810 "em_ecomp.y" 
 yyval <- newExp.create[env$ln, yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  200 then 
% #line 812 "em_ecomp.y" 
 yyval <- subscript.create[env$ln, yyv[yypvt-3], yyv[yypvt-1]] 

	elseif yym =  201 then 
% #line 814 "em_ecomp.y" 
 yyval <- fieldsel.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  202 then 
% #line 816 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-3], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  203 then 
% #line 818 "em_ecomp.y" 
 yyval <- starinvoc.create[env$ln, yyv[yypvt-3], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  204 then 
% #line 820 "em_ecomp.y" 
 yyval <- questinvoc.create[env$ln, yyv[yypvt-3], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  205 then 
% #line 824 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  206 then 
% #line 825 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  207 then 
% #line 827 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  208 then 
% #line 830 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  209 then 
% #line 831 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  210 then 
% #line 832 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  211 then 
% #line 835 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  212 then 
% #line 839 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  213 then 
% #line 842 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  214 then 
% #line 843 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  215 then 
% #line 844 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  216 then 
% #line 845 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  217 then 
% #line 846 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  218 then 
% #line 847 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  219 then 
% #line 848 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  220 then 
% #line 849 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  221 then 
% #line 850 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  222 then 
% #line 851 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  223 then 
% #line 852 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  224 then 
% #line 853 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  225 then 
% #line 854 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  226 then 
% #line 855 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  227 then 
% #line 856 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  228 then 
% #line 859 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  229 then 
% #line 860 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  230 then 
% #line 861 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  231 then 
% #line 864 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  232 then 
% #line 865 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  233 then 
% #line 866 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  234 then 
% #line 867 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  235 then 
% #line 871 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  236 then 
% #line 873 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  237 then 
% #line 877 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  238 then 
% #line 879 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  239 then 
% #line 883 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  240 then 
% #line 885 "em_ecomp.y" 
 const t <- arg.create[env$ln, yyv[yypvt-0]]
% If doing move/visit
%		  t$ismove <- true
		  yyval <- t 

	elseif yym =  241 then 
% #line 890 "em_ecomp.y" 
 const t : Arg <- arg.create[env$ln, yyv[yypvt-0]]
% If doing move/visit
%		  t$isvisit <- true
		  yyval <- t 

	elseif yym =  242 then 
% #line 896 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  243 then 
% #line 897 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  244 then 
% #line 898 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  245 then 
% #line 899 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  246 then 
% #line 901 "em_ecomp.y" 
 const t <- Literal.BooleanL[env$ln, true] 
		  yyval <- t 

	elseif yym =  247 then 
% #line 904 "em_ecomp.y" 
 const t <- Literal.BooleanL[env$ln, false]
		  yyval <- t 

	elseif yym =  248 then 
% #line 907 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  249 then 
% #line 909 "em_ecomp.y" 
 yyval <- Literal.NilL[env$ln] 

	elseif yym =  250 then 
% #line 910 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  251 then 
% #line 911 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  252 then 
% #line 915 "em_ecomp.y" 
 yyval <- vectorlit.create[env$ln, yyv[yypvt-1], yyv[yypvt-2], nil] 

	elseif yym =  253 then 
% #line 918 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  254 then 
% #line 919 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  255 then 
% #line 920 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  256 then 
% #line 923 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  257 then 
% #line 925 "em_ecomp.y" 
 const x <- yyv[yypvt-0]
		  const y <- view x as OTree
		  y$isImmutable <- true
		  yyval <- yyv[yypvt-0] 

	elseif yym =  258 then 
% #line 932 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  259 then 
% #line 934 "em_ecomp.y" 
 const x <- yyv[yypvt-0]
		  const y <- view x as OTree
		  y$isImmutable <- true
		  yyval <- yyv[yypvt-0] 

	elseif yym =  260 then 
% #line 939 "em_ecomp.y" 
 
		  const y <- view yyv[yypvt-0] as Monitorable
		  if nameof yyv[yypvt-0] = "anatlit" then
		    env.SemanticError[yyv[yypvt-0]$ln, "Monitored typeobjects don't make sense", nil]
		  end if
		  y$isMonitored <- true
		  yyval <- yyv[yypvt-0] 
		

	elseif yym =  261 then 
% #line 949 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  262 then 
% #line 950 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  263 then 
% #line 951 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  264 then 
% #line 952 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  265 then 
% #line 953 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  266 then 
% #line 954 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  267 then 
% #line 958 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  268 then 
% #line 962 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] end if

end yyreduce
end aYYparser
end create
end parsercreator
