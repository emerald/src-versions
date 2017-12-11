
const ByteCodeReader <- immutable object ByteCodeReader
  const codes : SITable <- SITable.create[512]
  const initialized <- object init
      field initialized : Boolean <- false
  end init

  export operation Lookup [s : String] -> [r : Character]
    const v : Integer <- codes.Lookup[s]
    if v == nil then
      r <- Character.Literal[255]
    else 
      r <- Character.Literal[v]
    end if
  end Lookup

  operation tryopen [fn : String] -> [infile : InStream]
    infile <- InStream.fromUnix[fn, "r"]
    failure infile <- nil end failure
  end tryopen

  operation tryread [infile : InStream] -> [s : String]
    s <- infile.getString
    failure s <- nil end failure
  end tryread

  export operation read
    const names <- { "lib/bcdef", "lib/jsdef", "lib/ccdef" }
    var s, def, name, value : String
    var infile : InStream
    var root : String
    if initialized$initialized then return end if
    initialized$initialized <- true
    primitive "GETROOTDIR" [root] <- []
    for n : Integer <- 0 while n <= names.upperbound by n <- n + 1
      const inputfilename : String <- root||"/"||names[n]
      infile <- self.tryopen[inputfilename]
      if infile == nil then
	const env : EnvironmentType <- Environment$env
	env.SemanticError[1, "Can't open required file \"%s\"",{inputfilename}]
      else
	loop
	  s <- self.tryread[infile]
	  exit when s == nil
	  const separators <- " \n\r\t"
	  def, s <- s.token[separators]
	  if def !== nil and def = "#define" then
	    name, s <- s.token[separators]
	    value, s <- s.token[separators]
	    codes.Insert[name, Integer.literal[value]]
	  end if
	end loop
	infile.close
      end if
    end for
  end read
end ByteCodeReader

const Patch <- record Patch
  var loc  : Integer
  var size : Integer
end Patch

const aop <- Array.of[Patch]

const LabelRec <- class LabelRec
    field value : Integer <- ~1
    field refs : aop
end LabelRec

const HandlerRecord <- class HandlerRecord[xcode : Tree, xstart: Integer]
  field code : Tree <- xcode
  field startAddress : Integer <- xstart
  field endAddress   : Integer
  field codeAddress  : Integer
  field name : Integer <- 0
  field varOffset : Integer <- -1
end HandlerRecord

const aoh <- Array.of[HandlerRecord]
const aolr <- Array.of[LabelRec]

const ByteCode <- class ByteCode [pliterals : aoip]
    field slength : Integer <- 0
    var   ssize   : Integer <- 512
    field s : VectorOfChar <- VectorOfChar.create[ssize]
    const labels <- aolr.create[~16]
    const bc <- BitChunk.create[4]
    const nesting : aoi <- aoi.create[~4]
    field others : aoa
    field usedPrimitive : Boolean <- false
    const field literals : aoip <- pliterals
    const field sizes : aoi <- aoi.create[~8]
    const field expectedATs : aoi <- aoi.create[~8]
    field lnlength : Integer <- 0
    var   lnsize   : Integer <- 64
    var   lnInfo : VectorOfChar <- VectorOfChar.create[lnsize]
    var   lastLineNumber : Integer <- ~1
    var   lastLineNumberAt : Integer <- ~1
    var   handlers : aoh
    var   padChar : Character <- ':'
    const env : EnvironmentType <- Environment$env
    const tracecode : Boolean <- env$tracecode
    const padByteCodes : Boolean <- env$padByteCodes
    const useAbCons : Boolean <- env$useAbCons
    var localSize : Integer <- 0

    export operation setLocalSize [n : Integer]
      localSize <- n
      if n > 0 then
        if n < 255 * 4 then
	  self.addCode["LINKB"]
	  self.addValue[n / 4, 1]
	else
	  self.addCode["LINK"]
	  self.addValue[n, 2]
	end if
      end if
    end setLocalSize

    operation padTo[size : Integer]
      if padByteCodes then
	var padding : Integer
	padding <- size - (slength # size)
	if padding != size and padding != 0 then
	  if slength + padding > ssize then self.grow end if
	  loop
	    s[slength] <- padChar
	    slength <- slength + 1
	    padding <- padding - 1
	    exit when padding = 0
	  end loop
	end if
      end if
    end padTo
	
    operation grow
      const nsize <- ssize * 2
      const ns <- VectorOfChar.create[nsize]
      var i : Integer <- 0
      loop
	ns[i] <- s[i]
	i <- i + 1
	exit when i >= slength
      end loop
      s <- ns
      ssize <- nsize
    end grow

    operation growln
      const nsize <- lnsize * 2
      const nln <- VectorOfChar.create[nsize]
      var i : Integer <- 0
      loop
	nln[i] <- lninfo[i]
	i <- i + 1
	exit when i >= lnlength
      end loop
      lninfo <- nln
      lnsize <- nsize
    end growln

    export operation getLnInfo -> [r : String]
      if lnlength > 0 then
	r <- String.FLiteral[lnInfo, 0, lnlength]
      end if
    end getLnInfo

    operation WriteLn [n : Integer]
      const rem <- n # 10
      const div <- n / 10
      if div > 0 then self.writeLN[div] end if
      if lnlength >= lnsize then self.growln end if
      lnInfo[lnlength] <- Character.Literal[rem + '0'.ord]
      lnlength <- lnlength + 1
    end WriteLn

    operation WriteLnChar [c : Character]
      var i : Integer <- 0
      if lnlength >= lnsize then self.growln end if
      lnInfo[lnlength] <- c
      lnlength <- lnlength + 1
    end WriteLnChar

    % We call this just before generating code for line number ln.  If we
    % have generated code for the previous line (difference > 0) we output
    % ;difference.  If ln > lastLineNumber + 1 then we output +(ln -
    % lastLineNumber).

    export operation LineNumber [ln : Integer]
      if !env$generateDebugInfo then return end if
      if lastLineNumber = ~1 then
	self.writeLNChar['#']
	self.writeLN[ln]
	lastLineNumber <- ln
	lastLineNumberAt <- 0
      elseif ln != lastLineNumber then
	const difference <- slength - lastLineNumberAt
	if difference > 0 then
	  self.WriteLnChar[';']
	  self.writeLN[difference]
	  lastLineNumber <- lastLineNumber + 1
	end if
	if lastLineNumber < ln then
	  self.WriteLnChar['+']
	  self.WriteLn[ln - lastLineNumber]
	  lastLineNumber <- ln
	elseif lastLineNumber > ln then
	  self.WriteLnChar['#']
	  self.WriteLn[ln]
	  lastLineNumber <- ln
	end if
	lastLineNumberAt <- slength
       end if
    end LineNumber

    export function asString -> [r : String]
      r <- "bytecode"
    end asString

    % The next three operations help maintain a stack telling us what
    % size object we want to generate.  An object consists of both
    % some data storing the values of variables referred to by
    % that object and a concrete type object containing the code for
    % the object.  The elements on this stack should be 4's and 8's.
    % If the top element of the stack (accesible through the getSize
    % function below) is 4, then only the data should be generated;
    % otherwise they both should, with the ctype ending up on top of
    % the stack.  

    % After generating what needs to be generated, all code should call
    % bc.finishExpr which will fix up the reference as necessary.

    export operation pushSize [size : Integer]
      sizes.addUpper[size]
    end pushSize

    export operation popSize
      const x : Any <- sizes.removeUpper
    end popSize

    export operation pushExpectedAT [ExpectedAT : Integer]
      expectedATs.addUpper[ExpectedAT]
    end pushExpectedAT

    export operation popExpectedAT
      const x : Any <- expectedATs.removeUpper
    end popExpectedAT

    % Clean up any mismatch between the size and type expected by the
    % environment and what was generated by the produced code.  If the size
    % generated was 4 and the size expected was 8, then push the second
    % thing.  If the size generated was 8 and the size expected was 4 then
    % POOP the second thing.  If the size generated was 8 and the size
    % expected was 8 but the expectedAT doesn't match the generated one,
    % then fix the abcon.
    export operation finishExpr[generatedSize : Integer,
      cty : Integer, aty : Integer]
      const neededSize <- sizes[sizes.upperbound]
      if neededSize = 8 and generatedSize = 4 then
	self.fetchVariableSecondThing[cty, aty]
      elseif neededSize = 4 and generatedSize = 8 then
	self.addCode["POOP"]
      end if
    end finishExpr
      
    export function getSize -> [size : Integer]
      size <- sizes[sizes.upperbound]
    end getSize

    export operation nest [a : Integer]
      nesting.addUpper[a]
    end nest
    
    export operation addOther [a : Any]
      if others == nil then others <- aoa.create[~4] end if
      others.addUpper[a]
    end addOther
    
    export function fetchNest -> [a : Integer]
      if nesting.upperbound > 0 then
	a <- nesting[nesting.upperbound]
      end if
    end fetchNest
    
    export operation unNest 
      const x : Any <- nesting.removeUpper
    end unNest

    % For implementing return 

    export operation nestBase -> [a : Integer]
      if nesting.upperbound >= 0 then
	a <- nesting[0]
      end if
    end nestBase

    % Add an operation to the instruction stream.
    export operation addCode [name : String]
      if tracecode then env.printf["  Code: %s\n", {name}] end if
      if slength >= ssize then self.grow end if
      s[slength] <- ByteCodeReader.Lookup[name]
      if s[slength] = Character.Literal[255] then
	env.Warning[lastLineNumber, "Undefined bytecode \"%s\"", {name}]
      end if
      slength <- slength + 1
    end addCode

    export operation addChar [c : Character]
      if slength >= ssize then self.grow end if
      s[slength] <- c
      slength <- slength + 1
    end addChar

    operation writeat[loc : Integer, val : Integer, size : Integer]
      var l : Integer <- loc
      bc.setunsigned[0, 32, val]
      if size >= 4 then
	s[l] <- Character.Literal[bc.getunsigned[0, 8]]
	l <- l + 1
	s[l] <- Character.Literal[bc.getunsigned[8, 8]]
	l <- l + 1
      end if
      if size >= 2 then
	s[l] <- Character.Literal[bc.getunsigned[16, 8]]
	l <- l + 1
      end if
      s[l] <- Character.Literal[bc.getunsigned[24, 8]]
    end writeat

    operation write [val : Integer, size : Integer]
      if slength + size > ssize then self.grow end if
      self.writeat[slength, val, size]
      slength <- slength + size
    end write

    % Add a literal value to the instruction stream.  The first
    % argument is the value, the second is its length in bytes.
    export operation addValue [val : Integer, size : Integer]
      self.padTo[size]
      self.write[val, size]
    end addValue

    export operation alignTo [size : Integer]
      self.padTo[size]
    end alignTo

    export operation declareLabel -> [r : Integer]
      labels.addUpper[LabelRec.create]
      r <- labels.upperbound
    end declareLabel

    export operation addLabelReference [label : Integer, size : Integer]
      var value, here : Integer
      const x <- labels[label]
      self.padTo[size]
      here <- slength
      if x$value < 0 then
	if x$refs == nil then
	  x$refs <- aop.create[~4]
	end if
	x$refs.addUpper[Patch.create[here, size]]
	value <- 0
      else
	value <- x$value - (here + size)
      end if
      self.write[value, size]
    end addLabelReference
    
    export operation defineLabel[w : Integer]
      const x <- labels[w]
      const r <- x$refs
      x$value <- slength
      
      if r !== nil then		% Backpatch
	for i : Integer <- 0 while i <= r.upperbound by i <- i + 1
	  const p <- r[i]
	  const newval <- x$value - p$loc - p$size
	  self.writeat[p$loc, newval, p$size]
	end for
	x$refs <- nil
      end if
    end defineLabel

%    export function fetchIndex -> [r : Integer]
%      r <- cs.fetchIndex
%    end fetchIndex
%    export operation getIndex [start : Integer, q : CPQueue]
%      cs$s <- String.FLiteral[s, 0, slength]
%      cs.getIndex[start, q]
%    end getIndex
%
%    export operation cpoint [file : OutStream]
%      cs.cpoint[file]
%    end cpoint

  % This is used to put builtins on the stack, as well as their subparts
  % (concrete type, etc.)  Look in builtins.info, ids.m, ../Builtins/*,
  % literal.m for more info on what the numbers mean.
  export operation fetchLiteral [oid : Integer]
    var index : Integer 
    const a <- self$literals

    for i : Integer <- 0 while i <= a.upperbound by i <- i + 1
      if a[i].first = oid and a[i].second = 0 then
	index <- i
	exit
      end if
    end for
    if index == nil then
      a.addUpper[IntPair.create[oid, 0]]
      index <- a.upperbound
      assert index < 256
    end if
    self.addCode["LDLITB"]
    self.addValue[index, 1]
  end fetchLiteral

  % This is used to put either concrete types or abcons on the stack as the
  % second part of a variable.
  export operation fetchVariableSecondThing [ctoid : Integer, atoid : Integer]
    var index : Integer 
    const a <- self$literals
    const limit : Integer <- a.upperbound
    if useAbCons then
      for i : Integer <- 0 while i <= limit by i <- i + 1
	if a[i].first = atoid and a[i].second = 1 and i < limit and
	   a[i+1].first = ctoid and a[i+1].second = 1 then
	  index <- i
	  exit
	end if
      end for
      if index == nil then
	a.addUpper[IntPair.create[atoid, 1]]
	index <- a.upperbound
	a.addUpper[IntPair.create[ctoid, 1]]
	assert index < 256
      end if
    else
      for i : Integer <- 0 while i <= limit by i <- i + 1
	if a[i].first = ctoid and a[i].second = 0 then
	  index <- i
	  exit
	end if
      end for
      if index == nil then
	a.addUpper[IntPair.create[ctoid, 0]]
	index <- a.upperbound
	assert index < 256
      end if
    end if
    self.addCode["LDLITB"]
    self.addValue[index, 1]
  end fetchVariableSecondThing
  
  export operation getString -> [r : String]
    padChar <- '\377' self.padTo[4] padChar <- ':'
    % Deal with failure handlers here
    if handlers !== nil then
      for i : Integer <- handlers.upperbound while i >= handlers.lowerbound by i <- i - 1
	const h <- handlers[i]
	self.addValue[h$startAddress, 2]
	self.addValue[h$endAddress, 2]
	self.addValue[h$codeAddress, 2]
	self.addValue[h$varOffset, 2]
	self.addValue[h$name, 4]
      end for
      self.addValue[handlers.upperbound - handlers.lowerbound + 1, 2]
      self.addChar['h']
      self.addChar['c']
    end if
    r <- String.FLiteral[self$s, 0, self$slength]
  end getString

  export operation beginHandlerBlock[t : Tree] -> [h : HandlerRecord]
    h <- HandlerRecord.create[t, slength]
    if handlers == nil then handlers <- aoh.create[~4] end if
    handlers.addUpper[h]
    handlers.addLower[h]
  end beginHandlerBlock
  
  export operation endHandlerBlock
    const h <- handlers.removeUpper
    h$endAddress <- slength
    const l <- self.declareLabel
    self.addCode["BR"]
    self.addLabelReference[l, 2]
    h$codeAddress <- slength
    h$code.generate[self]
    self.defineLabel[l]
  end endHandlerBlock
  
  initially
    ByteCodeReader.read
    sizes.addUpper[8]
  end initially

end ByteCode

export ByteCode, HandlerRecord
