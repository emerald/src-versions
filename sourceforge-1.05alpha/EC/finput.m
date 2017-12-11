export FormattedInput, InThingFromString

const InThing <- typeobject InThing
  op unGetChar[Character]
  op getChar -> [Character]
  function eos -> [Boolean]
end InThing

const InThingFromString <- class InThingFromString[theString : String]
  const length : Integer <- theString.length
  var pos : Integer <- 0
  
  export operation getChar -> [c : Character]
    if pos >= length then
      returnAndFail
    else
      c <- theString[pos]
      pos <- pos + 1
    end if
  end getChar
  
  export function unGetChar [c : Character]
    assert pos > 0
    pos <- pos - 1
    assert c = theString[pos]
  end unGetChar

  export function eos -> [r : Boolean]
    r <- pos >= length
  end eos
end InThingFromString

const voa <- Vector.of[Any]

const FormattedInput <- class FormattedInput[InThing]
  const BUFSIZE <- 128
  const buffer <- VectorofChar.create[BUFSIZE]
  const lowerdigits <- "0123456789abcdef"
  const upperdigits <- "0123456789ABCDEF"
  var digits : String <- lowerdigits
  var inC : Character

  export operation getChar -> [c : Character]
    c <- myThing.getChar
  end getChar

  operation skipString [s : String] -> [r : Boolean]
    const len <- s.length
    for i : Integer <- 0 while i < len by i <- i + 1
      exit when inC != s[i]
      inC <- myThing.getChar
    end loop
    r <- i = len
  end skipString

  function countPercent [format : String] -> [howMany : Integer]
    howMany <- 0
    const len <- format.length
    var wasPercent : Boolean <- false
    for i : Integer <- 0 while i < len by i <- i + 1
      const c <- format[i]
      if wasPercent then
	if c = '*' then
	  % no assignment, cancel the percent
	elseif c = '%' then
	  % a literal percent
	else
	  howMany <- howMany + 1
	end if
	wasPercent <- false
      else
	wasPercent <- c = '%'
      end if
    end for
  end countPercent

  export operation scanf [ format : String ] -> [ v : voa ]
    var i : Integer
    var c : Character
    var formatindex : Integer <- 0
    var formatlen : Integer <- format.length
    var width, maxwidth : Integer
    var valueindex : Integer <- 0
    var suppressCreate : Boolean
    
    const values <- voa.create[self.countPercent[format]]
    var value : Any

    loop
      exit when formatindex >= formatlen
      c <- format[formatindex]
      if c = '%' then
	formatindex <- formatindex + 1
	if formatindex >= formatlen then returnAndFail end if
	% the format of a conversion is:
	%  a % character
	%  an optional creation suppression character (*)
	%  an optional integer maximum width
	%  an option 'l' or 'h' for C compatibility
	%  a required formatting character
	%    { d, o, x, i, e, f, g, s, S, c, '[' }

	c <- format[formatindex]
	if c = '*' then
	  suppressCreate <- true
	  formatindex <- formatindex + 1
	  if formatindex >= formatlen then returnAndFail end if
	  c <- format[formatindex]
	else
	  suppressCreate <- false
	end if

	% look for a maximum field width
	if c >= '0' and c <= '9' then
	  maxwidth <- 0
	  loop
	    maxwidth <- 10 * maxwidth + c.ord - '0'.ord
	    formatindex <- formatindex + 1
	    if formatindex >= formatlen then returnAndFail end if
	    c <- format[formatindex]
	    exit when c < '0' or c > '9'
	  end loop
	else
	  maxwidth <- 0x7fffffff
	end if

	% ignore the 'l' or 'h' if present
	if c = 'l' or c = 'h' then
	  formatindex <- formatindex + 1
	  if formatindex >= formatlen then returnAndFail end if
	  c <- format[formatindex]
	end if

	if c = 'd' or c = 'u' or c = 'o' or c = 'x' or c = 'X' or c = 'i' or
	   c = 's' or c = 'S' or c = 'f' or c = 'g' or c = 'G' or c = 'F' then
	  loop
	    exit when c != ' ' and c != '\t' and c != '\n'
	    formatindex <- formatindex + 1
	    if formatindex >= formatlen then returnAndFail end if
	    c <- format[formatindex]
	  end loop
	end if
	if c = 'd' or c = 'u' or c = 'o' or c = 'x' or c = 'X' or c = 'i' then
	  % input an integer
	  var n : Integer
	  var prefix : String <- nil
	  var prefix2 : String <- nil
	  var ok : String

	  if c = 'd' or c = 'u' or then
	    prefix <- "-"
	    ok <- "0123456789"
	  elseif c = 'o' then
	    ok <- "01234567"
	  elseif c = 'x' or c = 'X' then
	    ok <- "0123456789abcdefABCDEF"
	  elseif c = 'i' then
	    prefix <- "0x"
	    prefix2 <- "-"
	    ok <- "0123456789abcdefABCDEF"
	  else
	    assert false
	  end if
	  
	      base <- 16
	    end if
	    width <- self.log[n, base]
	    totalwidth <- width
	    if neg then
	      totalwidth <- totalwidth + 1
	      prefix <- "-"
	    elseif alwayssign then
	      totalwidth <- totalwidth + 1
	      prefix <- "+"
	    elseif addblank then
	      totalwidth <- totalwidth + 1
	      prefix <- " "
	    else
	      prefix <- ""
	    end if
	    if alternate then
	      if c = 'x' then
		totalwidth <- totalwidth + 2
		prefix <- "0x"
		digits <- lowerdigits
	      elseif c = 'X' then
		totalwidth <- totalwidth + 2
		prefix <- "0X"
		digits <- upperdigits
	      elseif c = 'o' then
		totalwidth <- totalwidth + 1
		prefix <- "0"
	      end if
	    end if
	    % worry about padding on the left
	    loop
	      exit when leftjustify
	      exit when totalwidth >= minwidth
	      myThing.putChar[pad]
	      minwidth <- minwidth - 1
	    end loop
	    % Input the prefix
	    i <- 0
	    loop
	      exit when i >= prefix.length
	      myThing.putChar[prefix[i]]
	      i <- i + 1
	    end loop
	    % Input the characters of the thing
	    if n = 0 then
	      myThing.putChar['0']
	    else
	      self.doint[n, base]
	    end if
	    % worry about padding on the right
	    loop
	      exit when !leftjustify
	      exit when totalwidth >= minwidth
	      myThing.putChar[' ']
	      minwidth <- minwidth - 1
	    end loop
	  else
	    returnAndFail
	  end if
	elseif c = 'e' or c = 'f' or c = 'g' then
	  % floating point number - die
	  returnAndFail
	elseif c = 's' or c = 'S' then
	  % Input a string
	  var s : String
	  var limit : Integer
	  if value == nil then
	    myThing.putChar['N']
	    myThing.putChar['I']
	    myThing.putChar['L']
	  elseif typeof value *> String.getSignature then
	    s <- view value as String
	    if precision > 0 then
	      limit <- precision
	    else
	      limit <- s.length
	    end if
	    totalwidth <- limit
	    % worry about padding on the left
	    loop
	      exit when leftjustify
	      exit when totalwidth >= minwidth
	      myThing.putChar[' ']
	      minwidth <- minwidth - 1
	    end loop
	    i <- 0
	    loop
	      exit when i >= limit
	      myThing.putChar[s[i]]
	      i <- i + 1
	    end loop
	    % worry about padding on the right
	    loop
	      exit when !leftjustify
	      exit when totalwidth >= minwidth
	      myThing.putChar[' ']
	      minwidth <- minwidth - 1
	    end loop
	  else
	    returnAndFail
	  end if
	elseif c = 'c' then
	  % Input a string
	  var s : Character
	  if value == nil then
	    myThing.putChar['N']
	    myThing.putChar['I']
	    myThing.putChar['L']
	  elseif typeof value *> Character.getSignature then
	    s <- view value as Character
	    myThing.putChar[s]
	  else
	    returnAndFail
	  end if
	else
	  % illegal formatting character
	  returnAndFail
	end if
      elseif myThing.getChar != c then
	returnAndFail
      end if
      formatindex <- formatindex + 1
    end loop
  end printf
end anInputFormatter
end toStream
export operation ToString -> [r : InputFormatter]
const aThing <- InThingFromString.create
r <- self.toStream[aThing]
end ToString
export operation sprintf [ format : String, v : ris ] -> [r : String]
const aThing <- InThingFromString.create
const formatter <- self.toStream[aThing]
formatter.printf[format, v]
r <- aThing.fetch
end sprintf
end FormattedInput
