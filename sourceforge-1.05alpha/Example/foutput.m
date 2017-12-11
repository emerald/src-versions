export FormattedOutput, OutThingToString

const OutThing <- typeobject OutThing
  op putChar [Character]
  op Flush
end OutThing

const OutThingToString <- immutable object OutThingToString
  const OTTSType <- typeobject OTTSType
    op putChar [Character]
    op Flush
    op fetch -> [String]
  end OTTSType
  export function getSignature -> [r : Signature]
    r <- OTTSType
  end getSignature
  
  export operation create -> [r : OTTSType]
    r <- object OTFS
	const BUFSIZE <- 128
	const buffer <- VectorofChar.create[BUFSIZE]
	var length : Integer <- 0
	var theString : String <- nil
  
	export operation Flush 
	end Flush

	export operation putChar [c : Character]
	  if length < BUFSIZE then
	    buffer[length] <- c
	    length <- length + 1
	  else
	    if theString == nil then
	      theString <- String.Fliteral[buffer, 0, BUFSIZE]
	    else
	      theString <- theString || String.FLiteral[buffer, 0, BUFSIZE]
	    end if
	    length <- 0
	  end if
	end putChar
  
	export operation fetch -> [r : String]
	  if length > 0 then
	    if theString == nil then
	      r <- String.FLiteral[buffer, 0, length]
	    else
	      r <- theString || String.FLiteral[buffer, 0, length]
	    end if
	    length <- 0
	    theString <- nil
	  else
	    if theString == nil then
	      r <- ""
	    else
	      r <- theString
	    end if
	  end if
	end fetch
    end OTFS
  end create
end OutThingToString

const FormattedOutput <- immutable object FormattedOutput

  const OutputFormatter <- typeobject OutputFormatter
    op putChar [Character]
    op Flush
    operation printf [String, risa]
  end OutputFormatter

  export function getSignature -> [r : Signature]
    r <- OutputFormatter
  end getSignature

  export operation toStream [myThing : OutThing] -> [r : OutputFormatter]
    r <- object anOutputFormatter
	const BUFSIZE <- 128
	const buffer <- VectorofChar.create[BUFSIZE]
	const lowerdigits <- "0123456789abcdef"
	const upperdigits <- "0123456789ABCDEF"
	var digits : String <- lowerdigits

	export operation Flush
	  myThing.Flush
	end Flush

	export operation putChar [c : Character]
	  myThing.putChar[c]
	end putChar
  
	operation doint [n : Integer, base : Integer]
	  const digit <- n # base
	  const rest <- n / base
	  if rest > 0 then
	    self.doint[rest, base]
	  end if
	  myThing.putChar[digits[digit]]
	end doint

	function log [n : Integer, base : Integer] -> [l : Integer]
	  var sofar : Integer <- base
	  var next : Integer
	  l <- 1
	  loop
	    exit when sofar > n
	    l <- l + 1
	    next <- sofar * base
	    exit when next < sofar		% overflow
	    sofar <- next
	  end loop
	end log

	export operation printf [ format : String, v : risa ]
	  var i : Integer
	  var inC : Character
	  var c : Character
	  var formatindex : Integer <- 0
	  var formatlen : Integer <- format.length
	  var width, minwidth, precision, totalwidth : Integer
	  var leftjustify, alwayssign, addblank, alternate  : Boolean
	  var valueupb, valueindex   : Integer
	  var pad : Character
	  var value : Any

	  if v == nil then
	    valueupb <- ~1
	    valueindex <- 0
	  else
	    valueupb <- v.upperbound
	    valueindex <- v.lowerbound
	  end if
	  loop
	    exit when formatindex >= formatlen
	    c <- format[formatindex]
	    if c = '%' then
	      formatindex <- formatindex + 1
	      if formatindex >= formatlen then returnAndFail end if
	      % the format of a conversion is:
	      %  a % character
	      %  0 or more flags (-, #, +, space)
	      %  an optional integer minimum width (or *)
	      %  an optional .
	      %  an optional precision (or *)
	      %  a required formatting character
	      %    { d, o, x, e, f, g, s, c, '[' }
	      leftjustify <- false
	      alwayssign <- false
	      addblank <- false
	      alternate <- false
	      pad <- ' '
	      loop
		c <- format[formatindex]
		if c = '-' then
		  leftjustify <- true
		elseif c = '+' then
		  alwayssign <- true
		elseif c = ' ' then
		  addblank <- true
		elseif c = '#' then
		  alternate <- true
		else
		  exit
		end if
		formatindex <- formatindex + 1
		if formatindex >= formatlen then returnAndFail end if
	      end loop
	      % look for a minimum width
	      if c = '*' then
		formatindex <- formatindex + 1
		if formatindex >= formatlen then returnAndFail end if
		c <- format[formatindex]
		if valueindex > valueupb then
		  returnAndFail
		else
		  value <- v[valueindex]
		  valueindex <- valueindex + 1
		  
		  if value == nil then
		  elseif typeof value *> Integer.getSignature then
		    minwidth <- view value as Integer
		  else
		    returnAndFail
		  end if
		end if
	      elseif c >= '0' and c <= '9' then
		if c = '0' then pad <- '0' end if
		minwidth <- 0
		loop
		  minwidth <- 10 * minwidth + c.ord - '0'.ord
		  formatindex <- formatindex + 1
		  if formatindex >= formatlen then returnAndFail end if
		  c <- format[formatindex]
		  exit when c < '0' or c > '9'
		end loop
	      else
		minwidth <- ~1
	      end if
	      % look for a precision
	      precision <- 0
	      if c = '.' then
		formatindex <- formatindex + 1
		if formatindex >= formatlen then returnAndFail end if
		c <- format[formatindex]
		if c = '*' then
		  formatindex <- formatindex + 1
		  if formatindex >= formatlen then returnAndFail end if
		  c <- format[formatindex]
		  if valueindex > valueupb then
		    returnAndFail
		  else
		    value <- v[valueindex]
		    valueindex <- valueindex + 1
		    if value == nil then
		    elseif typeof value *> Integer.getSignature then
		      precision <- view value as Integer
		    else
		      returnAndFail
		    end if
		  end if
		elseif c >= '0' and c <= '9' then
		  precision <- 0
		  loop
		    precision <- 10 * precision + c.ord - '0'.ord
		    formatindex <- formatindex + 1
		    if formatindex >= formatlen then returnAndFail end if
		    c <- format[formatindex]
		    exit when c < '0' or c > '9'
		  end loop
		else
		  precision <- ~1
		end if
	      end if
	      if c = 'l' then
		formatindex <- formatindex + 1
		if formatindex >= formatlen then returnAndFail end if
		c <- format[formatindex]
	      end if
	      if valueindex > valueupb then
		returnAndFail
	      else
		value <- v[valueindex]
		valueindex <- valueindex + 1
	      end if
	      if c = 'd' or c = 'u' or c = 'o' or c = 'x' or c = 'X' then
		% format an integer.  We don't do unsigned things very well
		var n : Integer
		var neg : Boolean <- false
		var base, d : Integer
		var prefix : String <- ""
		if value == nil then
		  myThing.putChar['N']
		  myThing.putChar['I']
		  myThing.putChar['L']
		elseif typeof value *> Integer.getSignature then
		  n <- view value as Integer
		  if n < 0 then
		    neg <- true
		    n <- ~n
		  end if
		  if c = 'd' or c = 'u' then 
		    base <- 10
		  elseif c = 'o' then
		    base <- 8
		  elseif c = 'x' or c = 'X' then
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
		  % output the prefix
		  i <- 0
		  loop
		    exit when i >= prefix.length
		    myThing.putChar[prefix[i]]
		    i <- i + 1
		  end loop
		  % output the characters of the thing
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
		% output a string
		var s : String
		var limit : Integer
		if c = 'S' and value !== nil then
		  value <- (view value as typeobject t function asString->[String] end t).asString
		end if
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
		% output a string
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
	    else
	      myThing.putChar[c]
	    end if
	    formatindex <- formatindex + 1
	  end loop
	end printf
    end anOutputFormatter
  end toStream
  export operation ToString -> [r : OutputFormatter]
    const aThing <- OutThingToString.create
    r <- self.toStream[aThing]
  end ToString
  export operation sprintf [ format : String, v : risa ] -> [r : String]
    const aThing <- OutThingToString.create
    const formatter <- self.toStream[aThing]
    formatter.printf[format, v]
    r <- aThing.fetch
  end sprintf
end FormattedOutput
