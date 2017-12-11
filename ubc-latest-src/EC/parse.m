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
	const KACCEPT <- 40
	const KAND <- 41
	const KAS <- 42
	const KASSERT <- 43
	const KAT <- 44
	const KAWAITING <- 45
	const KATTACHED <- 46
	const KBEGIN <- 47
	const KBUILTIN <- 48
	const KBY <- 49
	const KCHECKPOINT <- 50
	const KCLOSURE <- 51
	const KCODEOF <- 52
	const KCLASS <- 53
	const KCONST <- 54
	const KELSE <- 55
	const KELSEIF <- 56
	const KEND <- 57
	const KENUMERATION <- 58
	const KEXIT <- 59
	const KEXPORT <- 60
	const KEXTERNAL <- 61
	const KFAILURE <- 62
	const KFALSE <- 63
	const KFIELD <- 64
	const KFIX <- 65
	const KFOR <- 66
	const KFORALL <- 67
	const KFROM <- 68
	const KFUNCTION <- 69
	const KIF <- 70
	const KIMMUTABLE <- 71
	const KIN <- 72
	const KINITIALLY <- 73
	const KISFIXED <- 74
	const KISLOCAL <- 75
	const KLOCATE <- 76
	const KLOOP <- 77
	const KMONITOR <- 78
	const KMOVE <- 79
	const KNAMEOF <- 80
	const KNEW <- 81
	const KNIL <- 82
	const KOBJECT <- 83
	const KOP <- 84
	const KOPERATION <- 85
	const KOR <- 86
	const KPRIMITIVE <- 87
	const KPROCESS <- 88
	const KRECORD <- 89
	const KRECOVERY <- 90
	const KREFIX <- 91
	const KRESTRICT <- 92
	const KRETURN <- 93
	const KRETURNANDFAIL <- 94
	const KSELF <- 95
	const KSIGNAL <- 96
	const KSUCHTHAT <- 97
	const KSYNTACTICTYPEOF <- 98
	const KTHEN <- 99
	const KTO <- 100
	const KTRUE <- 101
	const KTYPEOBJECT <- 102
	const KTYPEOF <- 103
	const KUNFIX <- 104
	const KUNAVAILABLE <- 105
	const KVAR <- 106
	const KVIEW <- 107
	const KVISIT <- 108
	const KWAIT <- 109
	const KWHEN <- 110
	const KWHILE <- 111
	const KWHERE <- 112
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
  operation newid -> [Integer]
end MYENVT
const env <- view environment as MYENVT

const ERRCODE <- 256
const vi <- vector.of[integer]

const yyexca <- {
~1,1
,0,~1
,~2,0
,~1,238
,311,68
,318,68
,321,68
,363,68
,~2,83
,~1,304
,271,271
,~2,270
,~1,315
,314,116
,319,116
,~2,68
,~1,336
,270,133
,278,133
,~2,135
,~1,448
,314,124
,~2,5
,~1,449
,312,122
,313,122
,314,122
,~2,5
}
const YYNPROD <- 272
const YYLAST <- 2047
const yyact %%2046
 <- {
292,3,9,46,497,321,62,379,221,291,
405,10,365,17,117,146,18,242,4,21,
362,6,259,194,307,313,236,268,243,263,
39,253,12,214,193,148,184,216,147,175,
150,174,415,239,16,241,189,179,58,13,
11,274,176,505,44,19,387,504,277,474,
15,276,116,491,388,499,225,500,501,70,
472,73,25,473,368,74,72,423,420,290,
94,95,96,97,98,99,100,101,102,103,
104,105,119,120,121,122,123,124,111,230,
112,69,488,275,367,486,191,71,113,114,
224,232,296,428,118,245,17,219,245,366,
68,464,503,192,172,196,235,234,125,126,
127,128,129,130,131,132,133,134,135,136,
137,138,139,140,141,142,143,14,170,151,
225,19,68,13,442,382,279,186,187,502,
182,280,171,280,15,485,190,153,484,169,
165,154,156,158,167,157,159,163,166,160,
161,155,168,152,162,212,164,215,217,192,
232,222,93,229,200,203,217,198,199,68,
204,227,204,11,467,235,234,109,106,107,
108,469,8,91,466,238,465,215,264,201,
202,92,208,246,455,453,451,232,248,90,
205,206,190,226,252,220,210,450,447,231,
237,238,235,234,228,445,441,440,444,249,
240,285,443,407,217,223,247,435,217,13,
414,270,288,250,283,257,237,278,256,256,
413,255,255,254,254,412,19,397,401,386,
402,377,374,371,369,215,191,308,308,309,
352,286,315,351,289,287,358,305,12,350,
298,299,311,218,357,302,245,238,363,301,
297,363,310,373,354,355,356,376,306,282,
353,251,336,213,209,185,180,359,360,8,
197,370,237,361,303,7,385,183,173,110,
23,20,115,381,57,396,293,294,295,56,
149,45,42,26,30,406,406,494,383,479,
395,459,337,384,421,378,408,375,403,329,
404,328,327,326,325,324,323,411,322,422,
320,319,192,318,317,380,330,416,426,314,
372,389,390,391,392,393,222,312,398,399,
427,419,400,431,436,406,262,261,260,452,
22,409,336,336,439,437,273,272,430,271,
269,67,195,394,93,284,64,63,446,462,
364,281,244,448,449,410,233,460,264,429,
496,118,66,188,65,91,211,232,463,192,
192,265,89,92,417,418,24,5,2,88,
438,90,235,234,471,1,267,0,266,0,
0,475,192,380,0,480,0,481,10,336,
336,454,482,0,0,456,457,458,0,487,
192,192,495,461,0,498,489,490,0,0,
0,0,336,0,468,0,470,336,210,498,
506,331,93,11,336,47,0,0,0,61,
336,336,477,0,0,0,0,0,50,51,
49,48,87,91,81,83,85,79,84,86,
89,92,0,0,82,80,0,88,0,90,
0,0,349,0,0,338,0,0,191,343,
0,0,0,70,0,73,0,0,0,493,
72,335,0,0,0,53,0,340,334,0,
0,0,332,59,0,0,0,0,0,333,
60,339,0,43,55,69,0,0,0,344,
0,71,0,341,0,347,348,54,346,0,
0,0,0,52,68,331,342,11,0,47,
0,345,0,61,300,0,0,264,0,0,
0,0,50,51,49,48,232,0,0,0,
265,0,0,0,0,0,0,0,0,0,
0,235,234,0,0,267,349,266,0,338,
0,0,191,343,0,0,0,70,0,73,
0,0,0,492,72,335,0,0,0,53,
0,340,334,0,0,0,332,59,0,0,
0,0,0,333,60,339,0,43,55,69,
0,0,0,344,0,71,0,341,0,347,
348,54,346,0,0,0,0,52,68,331,
342,11,0,47,0,345,0,61,258,0,
0,264,0,0,0,0,50,51,49,48,
232,0,0,0,265,0,0,0,0,0,
0,0,0,0,0,235,234,0,0,267,
349,266,0,338,0,0,191,343,0,0,
0,70,0,73,0,0,0,478,72,335,
0,0,0,53,0,340,334,0,0,0,
332,59,0,0,0,0,0,333,60,339,
0,43,55,69,0,0,0,344,0,71,
0,341,0,347,348,54,346,0,0,0,
0,52,68,331,342,11,0,47,0,345,
0,61,0,0,0,0,0,0,0,0,
50,51,49,48,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,349,0,0,338,0,0,
191,343,0,0,0,70,0,73,0,0,
0,425,72,335,0,0,0,53,0,340,
334,0,0,0,332,59,0,0,0,0,
0,333,60,339,0,43,55,69,0,0,
0,344,0,71,0,341,0,347,348,54,
346,0,0,0,0,52,68,331,342,11,
0,47,0,345,0,61,0,0,0,0,
0,0,0,0,50,51,49,48,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,349,0,
0,338,0,0,191,343,0,0,0,70,
0,73,0,0,0,0,72,335,0,0,
0,53,0,340,334,0,0,0,332,59,
0,0,0,0,0,333,60,339,0,43,
55,69,0,0,0,344,0,71,0,341,
0,347,348,54,346,0,0,0,0,52,
68,0,342,316,331,0,11,345,47,0,
0,0,61,0,0,0,0,0,0,0,
0,50,51,49,48,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,349,0,0,338,0,
0,191,343,0,0,0,70,0,73,0,
0,0,0,72,335,0,0,0,53,0,
340,334,0,0,0,332,59,0,0,0,
0,0,333,60,339,0,43,55,69,0,
0,0,344,0,71,0,341,0,347,348,
54,346,0,0,0,0,52,68,0,342,
11,0,47,0,345,207,61,0,0,0,
0,0,0,0,0,50,51,49,48,0,
0,0,0,0,0,0,0,0,0,41,
0,40,27,0,0,0,0,0,0,0,
0,0,0,0,32,0,0,0,0,0,
70,33,73,0,0,0,0,72,0,0,
0,0,53,0,0,0,0,0,0,0,
59,0,0,38,37,31,0,60,177,34,
43,55,69,0,0,0,0,0,71,0,
0,29,0,11,54,47,0,36,0,61,
52,68,35,0,0,0,28,178,50,51,
49,48,0,0,0,0,0,0,0,0,
0,0,41,0,40,27,0,0,0,0,
0,0,0,0,0,0,0,32,0,0,
0,0,0,70,33,73,0,0,0,0,
72,0,0,0,0,53,0,0,0,0,
0,0,0,59,0,0,38,37,31,0,
60,177,34,43,55,69,0,0,0,0,
0,71,0,0,29,0,11,54,47,0,
36,0,61,52,68,35,0,0,0,28,
178,50,51,49,48,0,0,0,0,0,
0,0,0,0,0,41,0,40,27,0,
0,0,0,0,0,0,0,0,0,0,
32,0,0,0,0,0,70,33,73,0,
0,0,0,72,0,0,0,0,53,0,
0,0,0,0,0,0,59,0,0,38,
37,31,0,60,0,34,43,55,69,0,
0,0,0,0,71,0,0,29,0,304,
54,47,0,36,0,61,52,68,35,0,
0,0,28,0,50,51,49,48,0,0,
0,0,0,0,0,0,0,0,41,0,
40,27,0,0,0,0,0,0,0,0,
0,0,0,32,0,0,0,0,0,70,
33,73,0,0,0,0,72,0,0,0,
0,53,0,0,0,0,0,0,0,59,
0,0,38,37,31,0,60,0,34,43,
55,69,0,0,0,0,0,71,0,0,
29,0,11,54,47,0,36,0,61,52,
68,35,0,0,0,28,0,50,51,49,
48,0,0,11,0,47,0,0,0,61,
0,0,0,0,0,0,0,0,50,51,
49,48,0,0,0,0,0,0,0,0,
0,0,70,0,73,0,0,0,0,72,
0,0,0,0,53,0,0,0,0,0,
0,0,59,70,0,73,0,0,0,60,
72,0,43,55,69,53,0,0,0,0,
71,0,0,59,0,0,54,0,0,0,
60,0,52,68,55,69,0,93,0,0,
0,71,0,0,0,0,0,54,0,0,
0,0,0,52,68,77,0,87,91,81,
83,85,79,84,86,89,92,93,0,82,
80,75,88,0,90,0,78,0,0,0,
0,0,0,0,0,77,0,87,91,81,
83,85,79,84,86,89,92,0,0,82,
80,75,88,0,90,93,78,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,76,0,77,0,87,91,81,83,85,
79,84,86,89,92,432,0,82,80,75,
88,0,90,0,78,0,93,0,0,0,
0,76,0,0,0,0,0,0,0,0,
0,0,0,0,77,145,87,91,81,83,
85,79,84,86,89,92,0,0,82,80,
75,88,0,90,0,78,93,0,0,76,
0,0,0,483,0,0,0,0,476,0,
0,0,424,0,77,0,87,91,81,83,
85,79,84,86,89,92,93,0,82,80,
75,88,0,90,0,78,0,0,0,0,
76,0,0,0,77,0,87,91,81,83,
85,79,84,86,89,92,0,0,82,80,
75,88,0,90,93,78,0,0,434,0,
0,0,0,0,0,0,0,0,0,0,
76,0,77,0,87,91,81,83,85,79,
84,86,89,92,0,0,82,80,75,88,
93,90,181,78,0,0,433,0,0,0,
76,0,0,0,0,0,0,0,77,0,
87,91,81,83,85,79,84,86,89,92,
0,93,82,80,75,88,0,90,0,78,
0,0,0,0,0,0,0,0,76,77,
0,87,91,81,83,85,79,84,86,89,
92,0,0,82,80,75,88,93,90,0,
78,144,0,0,0,0,0,0,0,0,
0,0,0,0,76,77,0,87,91,81,
83,85,79,84,86,89,92,0,93,82,
80,75,88,0,90,0,78,0,0,0,
0,0,0,0,0,76,77,0,87,91,
81,83,85,79,84,86,89,92,0,0,
82,80,0,88,0,90,0,78,170,151,
0,0,0,0,0,0,0,0,0,0,
0,76,0,0,0,0,0,153,0,0,
165,154,156,158,0,157,159,163,166,160,
161,155,0,152,162,0,164
}
const yypact %%506
 <- {
~1000,~1000,18,~1000,~1000,~1000,~1000,~55,1,~210,
~1000,~1000,5,~1000,65,~55,62,~1000,~1000,1068,
~1000,~1000,1068,~1000,~1000,1678,~1000,1068,1068,1068,
1068,1068,1068,1068,1068,1068,1068,1068,1068,~59,
~1000,~1000,77,1275,~1000,~1000,~1000,1068,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~239,
~239,1068,~1000,~1000,~1000,~1000,~1000,~1000,1,1,
1,1,1,1,1678,1068,1068,1068,1068,1068,
1068,1068,1068,1068,1068,1068,1068,1068,1068,1068,
1068,1068,1068,1068,253,1642,1388,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~110,1275,~110,80,
975,64,1611,~1000,~1000,5,~1000,67,1678,20,
20,20,~17,1,70,1709,1709,253,253,165,
165,165,165,165,165,165,165,165,~67,~67,
~1000,~1000,~1000,~1000,1068,1068,64,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,64,64,~1000,~68,~1000,1678,1068,1068,~1000,
882,~1000,59,1068,~1000,50,~1000,41,~197,~1000,
~108,~1000,~1000,~204,~1000,41,~1000,~55,1678,1678,
~1000,~1000,~1000,~1000,975,1678,1678,~1000,~70,~1000,
1678,~215,~1000,~1000,~17,~1000,~1000,~1000,~218,~55,
~1000,1,~1000,~1000,~55,1,20,60,~1000,~1000,
~55,~1000,1750,1750,~1000,~1000,414,~1000,~1000,~260,
~17,~1000,~107,~1000,16,~1000,~1000,~120,~1000,~1000,
~1000,~1000,~1000,41,~1000,~1000,~1000,41,~55,~1000,
~1000,~1000,~1000,~1000,~136,~1000,~1000,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~209,1,1,1,310,~1000,
~30,1161,~1000,~1000,~13,~1000,~6,~6,~1000,~1000,
~12,671,~1000,~15,~21,~24,1,~120,5,5,
~55,~1000,25,1678,~1000,~99,~17,~250,~1000,22,
~250,~47,~37,~1000,~1000,~1000,19,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,~1000,
~1000,~1000,1068,~1000,~105,~88,~59,~214,1068,1068,
1068,1068,1068,~1000,~75,1068,1068,~1000,~1000,1068,
~69,~65,~110,5,~25,~25,~1000,~1000,1068,~1000,
~1000,121,~1000,~1000,~250,~1000,17,12,2,~221,
~1000,~1000,~1000,~1000,~1000,~1000,~1000,1,~235,~1000,
1426,567,1254,~216,~1000,~1000,1068,1254,1068,1678,
1358,1575,1537,1678,~57,~108,~1000,~1000,1678,1678,
1678,~1000,~1000,~1000,~25,~1000,~1000,1068,~1000,1678,
~55,~1000,~31,~33,~1000,~1000,~109,~62,~66,~18,
1068,~76,~1000,~1000,~1000,~97,~45,~53,1068,1678,
~59,~46,1068,1068,1068,~1000,~1000,~1000,1678,~1000,
1068,~207,~1000,~103,~148,~1000,~1000,~123,778,778,
~1000,1068,~157,1068,1678,1068,1678,1678,1678,~203,
~1000,1678,~1000,~1000,~160,~1000,~1000,~1000,1507,1068,
1678,463,~1000,~1000,~55,~1000,1254,1467,~155,~98,
~1000,~106,~156,1254,~1000,~176,~1000,~1000,~199,359,
255,~208,~164,~201,~206,~1000,~217,~1000,~1000,~1000,
~1000,~1000,~1000,~1000,~1000,~208,~1000
}
const yypgo %%105
 <- {
0,465,458,0,457,21,2,44,16,456,
52,6,23,36,446,3,444,443,46,43,
8,34,442,4,440,27,31,37,24,20,
436,17,28,432,431,430,12,429,427,33,
26,426,425,22,422,421,25,420,419,417,
416,410,10,409,408,407,406,29,79,15,
9,397,390,389,386,384,383,381,380,5,
378,376,375,374,373,372,371,369,367,365,
7,364,363,362,30,14,361,360,359,357,
354,353,352,54,47,41,351,40,38,35,
350,39,349,344,342,48
}
const yyr1 %%271
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
57,58,54,55,56,60,60,60,64,63,
63,63,63,63,63,63,63,63,63,63,
63,63,63,63,78,78,61,61,62,62,
79,79,80,81,81,65,67,67,67,66,
68,82,82,83,83,69,69,70,71,71,
71,71,72,76,77,86,86,86,87,87,
20,20,73,88,88,89,89,74,75,85,
85,90,90,10,10,10,10,10,10,10,
10,10,10,10,10,10,10,10,10,10,
10,10,10,10,10,10,10,10,10,10,
10,10,10,10,10,91,84,84,84,84,
84,92,92,92,92,92,92,92,93,93,
93,26,26,26,98,97,99,99,99,99,
99,99,99,99,99,99,99,99,99,99,
99,100,100,100,59,59,59,59,94,94,
95,95,101,101,101,96,96,96,96,96,
96,96,96,96,96,103,104,104,104,37,
37,102,102,102,105,105,105,105,105,105,
15,12
}
const yyr2 %%271
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
4,3,4,4,4,1,2,2,2,1,
1,1,1,1,1,1,1,1,1,1,
1,1,1,1,1,3,1,5,1,4,
1,3,3,1,2,5,11,11,7,4,
2,1,2,1,3,1,3,2,4,4,
4,2,3,1,1,1,2,2,1,1,
1,1,11,1,1,1,1,2,2,1,
3,1,1,1,3,3,3,3,2,3,
3,3,3,3,3,3,3,3,4,4,
3,3,3,3,3,3,2,2,2,2,
2,2,2,2,2,1,1,2,3,3,
3,1,3,4,3,4,4,4,1,1,
3,1,1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1,2,3,
1,3,1,2,2,1,1,1,1,1,
1,1,1,1,1,4,1,1,2,1,
2,1,2,2,1,1,1,1,1,1,
1,1
}
const yychk %%506
 <- {
~1000,~1,~2,~3,0,~4,~5,317,311,~6,
~15,258,~12,258,357,270,~7,~3,~8,271,
276,~15,~51,278,~9,~10,~91,290,364,349,
~90,333,302,309,337,360,355,332,331,~84,
289,287,~92,338,~93,~96,~15,260,276,275,
273,274,358,320,352,339,~102,~103,~105,328,
335,264,~11,~38,~41,~16,~22,~45,359,340,
308,346,315,310,~10,293,343,277,298,284,
292,281,291,282,285,283,286,279,294,287,
296,280,288,259,~10,~10,~10,~10,~10,~10,
~10,~10,~10,~10,~10,~10,267,268,269,266,
262,~93,~10,~105,~105,~104,~3,~85,~10,~12,
~12,~12,~12,~12,~12,~10,~10,~10,~10,~10,
~10,~10,~10,~10,~10,~10,~10,~10,~10,~10,
~10,~10,~10,~10,299,357,~59,~98,~99,~100,
~97,259,293,277,281,291,282,285,283,286,
289,290,294,287,296,280,288,284,292,279,
258,~93,~59,258,~95,~101,~10,336,365,~94,
262,261,~7,270,~13,305,~13,~13,~17,~18,
~19,303,~3,~21,~12,~44,~3,260,~10,~10,
~94,~94,~94,263,270,~10,~10,263,~95,265,
~10,~14,~3,273,~39,~3,~27,~3,262,314,
~18,~20,~3,363,314,270,~27,~15,~101,263,
314,~25,326,~30,342,341,~40,~46,~3,~19,
~39,263,~31,~32,~33,336,~15,~21,~15,~12,
~13,261,~15,~26,~97,~98,~99,~26,314,~43,
~54,~55,~56,~57,317,330,347,345,~25,~47,
~5,~48,~49,~50,311,363,321,318,~40,263,
270,~34,303,~8,~42,~3,~27,~27,~15,~57,
~58,~60,~3,~58,~58,~58,321,~21,~12,~12,
314,~32,~12,~10,258,310,~39,~28,~3,295,
~28,314,~61,~46,~63,~3,362,~65,~66,~67,
~68,~69,~70,~71,~72,~73,~74,~75,~76,~77,
~64,256,327,334,323,316,~84,~83,300,336,
322,348,361,304,344,366,353,350,351,297,
314,314,314,~12,~8,~8,~8,~15,271,~5,
~43,~40,~29,~3,~35,~36,369,354,324,262,
~29,330,~62,~3,319,~78,~3,262,~79,~80,
~10,~60,260,~12,~82,~3,367,270,278,~10,
~10,~10,~10,~10,~58,~87,~3,352,~10,~10,
~10,347,345,~59,~8,~52,~3,278,~52,~10,
314,~36,258,258,258,263,~31,~58,~58,~12,
313,~81,~3,312,356,314,~69,~8,329,~10,
~84,~85,357,301,301,314,~20,~52,~10,~15,
278,279,263,314,314,263,~80,314,~60,~60,
334,271,~53,278,~10,270,~10,~10,~10,~86,
~3,~10,~37,~11,328,319,362,327,~10,368,
~10,~60,273,276,262,~11,271,~10,314,~88,
~3,~6,~69,306,323,263,261,~69,278,~60,
~60,262,314,314,~89,~3,~24,~23,~15,273,
275,276,323,323,263,270,~23
}
const yydef %%506
 <- {
5,~2,0,2,1,3,4,0,0,7,
20,270,5,271,0,0,0,8,9,0,
6,21,0,74,10,11,163,0,0,0,
0,0,0,0,0,0,0,0,0,195,
161,162,196,0,201,208,209,0,245,246,
247,248,249,250,251,252,253,254,261,0,
0,5,264,265,266,267,268,269,0,0,
0,0,0,0,77,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,
0,0,0,0,168,0,0,186,187,188,
189,190,191,192,193,194,0,0,0,0,
0,197,0,262,263,5,256,257,159,55,
55,55,5,0,5,164,165,166,167,169,
170,171,172,173,174,175,176,177,180,181,
182,183,184,185,0,0,198,234,235,236,
237,214,216,217,218,219,220,221,222,223,
224,225,226,227,228,229,230,231,232,233,
215,199,200,204,0,240,242,0,0,202,
0,210,0,258,5,0,5,5,5,14,
5,67,68,0,18,5,62,0,178,179,
205,206,207,203,0,243,244,238,0,255,
160,0,28,56,5,65,5,34,40,0,
15,0,150,151,0,0,55,0,241,239,
0,29,0,0,32,33,0,66,~2,0,
5,35,0,37,42,39,13,0,17,19,
5,63,12,5,211,212,213,5,0,84,
85,86,87,88,0,5,5,5,5,69,
70,71,72,73,0,0,0,0,0,36,
40,0,41,16,5,59,5,5,57,89,
0,5,95,0,0,0,0,0,0,0,
0,38,0,44,~2,0,5,5,45,0,
5,0,5,96,97,~2,5,99,100,101,
102,103,104,105,106,107,108,109,110,111,
112,113,0,5,0,5,~2,0,0,0,
0,0,0,5,5,0,0,143,144,0,
0,0,0,0,5,5,78,58,0,60,
61,0,30,48,49,50,0,0,0,40,
31,92,91,118,5,5,114,0,5,120,
0,5,0,0,130,131,0,0,0,137,
0,0,0,141,0,5,148,149,157,158,
98,93,94,90,5,82,79,0,75,43,
0,51,0,0,54,46,0,0,0,0,
0,0,123,5,5,0,0,0,0,132,
134,136,0,0,0,142,5,76,80,64,
0,0,47,0,0,115,121,0,~2,~2,
129,0,0,0,5,0,138,139,140,0,
145,52,53,259,0,119,117,125,0,0,
81,5,146,147,5,260,0,0,0,0,
153,154,0,0,128,0,5,5,0,5,
5,5,0,0,0,155,156,26,22,23,
24,25,126,127,152,0,27
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
% #line 149 "em_ecomp.y" 
 yyval <- comp.create[env$ln - 1, env$fileName, nil, nil, yyv[yypvt-1]] env.done[yyval] 

	elseif yym =  2 then 
% #line 153 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  3 then 
% #line 155 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  4 then 
% #line 157 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  5 then 
% #line 160 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  6 then 
% #line 164 "em_ecomp.y" 
 yyval <- xexport.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  7 then 
% #line 167 "em_ecomp.y" 
 yyval <- xexport.create[env$ln, yyv[yypvt-0], nil] 

	elseif yym =  8 then 
% #line 170 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  9 then 
% #line 171 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  10 then 
% #line 175 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  11 then 
% #line 178 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  12 then 
% #line 182 "em_ecomp.y" 
 const a : ATLit <- atlit.create[env$ln, env$fileName, yyv[yypvt-4], yyv[yypvt-2] ]
		  env.checkNames[yyv[yypvt-4], yyv[yypvt-0]]
		  yyval <- a
		  if yyv[yypvt-3] !== nil then
		    a.setBuiltinID[yyv[yypvt-3]]
		  end if 

	elseif yym =  13 then 
% #line 191 "em_ecomp.y" 
 env.checkNames[yyv[yypvt-3], yyv[yypvt-0]]
	      yyval <- recordlit.create[env$ln, env$fileName, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  14 then 
% #line 196 "em_ecomp.y" 
 yyval <- seq.create[env$ln] yyval.rappend[yyv[yypvt-0]] 

	elseif yym =  15 then 
% #line 198 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rappend[yyv[yypvt-0]] 

	elseif yym =  16 then 
% #line 202 "em_ecomp.y" 

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
% #line 224 "em_ecomp.y" 

		  env.checkNames[yyv[yypvt-3], yyv[yypvt-0]]
		  yyval <- enumlit.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]]
		

	elseif yym =  18 then 
% #line 231 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  19 then 
% #line 233 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  20 then 
% #line 237 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  21 then 
% #line 239 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  22 then 
% #line 243 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  23 then 
% #line 245 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  24 then 
% #line 247 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  25 then 
% #line 249 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  26 then 
% #line 253 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  27 then 
% #line 255 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  28 then 
% #line 259 "em_ecomp.y" 
 yyval <- seq.create[env$ln] 

	elseif yym =  29 then 
% #line 261 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] newid.reset 

	elseif yym =  30 then 
% #line 265 "em_ecomp.y" 
 const x : OpSig <- opsig.create[env$ln, (view yyv[yypvt-3] as hasIdent)$id, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]]
		  x$isFunction <- true
		  yyval <- x
		

	elseif yym =  31 then 
% #line 271 "em_ecomp.y" 
 yyval <- opsig.create[env$ln, (view yyv[yypvt-3] as hasIdent)$id, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  32 then 

	elseif yym =  33 then 

	elseif yym =  34 then 
% #line 278 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  35 then 
% #line 280 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  36 then 
% #line 282 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  37 then 
% #line 286 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  38 then 
% #line 288 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  39 then 

	elseif yym =  40 then 

	elseif yym =  41 then 

	elseif yym =  42 then 

	elseif yym =  43 then 
% #line 300 "em_ecomp.y" 

		  const p : Param <- param.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]]
% If doing move/visit
%		  p$isMove <- yyv[yypvt-4] !== nil
		  if yyv[yypvt-3] !== nil then p$isAttached <- true end if
		  yyval <- p
		

	elseif yym =  44 then 
% #line 308 "em_ecomp.y" 

  		  const id <- newid.newid
		  const asym : Sym <- sym.create[env$ln, id]
		  const p : Param <- param.create[env$ln, asym, yyv[yypvt-0]]
% If doing move/visit
%		  p$isMove <- yyv[yypvt-2] !== nil
		  if yyv[yypvt-1] !== nil then p$isAttached <- true end if
		  yyval <- p
		

	elseif yym =  45 then 
% #line 319 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  46 then 
% #line 321 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  47 then 
% #line 323 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  48 then 
% #line 326 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  49 then 
% #line 328 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  50 then 
% #line 332 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  51 then 
% #line 334 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  52 then 
% #line 338 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-2], 1, yyv[yypvt-0]] 

	elseif yym =  53 then 
% #line 340 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-2], 2, yyv[yypvt-0]] 

	elseif yym =  54 then 
% #line 342 "em_ecomp.y" 
 yyval <- wherewidgit.create[env$ln, yyv[yypvt-0], 3, nil] 

	elseif yym =  55 then 
% #line 345 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  56 then 
% #line 347 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  57 then 
% #line 351 "em_ecomp.y" 
 const x : Oblit <- oblit.create[env$ln, env$fileName, yyv[yypvt-5], yyv[yypvt-3], yyv[yypvt-2]]
		  env.checkNames[yyv[yypvt-5], yyv[yypvt-0]]
		  if yyv[yypvt-4] !== nil then
		    x.setBuiltinID[yyv[yypvt-4]]
		  end if 
		  yyval <- x 

	elseif yym =  58 then 
% #line 360 "em_ecomp.y" 
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
% #line 379 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  60 then 
% #line 381 "em_ecomp.y" 
 if yyv[yypvt-2] == nil then yyval <- seq.pair[seq.singleton[yyv[yypvt-0]], seq.create[env$ln]] else yyval <- yyv[yypvt-2] yyval[0].rcons[yyv[yypvt-0]] end if 

	elseif yym =  61 then 
% #line 384 "em_ecomp.y" 
 if yyv[yypvt-2] == nil then yyval <- seq.pair[seq.create[env$ln], seq.singleton[yyv[yypvt-0]]] else yyval <- yyv[yypvt-2] yyval[1].rcons[yyv[yypvt-0]] end if 

	elseif yym =  62 then 
% #line 387 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  63 then 
% #line 389 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  64 then 
% #line 393 "em_ecomp.y" 
 
		  env.checkNames[yyv[yypvt-8], yyv[yypvt-0]]
		  const c <- xclass.create[env$ln, env$fileName, yyv[yypvt-8], yyv[yypvt-7], yyv[yypvt-6], yyv[yypvt-4], yyv[yypvt-3], yyv[yypvt-2]]
		  if yyv[yypvt-5] !== nil then c.setbuiltinid[yyv[yypvt-5]] end if
		  yyval <- c
		

	elseif yym =  65 then 
% #line 402 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  66 then 
% #line 404 "em_ecomp.y" 
 if yyv[yypvt-1] == nil then yyval <- sseq.singleton[yyv[yypvt-0]] else yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] end if 

	elseif yym =  67 then 
% #line 408 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  68 then 
% #line 409 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  69 then 
% #line 413 "em_ecomp.y" 

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
% #line 434 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  71 then 
% #line 435 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  72 then 
% #line 436 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  73 then 
% #line 437 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  74 then 

	elseif yym =  75 then 
% #line 444 "em_ecomp.y" 
 yyval <- fielddecl.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  76 then 
% #line 446 "em_ecomp.y" 
 const f : FieldDecl <- fielddecl.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]]
		  f$isConst <- true
		  yyval <- f 

	elseif yym =  77 then 
% #line 452 "em_ecomp.y" 
 yyval <- constdecl.create[env$ln, yyv[yypvt-3], yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  78 then 
% #line 456 "em_ecomp.y" 
 yyval <- extdecl.create[env$ln, yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  79 then 
% #line 459 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  80 then 
% #line 461 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  81 then 
% #line 465 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  82 then 
% #line 469 "em_ecomp.y" 
 yyval <- env.distribute[vardecl, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  83 then 
% #line 473 "em_ecomp.y" 
 yyval <- seq.create[env$ln]
		  yyval.rcons[nil] yyval.rcons[nil] yyval.rcons[nil] 

	elseif yym =  84 then 
% #line 476 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  85 then 
% #line 478 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 
		  if yyval.getElement[0] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one initially definition is allowed", nil]
		  else
		    yyval.setElement[0, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  86 then 
% #line 486 "em_ecomp.y" 
 yyval <- yyv[yypvt-1]
		  if yyval.getElement[1] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one recovery definition is allowed", nil]
		  else
		    yyval.setElement[1, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  87 then 
% #line 494 "em_ecomp.y" 
 yyval <- yyv[yypvt-1]
		  if yyval.getElement[2] !== nil then
		    env.SemanticError[yyv[yypvt-0]$ln, "Only one process definition is allowed", nil]
		  else
		    yyval.setElement[2, yyv[yypvt-0]] 
		  end if
		

	elseif yym =  88 then 
% #line 504 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  89 then 
% #line 506 "em_ecomp.y" 
 (view yyv[yypvt-0] as OpDef)$isExported <- true yyval <- yyv[yypvt-0] 

	elseif yym =  90 then 
% #line 510 "em_ecomp.y" 
 const sig <- view yyv[yypvt-3] as OpSig
		  env.checkNamesByID[sig$name, (view yyv[yypvt-0] as hasIdent)$id]
		  sig.isInDefinition
		  yyval <- opdef.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  91 then 
% #line 517 "em_ecomp.y" 
 yyval <- block.create[env$ln, yyv[yypvt-2], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  92 then 
% #line 521 "em_ecomp.y" 
 yyval <- initdef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  93 then 
% #line 525 "em_ecomp.y" 
 yyval <- recoverydef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  94 then 
% #line 529 "em_ecomp.y" 
 yyval <- processdef.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  95 then 
% #line 533 "em_ecomp.y" 
 yyval <- sseq.create[env$ln] 

	elseif yym =  96 then 
% #line 535 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  97 then 
% #line 537 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  98 then 
% #line 540 "em_ecomp.y" 
 yyval <- acceptstat.create[env$ln, yyv[yypvt-0] ] 

	elseif yym =  99 then 
% #line 543 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  100 then 
% #line 544 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  101 then 
% #line 545 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  102 then 
% #line 546 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  103 then 
% #line 547 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  104 then 
% #line 548 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  105 then 
% #line 549 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  106 then 
% #line 550 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  107 then 
% #line 551 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  108 then 
% #line 552 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  109 then 
% #line 553 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  110 then 
% #line 554 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  111 then 
% #line 555 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  112 then 
% #line 556 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  113 then 

	elseif yym =  114 then 
% #line 560 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  115 then 
% #line 562 "em_ecomp.y" 
 yyval <- vardecl.create[env$ln, yyv[yypvt-1], sym.create[env$ln, env$itable.Lookup["any", 999]], nil] 

	elseif yym =  116 then 
% #line 565 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  117 then 
% #line 567 "em_ecomp.y" 
 yyval <- xunavail.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  118 then 
% #line 570 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  119 then 
% #line 572 "em_ecomp.y" 
 yyval <- xfailure.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  120 then 
% #line 576 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  121 then 
% #line 578 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  122 then 
% #line 582 "em_ecomp.y" 
 yyval <- ifclause.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  123 then 
% #line 585 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  124 then 
% #line 587 "em_ecomp.y" 
 yyval <- elseclause.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  125 then 
% #line 591 "em_ecomp.y" 
 yyval <- ifstat.create[env$ln, yyv[yypvt-3], yyv[yypvt-2]] 

	elseif yym =  126 then 
% #line 595 "em_ecomp.y" 
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

	elseif yym =  127 then 
% #line 608 "em_ecomp.y" 
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

	elseif yym =  128 then 
% #line 621 "em_ecomp.y" 
 
		  const id <- env$itable.Lookup["i" || env.newid.asString, 999]
		  const lb <- env$itable.Lookup["lb" || env.newid.asString, 999]
		  const ub <- env$itable.Lookup["ub" || env.newid.asString, 999]
		  const col <- env$itable.Lookup["col" || env.newid.asString, 999]
		  const int <- env$itable.Lookup["integer", 999]

		  const colconst <- constdecl.create[env$ln, sym.create[env$ln, col], nil, yyv[yypvt-3]]
		  const lbconst <- constdecl.create[env$ln, sym.create[env$ln, lb], nil,
											invoc.create[env$ln, sym.create[env$ln, col], opname.literal["lowerbound"], nil]]
		  const ubconst <- constdecl.create[env$ln, sym.create[env$ln, ub], nil,
											invoc.create[env$ln, sym.create[env$ln, col], opname.literal["upperbound"], nil]]
		  const indexvar <- vardecl.create[env$ln, sym.create[env$ln, id], sym.create[env$ln, int], sym.create[env$ln, lb]]
		  
		  const inv : Invoc <- invoc.create[env$ln, sym.create[env$ln, id], opname.literal[">"], seq.singleton[sym.create[env$ln, ub]]]
		  const ex : ExitStat <- exitstat.create[env$ln, inv]
		  var s : Tree <- sseq.create[env$ln]
		  var l : Tree <- sseq.create[env$ln]

		  s.rcons[colconst]
		  s.rcons[lbconst]
		  s.rcons[ubconst]
		  s.rcons[indexvar]

		  l.rcons[ex]
		  l.rcons[constdecl.create[env$ln, yyv[yypvt-5], nil,
								   invoc.create[env$ln, sym.create[env$ln, col], opname.literal["getelement"], seq.singleton[sym.create[env$ln, id]]]]]
		  l.rcons[block.create[env$ln, yyv[yypvt-2], nil, nil]]

		  const inc <- assignstat.create[env$ln, seq.singleton[sym.create[env$ln, id]],
										 seq.singleton[invoc.create[env$ln, sym.create[env$ln, id], opname.literal["+"], seq.singleton[Literal.IntegerL[env$ln, "1"]]]]]
		  l.rcons[inc]
		  l <- loopstat.create[env$ln, l]
		  s.rcons[l]
		  yyval <- block.create[env$ln, s, nil, nil] 

	elseif yym =  129 then 
% #line 659 "em_ecomp.y" 
 yyval <- loopstat.create[env$ln, yyv[yypvt-2]] 

	elseif yym =  130 then 
% #line 663 "em_ecomp.y" 
 yyval <- exitstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  131 then 
% #line 666 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  132 then 
% #line 668 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  133 then 
% #line 672 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  134 then 
% #line 674 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  135 then 
% #line 678 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  136 then 
% #line 680 "em_ecomp.y" 
 yyval <- assignstat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  137 then 
% #line 684 "em_ecomp.y" 
 yyval <- assertstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  138 then 
% #line 688 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["move"]] 

	elseif yym =  139 then 
% #line 690 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["fix"]] 

	elseif yym =  140 then 
% #line 692 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], opname.literal["refix"]] 

	elseif yym =  141 then 
% #line 694 "em_ecomp.y" 
 yyval <- movestat.create[env$ln, yyv[yypvt-0], nil, opname.literal["unfix"]] 

	elseif yym =  142 then 
% #line 698 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  143 then 
% #line 702 "em_ecomp.y" 
 yyval <- returnstat.create[env$ln] 

	elseif yym =  144 then 
% #line 706 "em_ecomp.y" 
 yyval <- returnandfailstat.create[env$ln] 

	elseif yym =  145 then 
% #line 709 "em_ecomp.y" 
 yyval <- seq.create[env$ln] 

	elseif yym =  146 then 
% #line 711 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  147 then 
% #line 713 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  148 then 
% #line 716 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  149 then 
% #line 717 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  150 then 
% #line 720 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  151 then 
% #line 721 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  152 then 
% #line 725 "em_ecomp.y" 
 yyval <- primstat.create[env$ln, yyv[yypvt-9], yyv[yypvt-8], yyv[yypvt-7], yyv[yypvt-5], yyv[yypvt-1]] 

	elseif yym =  153 then 
% #line 728 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  154 then 
% #line 729 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  155 then 
% #line 732 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  156 then 
% #line 733 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  157 then 
% #line 737 "em_ecomp.y" 
 yyval <- waitstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  158 then 
% #line 741 "em_ecomp.y" 
 yyval <- signalstat.create[env$ln, yyv[yypvt-0]] 

	elseif yym =  159 then 
% #line 745 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  160 then 
% #line 747 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  161 then 
% #line 750 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  162 then 
% #line 751 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  163 then 
% #line 754 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  164 then 
% #line 756 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  165 then 
% #line 758 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], opname.literal["or"], yyv[yypvt-0]]

	elseif yym =  166 then 
% #line 760 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  167 then 
% #line 762 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], opname.literal["and"], yyv[yypvt-0]]

	elseif yym =  168 then 
% #line 764 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-0], (view yyv[yypvt-1] as hasIdent)$id, nil] 

	elseif yym =  169 then 
% #line 766 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  170 then 
% #line 768 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  171 then 
% #line 770 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  172 then 
% #line 772 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  173 then 
% #line 774 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  174 then 
% #line 776 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  175 then 
% #line 778 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  176 then 
% #line 780 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  177 then 
% #line 782 "em_ecomp.y" 
 yyval <- exp.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  178 then 
% #line 784 "em_ecomp.y" 
 yyval <- xview.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  179 then 
% #line 786 "em_ecomp.y" 
 yyval <- xview.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  180 then 
% #line 788 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  181 then 
% #line 790 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  182 then 
% #line 792 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  183 then 
% #line 794 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  184 then 
% #line 796 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  185 then 
% #line 798 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-1] as hasIdent)$id, seq.singleton[yyv[yypvt-0]]] 

	elseif yym =  186 then 
% #line 800 "em_ecomp.y" 

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
		

	elseif yym =  187 then 
% #line 818 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln, opname.literal["locate"],yyv[yypvt-0]]

	elseif yym =  188 then 
% #line 820 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln, opname.literal["awaiting"],yyv[yypvt-0]]

	elseif yym =  189 then 
% #line 822 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["codeof"],yyv[yypvt-0]]

	elseif yym =  190 then 
% #line 824 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["nameof"],yyv[yypvt-0]]

	elseif yym =  191 then 
% #line 826 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["typeof"],yyv[yypvt-0]]

	elseif yym =  192 then 
% #line 828 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["syntactictypeof"],yyv[yypvt-0]]

	elseif yym =  193 then 
% #line 830 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["islocal"],yyv[yypvt-0]]

	elseif yym =  194 then 
% #line 832 "em_ecomp.y" 
 yyval <- unaryexp.create[env$ln,opname.literal["isfixed"],yyv[yypvt-0]]

	elseif yym =  195 then 
% #line 835 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  196 then 
% #line 839 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  197 then 
% #line 841 "em_ecomp.y" 
 yyval <- newExp.create[env$ln, yyv[yypvt-0], nil] 

	elseif yym =  198 then 
% #line 843 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-0] as hasIdent)$id, nil] 

	elseif yym =  199 then 
% #line 845 "em_ecomp.y" 
 yyval <- starinvoc.create[env$ln, yyv[yypvt-2], yyv[yypvt-0], nil] 

	elseif yym =  200 then 
% #line 847 "em_ecomp.y" 
 yyval <- questinvoc.create[env$ln, yyv[yypvt-2], (view yyv[yypvt-0] as hasIdent)$id, nil] 

	elseif yym =  201 then 
% #line 851 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  202 then 
% #line 853 "em_ecomp.y" 
 yyval <- newExp.create[env$ln, yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  203 then 
% #line 855 "em_ecomp.y" 
 yyval <- subscript.create[env$ln, yyv[yypvt-3], yyv[yypvt-1]] 

	elseif yym =  204 then 
% #line 857 "em_ecomp.y" 
 yyval <- fieldsel.create[env$ln, yyv[yypvt-2], yyv[yypvt-0]] 

	elseif yym =  205 then 
% #line 859 "em_ecomp.y" 
 yyval <- invoc.create[env$ln, yyv[yypvt-3], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  206 then 
% #line 861 "em_ecomp.y" 
 yyval <- starinvoc.create[env$ln, yyv[yypvt-3], yyv[yypvt-1], yyv[yypvt-0]] 

	elseif yym =  207 then 
% #line 863 "em_ecomp.y" 
 yyval <- questinvoc.create[env$ln, yyv[yypvt-3], (view yyv[yypvt-1] as hasIdent)$id, yyv[yypvt-0]] 

	elseif yym =  208 then 
% #line 867 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  209 then 
% #line 868 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  210 then 
% #line 870 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  211 then 
% #line 873 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  212 then 
% #line 874 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  213 then 
% #line 875 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  214 then 
% #line 878 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  215 then 
% #line 882 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  216 then 
% #line 885 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  217 then 
% #line 886 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  218 then 
% #line 887 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  219 then 
% #line 888 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  220 then 
% #line 889 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  221 then 
% #line 890 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  222 then 
% #line 891 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  223 then 
% #line 892 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  224 then 
% #line 893 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  225 then 
% #line 894 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  226 then 
% #line 895 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  227 then 
% #line 896 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  228 then 
% #line 897 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  229 then 
% #line 898 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  230 then 
% #line 899 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  231 then 
% #line 902 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  232 then 
% #line 903 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  233 then 
% #line 904 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  234 then 
% #line 907 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  235 then 
% #line 908 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  236 then 
% #line 909 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  237 then 
% #line 910 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  238 then 
% #line 914 "em_ecomp.y" 
 yyval <- nil 

	elseif yym =  239 then 
% #line 916 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  240 then 
% #line 920 "em_ecomp.y" 
 yyval <- seq.singleton[yyv[yypvt-0]] 

	elseif yym =  241 then 
% #line 922 "em_ecomp.y" 
 yyval <- yyv[yypvt-2] yyval.rcons[yyv[yypvt-0]] 

	elseif yym =  242 then 
% #line 926 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  243 then 
% #line 928 "em_ecomp.y" 
 const t <- arg.create[env$ln, yyv[yypvt-0]]
% If doing move/visit
%		  t$ismove <- true
		  yyval <- t 

	elseif yym =  244 then 
% #line 933 "em_ecomp.y" 
 const t : Arg <- arg.create[env$ln, yyv[yypvt-0]]
% If doing move/visit
%		  t$isvisit <- true
		  yyval <- t 

	elseif yym =  245 then 
% #line 939 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  246 then 
% #line 940 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  247 then 
% #line 941 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  248 then 
% #line 942 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  249 then 
% #line 944 "em_ecomp.y" 
 const t <- Literal.BooleanL[env$ln, true] 
		  yyval <- t 

	elseif yym =  250 then 
% #line 947 "em_ecomp.y" 
 const t <- Literal.BooleanL[env$ln, false]
		  yyval <- t 

	elseif yym =  251 then 
% #line 950 "em_ecomp.y" 
 yyval <- selflit.create[env$ln] 

	elseif yym =  252 then 
% #line 952 "em_ecomp.y" 
 yyval <- Literal.NilL[env$ln] 

	elseif yym =  253 then 
% #line 953 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  254 then 
% #line 954 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  255 then 
% #line 958 "em_ecomp.y" 
 yyval <- vectorlit.create[env$ln, yyv[yypvt-1], yyv[yypvt-2], nil] 

	elseif yym =  256 then 
% #line 961 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  257 then 
% #line 962 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  258 then 
% #line 963 "em_ecomp.y" 
 yyval <- yyv[yypvt-1] 

	elseif yym =  259 then 
% #line 966 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  260 then 
% #line 968 "em_ecomp.y" 
 const x <- yyv[yypvt-0]
		  const y <- view x as OTree
		  y$isImmutable <- true
		  yyval <- yyv[yypvt-0] 

	elseif yym =  261 then 
% #line 975 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  262 then 
% #line 977 "em_ecomp.y" 
 const x <- yyv[yypvt-0]
		  const y <- view x as OTree
		  y$isImmutable <- true
		  yyval <- yyv[yypvt-0] 

	elseif yym =  263 then 
% #line 982 "em_ecomp.y" 
 
		  const y <- view yyv[yypvt-0] as Monitorable
		  if nameof yyv[yypvt-0] = "anatlit" then
		    env.SemanticError[yyv[yypvt-0]$ln, "Monitored typeobjects don't make sense", nil]
		  end if
		  y$isMonitored <- true
		  yyval <- yyv[yypvt-0] 
		

	elseif yym =  264 then 
% #line 992 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  265 then 
% #line 993 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  266 then 
% #line 994 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  267 then 
% #line 995 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  268 then 
% #line 996 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  269 then 
% #line 997 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  270 then 
% #line 1001 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] 

	elseif yym =  271 then 
% #line 1005 "em_ecomp.y" 
 yyval <- yyv[yypvt-0] end if

end yyreduce
end aYYparser
end create
end parsercreator
