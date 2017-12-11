export Scanner

const yystype <- Tree

const scanner <- immutable object scanner
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
const tokenNameTable <- {
  "end of file",
  "identifier",
  "operator",
  "(",
  ")",
  "[",
  "]",
  "{",
  "}",
  "$",
  ".",
  ".*",
  ".?",
  ",",
  ":",
  ";",
  "integer",
  "real",
  "character",
  "string",
  "&",
  "<-",
  "*>",
  "/",
  "=",
  ">",
  ">=",
  "==",
  "<",
  "<=",
  "-",
  "#",
  "~",
  "!",
  "!=",
  "!==",
  "|",
  "+",
  "->",
  "*",
  "accept",
  "and",
  "as",
  "assert",
  "at",
  "awaiting",
  "attached",
  "begin",
  "builtin",
  "by",
  "checkpoint",
  "closure",
  "codeof",
  "class",
  "const",
  "else",
  "elseif",
  "end",
  "enumeration",
  "exit",
  "export",
  "external",
  "failure",
  "false",
  "field",
  "fix",
  "for",
  "forall",
  "from",
  "function",
  "if",
  "immutable",
  "in",
  "initially",
  "isfixed",
  "islocal",
  "locate",
  "loop",
  "monitor",
  "move",
  "nameof",
  "new",
  "nil",
  "object",
  "op",
  "operation",
  "or",
  "primitive",
  "process",
  "record",
  "recovery",
  "refix",
  "restrict",
  "return",
  "returnandfail",
  "self",
  "signal",
  "suchthat",
  "syntactictypeof",
  "then",
  "to",
  "true",
  "typeobject",
  "typeof",
  "unfix",
  "unavailable",
  "var",
  "view",
  "visit",
  "wait",
  "when",
  "while",
  "where"
}
  const firstKeyword <- OAND
  const lastKeyword  <- KWHERE

  const token <- integer

  const scannerType <- typeobject scannerType
    operation lex -> [Integer, yystype]
    function lineNumber -> [Integer]
    function line -> [String]
    function position -> [Integer]
    operation reset [InputThing]
  end scannerType

  export function getSignature -> [r : Signature]
    r <- scannerType
  end getSignature

  export operation create [xstdin : InputThing, it : IdentTable] -> [r : scannerType]
    r <- object aScanner
	var stdin : InputThing <- xstdin
	var nextLineNumber :    integer <- 0
	var needIncLineNumber : Boolean <- true
	var nextChar : Character <- ' '
	const lineBuffer : InputBuffer <- InputBuffer.create
	const nextTokenBuffer : InputBuffer <- InputBuffer.create
	var nextPosition, currentPosition : Integer
	const EOF <- Character.literal[0]
	var nextToken : Token
	var nextTokenValue : yystype
% ifdef DEBUGSCAN
%	const here <- locate aScanner
%	const out <- here.getStdOut
%
	const CILLEGAL <- 0
	const CLETTER <- 1
	const CCOLON <- 2
	const CLPAREN <- 3
	const CRPAREN <- 4
	const CDIGIT <- 5
	const CDOT <- 6
	const CSTRINGQUOTE <- 7
	const CCHARQUOTE <- 8
	const CCOMMA <- 9
	const CCOMMENT <- 10
	const COPERATOR <- 11
	const CLSQUARE <- 12
	const CRSQUARE <- 13
	const CLCURLY <- 14
	const CRCURLY <- 15
	const CDOLLAR <- 16
	const CEOF <- 17
	const CWHITE <- 18
	const CNL <- 19

	const charClass <- {
CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,
CILLEGAL,CWHITE,CNL,CILLEGAL,CWHITE,CWHITE,CILLEGAL,CILLEGAL,
CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,
CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,CILLEGAL,
CWHITE,COPERATOR,CSTRINGQUOTE,COPERATOR,CDOLLAR,CCOMMENT,COPERATOR,CCHARQUOTE,
CLPAREN,CRPAREN,COPERATOR,COPERATOR,CCOMMA,COPERATOR,CDOT,COPERATOR,
CDIGIT,CDIGIT,CDIGIT,CDIGIT,CDIGIT,CDIGIT,CDIGIT,CDIGIT,
CDIGIT,CDIGIT,CCOLON,CILLEGAL,COPERATOR,COPERATOR,COPERATOR,COPERATOR,
COPERATOR,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLSQUARE,CILLEGAL,CRSQUARE,COPERATOR,CLETTER,
CILLEGAL,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLCURLY,COPERATOR,CRCURLY,COPERATOR,CILLEGAL,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,
CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER,CLETTER
}

	operation readLine
	  nextPosition <- ~1
	  lineBuffer.readString[stdin, EOF]
	end readLine
  
	operation getNextChar
	  var c : Character
	  if needIncLineNumber then
	    nextLineNumber <- nextLineNumber + 1
	    self.readline[]
	  end if
	  nextPosition <- nextPosition + 1
	  c <- lineBuffer[nextPosition]
	  needIncLineNumber <- c == '\n' or c == EOF
	  nextChar <- c
	end getNextChar
      
	operation doAChar -> [r : Character]
	  var num : integer <- 0
	  if nextChar = '\\' then
	    self.getNextChar[]
	    if nextChar = '^' then
	      self.getNextChar[]
	      num <- nextChar.ord # 32
	      self.getNextChar[]
	    elseif '0' <= nextChar and nextChar <= '7' then
	      % a C octal escape
	      num <- nextChar.ord - '0'.ord
	      self.getNextChar[]
	      if '0' <= nextChar and nextChar <= '7' then
		num <- num * 8 + nextChar.ord - '0'.ord
		self.getNextChar[]
		if '0' <= nextChar and nextChar <= '7' then
		  num <- num * 8 + nextChar.ord - '0'.ord
		  self.getNextChar[]
		end if
	      end if
	    else
	      if nextChar == 'n' then
		num <- '\n'.ord
	      elseif nextChar == 'b' then
		num <- '\b'.ord
	      elseif nextChar == 't' then
		num <- '\t'.ord
	      elseif nextChar == 'r' then
		num <- '\r'.ord
	      elseif nextChar == 'f' then
		num <- '\f'.ord
	      else
		num <- nextChar.ord
	      end if
	      self.getNextChar[]
	    end if
	  else
	    num <- nextChar.ord
	    self.getNextChar[]
	  end if
	  r <- Character.literal[num]
	end doAChar

	operation doaccept
	  nextTokenBuffer.reset
	  nextTokenValue <- nil
	  self.scan[]
	end doaccept

	operation scan
	  var cc : Integer
	  loop
	    if nextChar = EOF then
	      nextToken <- 0
	      currentPosition <- 0	      
	      return
	    end if
	    currentPosition <- nextPosition
	    cc <- charClass[nextChar.ord]
      
	    if cc = CILLEGAL then
  %	    IllegalCharacter[nextChar]
	      self.getNextChar[]
	    elseif cc = CLETTER then
	      var id : Ident
	      loop
%ifdef CASESENSITIVITY
%		nextTokenBuffer.collect[nextChar]
%else
		if 'A' <= nextChar and nextChar <= 'Z' then
		  nextTokenBuffer.collect[
		    Character.literal[nextChar.ord - 'A'.ord + 'a'.ord]]
		else
		  nextTokenBuffer.collect[nextChar]
		end if
%endif CASESENSITIVITY
		self.getNextChar[]
		cc <- charClass[nextChar.ord]
		exit when cc != CLETTER and cc != CDIGIT
	      end loop
	      id <- it.Lookup[nextTokenBuffer.asString, 999]
	      if id$value <= lastKeyword then
		nextToken <- id$value
	      else
		nextToken <- TIDENTIFIER
		nextTokenValue <- sym.create[nextLineNumber, id]
	      end if
	      exit
	    elseif cc = COPERATOR then
	      var id : Ident
	      loop
		nextTokenBuffer.collect[nextChar]
		self.getNextChar[]
		cc <- charClass[nextChar.ord]
		exit when cc != COPERATOR
	      end loop
	      id <- it.Lookup[nextTokenBuffer.asString, 999]
	      if id$value <= lastKeyword then
		nextToken <- id$value
	      else
		nextToken <- TOPERATOR
	      end if
	      nextTokenValue <- Sym.create[nextLineNumber, id]
	      exit
	    elseif cc = CWHITE then
	      self.getNextChar[]
	    elseif cc = CCOLON then
	      self.getNextChar[]
	      nextToken <- TCOLON
	      exit
	    elseif cc = CLPAREN then
	      self.getNextChar[]
	      nextToken <- TLPAREN
	      exit
	    elseif cc = CRPAREN then
	      self.getNextChar[]
	      nextToken <- TRPAREN
	      exit
	    elseif cc = CDIGIT then
	      loop
		nextTokenBuffer.collect[nextChar]
		self.getNextChar[]
		cc <- charClass[nextChar.ord]
		exit when cc != CDIGIT and !(nextChar = 'x' or nextChar >= 'a' and nextChar <= 'f' or nextChar >= 'A' and nextChar <= 'F')
	      end loop
	      if nextChar == '.' then
		loop
		  nextTokenBuffer.collect[nextChar]
		  self.getNextChar[]
		  cc <- charClass[nextChar.ord]
		  exit when cc != CDIGIT
		end loop
		nextToken <- TREALLITERAL
		nextTokenvalue <- Literal.RealL[nextLineNumber, nextTokenBuffer.asString]
	      else
		nextToken <- TINTEGERLITERAL
		nextTokenvalue <- Literal.IntegerL[nextLineNumber, nextTokenBuffer.asString]
	      end if
	      exit
	    elseif cc = CDOT then
	      self.getNextChar[]
	      if nextChar == '*' then
		self.getNextChar[]
		nextToken <- TDOTSTAR
	      elseif nextChar == '?' then
		self.getNextChar[]
		nextToken <- TDOTQUESTION
	      else
		nextToken <- TDOT
	      end if
	      exit
	    elseif cc = CCOMMA then
	      self.getNextChar[]
	      nextToken <- TCOMMA
	      exit
	    elseif cc = CLSQUARE then
	      self.getNextChar[]
	      nextToken <- TLSQUARE
	      exit
	    elseif cc = CRSQUARE then
	      self.getNextChar[]
	      nextToken <- TRSQUARE
	      exit
	    elseif cc = CLCURLY then
	      self.getNextChar[]
	      nextToken <- TLCURLY
	      exit
	    elseif cc = CRCURLY then
	      self.getNextChar[]
	      nextToken <- TRCURLY
	      exit
	    elseif cc = CDOLLAR then
	      self.getNextChar[]
	      nextToken <- TDOLLAR
	      exit
	    elseif cc = CCOMMENT then
	      loop
		self.getNextChar[]
		exit when nextChar == '\n' or nextChar == EOF
	      end loop
	    elseif cc = CSTRINGQUOTE then
	      var c : Character
	      self.getNextChar[]
	      loop
		if nextChar == EOF then
  % 		UnexpectedEndOfFile
		  exit
		elseif nextChar == '"' then
		  self.getNextChar[]
		  exit
		end if
		c <- self.doAChar[]
		nextTokenBuffer.collect[c]
	      end loop
	      nextToken <- TSTRINGLITERAL
	      nextTokenValue <- Literal.StringL[nextLineNumber, nextTokenBuffer.asString]
	      exit
	    elseif cc = CCHARQUOTE then
	      var c : Character
	      self.getNextChar[]
	      if nextChar == EOF then
  % 	      UnexpectedEndOfFile
		nextTokenBuffer.collect['a']
	      else
		c <- self.doAChar[]
		nextTokenBuffer.collect[c]
		if nextChar != '\'' then
  %		UnexpectedEndOfCharLiteral
		end if
		self.getNextChar[]
	      end if
	      nextToken <- TCHARACTERLITERAL
	      nextTokenValue <- Literal.CharacterL[nextLineNumber, nextTokenBuffer.asString]
	      exit
	    elseif cc = CEOF then
	      nextToken <- TEOF
	      exit 
	    elseif cc = CNL then
	      self.getNextChar[]
	    end if
	  end loop
	  nextToken <- nextToken + 257
	end scan

	export operation lex -> [thissym : token, yylval : yystype]
	  var d : Integer
	  self.doaccept[]
	  yylval <- nextTokenValue
	  thissym <- nextToken
% #ifdef DEBUGSCAN
% 	  d <- thissym - 257
% 	  out.putstring["Lex returning "]
% 	  out.putint[d, 0]
% 	  out.putstring[" ("]
% 	  if d < tokenNameTable.lowerbound | d > tokenNameTable.upperbound then
% 	    out.putstring["no name"]
% 	  else
% 	    out.putstring[tokenNameTable[d]]
% 	  end if
% 	  out.putstring[") - "]
% 	  if yylval == nil then
% 	    out.putstring["nil"]
% 	  else
% 	    out.putstring[yylval.asString]
% 	  end if
% 	  out.putchar['\n']
% #endif
	end lex

	export function lineNumber -> [r : Integer]
	  r <- nextLineNumber
	end lineNumber
	
	export function line -> [r : String]
	  r <- lineBuffer.asString
	end line
	
	export function position -> [r : Integer]
	  r <- currentPosition
	end position
	
	export operation reset [f : InputThing]
	  stdin <- f
	  nextLineNumber <- 0
	  needIncLineNumber <- true
	  nextChar <- ' '
	  nextTokenBuffer.reset
	  lineBuffer.reset
	end reset

	initially
	  var id : Ident
	  for i : integer <- firstKeyword while i <= lastKeyword by i <- i + 1
	    id <- it.Lookup[tokenNameTable[i], i]
	  end for
	end initially

    end aScanner
  end create
end scanner

