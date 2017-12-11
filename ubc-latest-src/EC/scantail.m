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

