const invoc <- class Invoc (Tree) [xxtarget : Tree, xxopname : Ident, xxargs : Tree]
    const ln : Integer <- xxtarget$ln
    field opNumber : Integer
    field nress : Integer <- 1
    var isNotManifest : Boolean <- false
    field value : Tree <- nil
    field target : Tree <- xxtarget
    field xopname : Ident <- xxopname
    field args  : Tree <- xxargs
    var typeinfo : Tree <- nil
    const VoS <- Vector.of[Symbol]

    export operation getIsNotManifest -> [r : Boolean]
      r <- isNotManifest
    end getIsNotManifest
    export operation setIsNotManifest [r : Boolean]
      isNotManifest <- r
    end setIsNotManifest
    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- target
      elseif i = 1 then
	r <- args
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	target <- r
      elseif i = 1 then
	args <- r
      end if
    end setElement

    export function getnargs -> [r : Integer]
      if args == nil then
	r <- 0
      else
	r <- args.upperbound + 1
      end if
    end getnargs

    export operation copy [i : Integer] -> [newt : Tree]
      var ntarget, nargs : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if args !== nil then nargs <- args.copy[i] end if
      const r <- invoc.create[ln, ntarget, xopname, nargs]
      r$isNotManifest <- isNotManifest
      newt <- r
    end copy
    export operation resolveSymbols [st : SymbolTable, nexp : Integer]
      nress <- nexp
      target.resolveSymbols[st, 1]
      if args !== nil then args.resolveSymbols[st, 1] end if
    end resolveSymbols

  export operation assignTypes
    if self$value !== nil then
      self$value.assignTypes
    else
      FTree.assignTypes[self]
    end if
  end assignTypes

  function isSelf -> [r : Boolean] 
    const t <- nameof self$target

    if t = "aselflit" then
      r <- true
    elseif t = "asym" then
      const ts <- view self$target as Sym
      r <- ts$mySym$isSelf
    else
      r <- false
    end if
  end isSelf

  operation isAlreadySet [s : Symbol, v1 : VoS, v2 : VoS] -> [r : Boolean]
    r <- false
    const limit <- v1.upperbound
    for i : Integer <- 0 while i <= limit by i <- i + 1
      if v1[i] == s then r <- true return end if
      if v2[i] == s then r <- true return end if
    end for
  end isAlreadySet

  export operation typeCheck 
    if typeinfo !== nil then return end if
    var isNone : Boolean <- false
    if self$value !== nil then
      self$value.typeCheck
      return
    end if
    var targetct   : Tree <- self$target.getCT
    var targettype : Tree
    if targetct == nil then
      targettype <- self$target.getAT
      if nameof targettype = "abuiltinlit" then
	const ttbID : Integer <- (view targettype as BuiltinLit)$id
	isNone <- ttbID = 0x1007 or ttbID = 0x1607
	const newtargettype <- (view targettype as hasinstat)$instAT
	if newtargettype !== nil then targettype <- newtargettype end if
      end if
      if nameof targettype = "aglobalref" then
	const ttgID : Integer <- (view targettype as GlobalRef)$id
	isNone <- ttgID = 0x1007 or ttgID = 0x1607
	const newtargettype <- targettype.asType
	if newtargettype !== nil then targettype <- newtargettype end if
      end if
      if targettype !== nil then
	targetct <- (view targetType as hasInstCT)$instCT
      end if
    end if
    var theopsig : OpSig
    const env <- Environment$env
    const opst <- xopname$name

    if targetCT !== nil and nameof targetCT = "aglobalref" then
      const codeoid <- (view targetCT as GlobalRef)$codeoid
      if codeoid !== nil then
	const newr <- ObjectTable.Lookup[codeoid]
	if newr !== nil then targetCT <- newr end if
      end if
    end if
    if targetct !== nil and nameof targetct = "anoblit" then
      const tob <- view targetct as Oblit
      isNone <- tob$codeOID = 0x1807
      var theopdef : OpDef
      theopdef, opNumber <- tob.findOp[xopname, self.isSelf, self$nargs, 0]
      opNumber <- -opNumber
      if theopdef !== nil then
	theopsig <- view theopdef$sig as OpSig
      end if
      if env$tracetypeCheck then
	env.printf["invoc.check of \"%s\" on %d, got sig from ct,self? %s\n",
	  { opst, ln, self.isSelf.asString }]
      end if
      if isNone then
	% No problem, the target has type None, so has all operations
	typeinfo <- self.fakeResultTypes
	return
      end if
    elseif targettype !== nil and nameof targettype = "anatlit" then
      const targetat <- view targettype as ATLit
      isNone <- targetat$id = 0x1607
      targetat.assignTypes
      theopsig, opNumber <- targetat.findOp[xopname, self$nargs, 0] 
      if env$tracetypeCheck then
	env.printf["invoc.check of \"%s\" on %d, got sig from at\n",
	  { opst, ln}]
      end if
      if isNone then
	% No problem, the target has type None, so has all operations
	typeinfo <- self.fakeResultTypes
	return
      end if
    elseif isNone then
      % No problem, the target has type None, so has all operations
      typeinfo <- self.fakeResultTypes
      return
    else
      % Can't find a type
      FTree.typecheck[self]
      return
    end if
    if theopsig == nil then
      env.SemanticError[ln, "Operation %s[%d] is not defined",
	{ opst, self$nargs }]
      typeinfo <- self.fakeResultTypes
      return
    end if
    if theopsig$mustBeCompilerExecuted then
      env.SemanticError[ln, "Operation \"%s[%d]\" must be manifest, but isn't",
	{ opst, self$nargs }]
      typeinfo <- self.fakeResultTypes
      return
    end if
    const opsignress <- theopsig$nress
    const opsignargs <- theopsig$nargs

    var limit : Integer
    var opsigargs : Tree <- theopsig$params
    
    if opsignargs != self$nargs then
      env.SemanticError[ln,
	"Number of arguments %d incorrect, \"%s\" expects %d",
	{ self$nargs, opst, opsignargs }]
    end if
%   if opsignress != self$nress then
%     env.SemanticError[self$ln,
%	"Number of results %d incorrect, \"%s\" returns %d",
%	{ self$nress, opst, opsignress }]
%   end if

    % This +10 should be +opsig.wheres.length

    const oldvalues <- VoT.create[self$nargs+10]
    const oldtypes  <- VoT.create[self$nargs+10]
    const parxs <- VoT.create[self$nargs+10]
    const valuesyms <- VoS.create[self$nargs+10]
    const typesyms  <- VoS.create[self$nargs+10]
    const theParams  <- (view theopsig as OpSig)$params
    const theResults <- (view theopsig as OpSig)$results
    var redoassignment : Boolean <- false


    if env$tracetypecheck then
      env.printf["Before typechecking\n", nil]
      theopsig.print[env$stdout, 0]
    end if
    limit <- self$nargs
    if limit > opsignargs then limit <- opsignargs end if
    for i : Integer <- 1 while i <= limit by i <- i + 1
      const thisarg <- self$args[i-1]
      const actualtype <- view thisarg.getAT as hasconforms
      const thisparx <- opsigargs[i-1]
      const formaltype <- thisparx.asType
      if redoassignment then
	parxs[i] <- thisparx
	thisparx.assignTypes
      end if
      if nameof thisparx = "aparam" then
	const thispar <- view thisparx as Param
	const thisparsym : Symbol <- (view thispar$xsym as Sym)$mysym
	if thisparsym$isTypeVariable then
	  var thisvalue : Tree
	  if !thisarg$isNotManifest then
	    thisvalue <- thisarg.execute.asType
	  end if
	  if thisvalue == nil then
	    env.SemanticError[ln,
	      "Parameter %d to %S[%d] must be manifest", 
	      { i, xopname, self$nargs}]
	  elseif !self.isAlreadySet[thisparsym, valuesyms, typesyms] then
	    % We actually have a value here, change the value of the param
	    % First check for a constraint
	    assert thisparsym$value !== nil
	    if !(view thisvalue as hasConforms).ConformsTo[ln, view thisparsym$value as ATLit] then
	      env.SemanticError[ln, 
		"Actual #%d to \"%S[%d]\" does not match constraint on formal",
		{ i, xopname, self$nargs }]
	    end if
	    if env$tracetypecheck then
	      env.printf["Setting %S's (%d) value to %S\n", 
		{ thisparsym$myident, Environment.getPtr[thisparsym], thisvalue }]
	    end if
	    valuesyms[i-1] <- thisparsym
	    oldvalues[i-1] <- view thisparsym$value as Tree
	    thisparsym$value <- thisvalue
	    redoassignment <- true
	  end if
	end if
	if nameof thispar$xtype = "asym" then
	  const thispartypesym <- (view thispar$xtype as sym)$mysym
	  if thispartypesym$isTypeVariable and !self.isAlreadySet[thispartypesym, valuesyms, typesyms] then
	    assert thispartypesym$value !== nil
	    if !actualType.ConformsTo[ln, view thispartypesym$value as ATLit] then
	      env.SemanticError[ln, 
		"Actual type #%d to \"%S[%d]\" does not match constraint on formal",
		{ i, xopname, self$nargs }]
	    end if
	    if env$tracetypecheck then
	      env.printf["Setting %S's (%d) types value to %S\n", 
		{ thispartypesym$myident, Environment.getPtr[thispartypesym],
		  actualType }]
	    end if
	    typesyms[i-1] <- thispartypesym
	    oldtypes[i-1] <- view thispartypesym$value as Tree
	    thispartypesym$value <- view actualType as Tree
	    redoassignment <- true
	  end if
	end if
      end if
      if actualtype == nil then
	env.ttypeCheck["invoc.typecheck of \"%s\" on %d, actual %d type is nil\n", 
	  { opst, ln, i} ]
      elseif formaltype == nil then
	env.ttypeCheck["invoc.typecheck of \"%s\" on %d, formal %d type is nil\n", 
	  { opst, ln, i } ]
      elseif !actualType.conformsTo[ln, formalType] then
	env.SemanticError[ln, 
	  "Actual #%d to \"%s\" does not conform to formal",
	  { i, opst}]
      end if
    end for
    if theResults == nil then
      if nress = 0 then
	typeinfo <- Seq.create[ln]
	FTree.typeCheck[self]
      else
	env.SemanticError[ln, "Invocation %S[%d] returns 0 results, %d are expected", { xopname, self$nargs, nress} ]
	typeinfo <- self.fakeResultTypes
      end if
    elseif nress != theResults.upperbound + 1 then
      env.SemanticError[ln, "Invocation %S[%d] returns %d results, %d are expected", { xopname, self$nargs, theResults.upperbound + 1, nress } ]
      typeinfo <- self.fakeResultTypes
    else
      if redoassignment then
	const thewheres <- (view theopsig as OpSig)$xwhere
	if thewheres !== nil then
	  const st <- (view theopsig as OpSig)$st
	  const newst <- SymbolTable.create[(view theopsig as OpSig)$st,CBlock]
	  const todo <- seq.create[thewheres$ln]
	  var xx : Any
	  for i : Integer <- 0 while i <= thewheres.upperbound by i <- i + 1
	    const awhere  <- view thewheres[i] as Wherewidgit
	    const aop     <- awhere$xop

	    if aop = OP_WHERE then
	      % This is a declaration, and I need to do it
	      const awsymdef<- awhere$xsym
	      const awsym   <- (view awsymdef as Sym)$mysym
	      valuesyms[self$nargs + i] <- awsym
	      oldvalues[self$nargs + i] <- view awsym$value as Tree
	      const tcopy   <- awhere$xtype.copy[0]
	      todo.rcons[tcopy]
	      awsym$value <- tcopy
	    end if
	  end for
	  xx <- todo.removeSugar[nil]
	  todo.defineSymbols[newst]
	  todo.resolveSymbols[newst, 1]
	  loop
	    exit when !todo.findManifests
	  end loop
	  todo.evaluateManifests
	end if
      end if
      var theType : Tree
      if nress != 1 then typeinfo <- Seq.create[ln] end if
      for i : Integer <- 0 while i <= theResults.upperbound by i <- i + 1
	if redoassignment then
	  parxs[self$nargs + i] <- theResults[i]
	  theResults[i].assignTypes
	end if
	theType <- theResults[i].asType
	if nameof theType = "abuiltinlit" then
	  theType <- (view theType as hasInstAT).getInstAT
	end if
	if env$traceassignTypes then
	  env.printf["invoc.getAT:  answer is %s\n", {theType.asString}]
	end if
	if nress = 1 then
	  typeinfo <- theType
	else
	  typeinfo.rcons[theType]
	end if
      end for
      FTree.typeCheck[self]
      if redoassignment then
	% That same old + 10
	for i : Integer <- limit + 10 - 1 while i >= 0 by i <- i - 1
	  if valuesyms[i] !== nil then
	    if env$tracetypecheck then
	      env.printf["Setting %S's (%d) value back to %S\n", 
		{ valueSyms[i]$myident, Environment.getPtr[valueSyms[i]], oldvalues[i] }]
	    end if
	    valueSyms[i]$value <- oldvalues[i]
	  end if
	  if typesyms[i] !== nil then
	    if env$tracetypecheck then
	      env.printf["Setting type %S's (%d) value back to %S\n", 
		{ typeSyms[i]$myident, Environment.getPtr[typeSyms[i]], oldtypes[i] }]
	    end if
	    typeSyms[i]$value <- oldtypes[i]
	  end if
%	  if parxs[i] !== nil then
%	    parxs[i].assignTypes
%	  end if
	end for
	theopsig.assignTypes
      end if
    end if
    if env$tracetypecheck then
      env.printf["After all typechecking is done\n", nil]
      theopsig.print[env$stdout, 0]
    end if
  end typeCheck

  export operation findThingsToGenerate [q : Any]
    if self$value !== nil then
      self$value.findThingsToGenerate[q]
    else
      FTree.findThingsToGenerate[q, self]
    end if
  end findThingsToGenerate

  export function count [x : Tree] -> [r : Integer]
    if x == nil then
      r <- 0
    else
      r <- x.upperbound + 1
    end if
  end count

  export operation tryInline[ct : Tree, xct : Printable] -> [r : Boolean]
    const bc <- view xct as ByteCode
    const ob <- view ct as oblit
    var def : OpDef
    var stat : Tree
    var sig : OpSig
    const hasGenerateLValue <- typeobject hasGenerateLValue
      operation generateLValue[Printable]
    end hasGenerateLValue
    var lv : hasGenerateLValue
    var first : String
    var instSize : Integer <- 0
    var generatedSize : Integer <- 4
    var nResults : Integer <- 0
    var isPrim : Boolean
    var index : Integer
    const env <- Environment$env

    r <- false
    if env$traceinline then
      env.printf["Trying an inline of %s on %s\n",
	{self$xopname.asString, ob$name.asString}]
    end if
    def, index <- ob.findOp[self$xopname, self.isSelf, self$nargs, self$nress]
    if def == nil or !def$isInlineable then return end if
    
    sig <- view def$sig as OpSig
    if sig$results !== nil then
      nResults <- 1
    end if
    
    isprim, stat <- def.findStatement
    assert stat !== nil 

    if isprim then
      const prims <- view stat as PrimStat
      const number <- prims$number
      const extravals <- self.count[prims$vals] - self.count[self$args]
      var lt : Integer
      % Check that if there is 1 result that it is also the left of the
      % primstat  
  
      % Check that there are the same number of args as vals
      if extravals < 0 then
	env.tinline["  Less prim vals than args\n", nil]
	return
      end if

      % We assume that the order of arguments to the primitive statement is
      % local instance vars followed by arguments in the same order as the
      % arguments

      % Check that the args are in the same order as the prim vals
      
      instSize <- ob$instanceSize  
  
      if prims$xvar !== nil then
	% all things are assumed vars
	generatedSize <- 8
      end if
      bc.pushSize[generatedSize]	
  
      if prims$xself !== nil then
        self$target.generate[bc]
      end if
  
      % Generate the local variables
      for i : Integer <- 0 while i < extravals by i <- i + 1
	const val <- view prims$vals[i] as Sym
	const valsym <- val$mysym
	const offset : Integer <- valsym$offset
	var lgeneratedSize : Integer
	if valsym$isNotManifest then
	  % Generate the target
	  bc.pushSize[4]
	  self$target.generate[bc]
	  bc.popSize

	  if bc$size = 4 or valsym$size = 4 then
	    bc.addCode["LDINDS"]
	    lgeneratedSize <- 4
	  else
	    bc.addCode["LDVINDS"]
	    lgeneratedSize <- 8
	  end if
	  if offset == nil or offset == 0 then
	    % Use 4
	    bc.addValue[4, 2]
	  else
	    bc.addValue[valsym$offset, 2]
	  end if
	  bc.finishExpr[lgeneratedsize, val$codeOID, val$atOID]
	else
	  (view valsym$value as Tree).generate[bc]
	end if
      end for
      
      if instSize == ~8 and number !== nil then
	first <- (view number[0] as hasStr)$str
	if first = "SET" then
	  assert prims$vals.upperbound = 1
	  assert self$args.upperbound = 1
	  self$args[0].generate[bc]
	  bc.pushSize[8]
	  self$args[1].generate[bc]
	  bc.popSize
	else
	  if self$args !== nil then self$args.generate[bc] end if
	end if
      else
	if self$args !== nil then self$args.generate[bc] end if
      end if
	
      if number !== nil then
	const limit : Integer <- number.upperbound
	for i : Integer <- number.lowerbound while i <= limit by i <- i + 1
	  const v <- view number[i] as hasStr
	  const s : String <- v$str
	  if s[0] >= '0' and s[0] <= '9' then
	    const primno <- Integer.Literal[s]
	    bc.addValue[primno, 1]
	  else
	    if s = "SET" and instSize = ~8 then
	      bc.addCode["SETV"]
	    elseif s = "GET" and instSize = ~8 then
	      bc.addCode["GETV"]
	      generatedSize <- 8
	    else
	      bc.addCode[s]
	      if s = "LDIS" then
		bc.alignTo[2]
	      end if
	    end if
	  end if
  
	end for
      end if
      bc.popSize
      if nResults > 0 then
	% Worry about if the context needs a different size
	if bc$size = 4 then
	  bc.finishExpr[generatedSize, 0, 0]
	elseif bc$size = 8 and generatedSize = 4 then
	  const thetype <- sig$results[0][1].asType
	  const t <- (view thetype as hasInstCT)$instCT
	  const u <- view t as hasIDs
	  if t == nil then
	    Environment$env.printf["inlined invoc botch, thetype = %s, theopname = %s, thetarget = %s\n", {thetype.asString, xopname$name, ob.asString}]
	    Environment$env.printf["  the type id = %#x instSize = %d\n", 
	      {(view thetype as hasID)$id, instSize}]
	    Environment$env.printf["  the type.isVector = %s\n", 
	      {(view thetype as ATLit)$isVector.asString}]
	    Environment$env.printf["  the type.name = %s\n", 
	      {(view thetype as ATLit)$name.asString}]
	    bc.finishExpr[generatedSize, 0x80000000, 0x1601]
	  else
	    bc.finishExpr[generatedSize, u$codeOID, (view thetype as hasID)$id]
	  end if
	end if
      end if
    else 			% assignstatement
      const asss <- view stat as AssignStat
      var right : Tree
      var rname : String
      var rsy : Symbol
      var rsym: Sym

      if env$traceinline then
	env.printf["  Found an assignment statement\n", nil]
      end if

      % Check that if there is 1 result that it is also the left of the
      % assignstat
  
      assert nResults = 1

      right <- asss$right[0]
      rname <- nameof right
      if rname = "aliteral" and (view right as Literal)$index = IntegerIndex then
	right.generate[bc]
      elseif rname = "asym" then
	rsym<- view right as Sym
	rsy <- rsym$mysym
	if !rsy$isNotManifest then
	  (view rsy$value as Tree).generate[bc]
	else
	  if self.isself then
	    % Since the target is me, I can just use the right hand side
	    rsym.generate[bc]
	  else
	    % Generate the target
	    bc.pushSize[4]
	    self$target.generate[bc]
	    bc.popSize
  
	    if bc$size = 4 or rsy$size = 4 then
	      generatedSize <- 4
	      bc.addCode["LDINDS"]
	    else
	      generatedSize <- 8
	      bc.addCode["LDVINDS"]
	    end if
	    bc.addValue[rsy$offset, 2]
	    bc.finishExpr[generatedSize, rsym$codeOID, (view rsy$ATinfo as hasID)$id]
	  end if
	end if
      end if
    end if
    r <- true
  end tryInline

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    if self$value !== nil then
      const gs <- typeobject gs
	operation generateSelf[Printable]
      end gs
      const vgs <- view self$value as gs
      vgs.generateSelf[xct]
    else
      var targetType, targetCT : Tree
      const env <- Environment$env
      bc.lineNumber[ln]
      if env$traceinline then
	env.printf["invoc.inline: %s target is %s\n",
	  {xopname$name, self$target.asString}]
      end if
      targetCT <- self$target$ct
      if targetCT == nil then
	targetType <- self$target.getat
	if targetType !== nil then
	  if env$traceinline then
	    env.printf["targetType is %s\n", {targetType.asString}]
	  end if
	  targetCT <- (view targetType as hasInstCT)$instCT
	end if
      end if
      if targetCT !== nil and nameof targetCT = "aglobalref" then
	const codeoid <- (view targetCT as GlobalRef)$codeoid
	if codeoid !== nil then
	  const newr <- ObjectTable.Lookup[codeoid]
	  if newr !== nil then targetCT <- newr end if
	end if
      end if
	
      if env$traceinline then
	if targetCT == nil then
	  env.printf["targetCT is nil\n", nil]
	else
	  env.printf["targetCT is %s\n", {targetCT.asString}]
	end if
      end if
      if targetCT !== nil and
	 nameof targetCT = "anoblit" and
	 ((view targetCT as ObLit)$isImmutable or
	  ! env$generateconcurrent) 
      then
	if self.tryInline[targetCT, xct] then return end if
      end if

      % Push nil objects (in the 8-byte format) onto the stack in the
      % slots where return values should eventually go.
      for i : Integer <- 0 while i < self$nress by i <- i + 1
	bc.addCode["PUSHNILV"]
      end for
      % Push the arguments on the stack.
      bc.pushSize[8]
      if self$args !== nil then 
	self$args.generate[xct]
      end if
      % Generate the object whose operation we are about to invoke.
      self$target.generate[xct]
      bc.popSize
      % Invoke it.
      if targetCT !== nil and nameof targetCT = "anoblit" then
	if opNumber == nil or opNumber >= 0 then
	  var theOpDef : Any
	  const tob <- view targetCT as ObLit
	  theopdef, opNumber <- tob.findOp[xopname, self.isSelf, self$nargs, 0]
	  %	
	  % We have to take special care of nil.  If we are explicitly 
	  % invoking nil, then we will know the CT.  Nil has every operation, 
	  % but doesn't really implement them all, so we have to special case
	  % it 'cause we won't find the operation.
	  if tob$codeoid = 0x1807 then
	    assert opNumber == nil
	    opNumber <- 0
	  else
	    opNumber <- -opNumber
	  end if
	end if
	opNumber <- -opNumber
	assert opNumber <= 255
	bc.addCode["CALLCTB"]
	bc.addValue[opnumber, 1]
      elseif Environment$env$useAbCons then
	assert opNumber >= 0
	if opNumber <= 255 then
	  bc.addCode["CALLB"]
	  bc.addValue[opNumber, 1]
	else
	  assert opNumber <= 65535
	  bc.addCode["CALLS"]
	  bc.addValue[opNumber, 2]
	end if
      else
	var name : String <- xopname$name
	if self$args == nil then 
	  name <- name || "@0"
	else
	  name <- name || "@" || (self$args.upperbound + 1).asString
	end if
	name <- name || "@" || self$nress.asString
	const opoid <- opnametooid.Lookup[name]
	if opoid <= 32767 then
	  bc.addCode["CALLOIDS"]
	  bc.addValue[opoid, 2]
	else
	  bc.addCode["CALLOID"]
	  bc.addValue[opoid, 4]
	end if
      end if
      % The call should return its result(s) in the 8-byte format; this
      % changes it to the 4-byte format if necessary.
      % In addition, if we are using ab/cons, then we need to generate code
      % to correct the ab in the ab/cons that left for us by the called
      % procedure.  Where do we find the abs?
      % The third argument needs to be the at that we have generated.
      if self$nress = 1 then
        bc.finishExpr[8, 0, 0]
      end if
    end if
  end generate

  operation findObject [t : Tree] -> [s : String, result : Oblit]
    var r : Tree
    s <- nameof t
    r <- view t as Tree
    loop
      exit when s != "asym"
      r <- view (view r as Sym)$mysym$value as Tree
      if r == nil then
	s <- "totaljunk"
      else
	s <- nameof r
      end if
    end loop
    result <- view r as ObLit
  end findObject

  export operation findManifests -> [changed : Boolean]
    const env <- Environment$env

    changed <- false
    if ! self$isNotManifest then
      var makeNotManifest : Boolean <- false
      if self$target$isNotManifest then
	makeNotManifest <- true
      else
	if self$args !== nil then
	  for i : Integer <- 0 while i <= self$args.upperbound by i <- i + 1
	      const arg <- args[i]
	    if arg$isNotManifest or nameof arg = "aliteral" then
	      makeNotManifest <- true
	    end if
	  end for
	end if
	if !makeNotManifest then
	  var thing : Oblit
	  var s : String
	  s, thing <- self.findObject[self$target]
  
	  if env$traceevaluatemanifests then
	    env.printf["invoc on line %d, s = %s\n", { ln, s : Any} ]
	  end if
	  if s = "anoblit" then
	    makeNotManifest <- !thing.isAFunction[self$xopname, self$nargs, 0]
	    %
	    % Only because I'm tired of trying things that don't work
	    %
	    makeNotManifest <- makeNotManifest | xopname$name != "of"
	  elseif s = "abuiltinlit" then
	    % A builtin literal
	    % this is manifest if the operation is "of"
	    makeNotManifest <- xopname$name != "of"
	  else
	    makeNotManifest <- true
	  end if
	  if env$traceevaluatemanifests then
	    env.printf["makeNonManifest = %s\n", {makeNotManifest.asString}]
	  end if
	end if
      end if
      if makeNotManifest then
	self$isNotManifest <- true
	changed <- true
      end if
    end if
    changed <- FTree.findManifests[self] | changed
  end findManifests

  function toInt [a : Any] -> [r : Integer]
    primitive [r] <- [a]
  end toInt

  export operation execute -> [r : Tree]
    var tar : Tree
    var t : Oblit
    var theopdef, theopsig, thebody, thestats, thestat, theexps, theexp : Tree
    var theparams, thewheres, thewhere : Tree
    var thecopy : Oblit
    var newst : SymbolTable
    const VofT <- Vector.of[Tree]
    var executedargs  : VofT
    var keystring : String
    var id, codeid, instcodeid : Integer
    var resultObject : Any
    var oldfilename : String
    var filename : String
    var tarname : String
    var shouldCacheAnswer : Boolean <- false
    var index : Integer
    const env <- Environment$env
    const tem : Boolean <- env$traceevaluatemanifests

    if self$value !== nil then
      r <- self$value
      return
    end if
    tar <- self$target.execute
    if tar == nil then
      env$needMoreEvaluateManifest <- true
      return
    end if

    tarname <- nameof tar
    if tem then
      env.info[ln, "Invoc.execute on \"%S\", opname %S",
	{ self$target, xopname } ]
    end if

    if args !== nil then
      executedargs <- VofT.create[self$nargs]
      for i : Integer <- 0 while i <= args.upperbound by i <- i + 1
	var a : Tree <- args[i]
	var xa, xxa : Tree
	xa <- a.execute
	if xa !== nil then xxa <- xa.asType end if
	if tem then
	  env.printf["  arg %d was %S\n", { i, a }]
	  env.printf["  arg %d.execute is %S\n", {i, xa}]
	  env.printf["  arg %d.execute.asType is %S\n", {i, xxa}]
	end if
	if xxa == nil then
	  env$needMoreEvaluateManifest <- true
	  return
	end if
	executedargs[i] <- xxa
      end for
    end if

    % Check the invoc cache
    if self$nargs = 1 then
      const argone <- executedargs[0]
      const aashasid <- view argone as hasId
      const tashasId <- view tar as hasId
      var aid : Integer
      if aashasid == nil then
	env.info[ln, "The invoc of %S should be manifest but arg[0] is nil\n", {xopname}]
      else
        aid <- aashasid$id
	if aid !== nil and aid != 0 then
	  keystring <- formattedOutput.sprintf["%#x.%s[%#x]",
	    { tashasId$id, xopname$name, aashasid$id }]
	  shouldCacheAnswer <- true
%	    (tashasId$id == 0x100c | tashasid$id == 0x1012)
%	    & (xopname$name = "of")
%%%% Seems to break something
%%%%	    & (0x1000 <= aashasid$id) & (aashasid$id <= 0x1a00)
	end if
      end if
    end if
    if keystring !== nil then
      id, codeid, instcodeid, oldfilename, resultObject <- InvocCache.Lookup[keystring]
      filename <- env$fn
      if tem then
	env.printf["Invoc (%s) found %x %x %x %x\n", 
	  {keystring, id, codeid, instcodeid, self.toInt[resultObject]}]
      end if
      if id !== nil then
	if resultObject !== nil then
	  r <- view resultObject as Tree
	  self$value <- r
	  if tem then env.printf["Found a result object\n", nil] end if
	  return
	elseif tarname != "anoblit" then
	  r <- GlobalRef.create[ln, id, nil, codeid, instcodeid, nil]
	  self$value <- r
	  if tem then env.printf["Created a result globalref\n", nil] end if
	  return
	end if
      end if
    end if
    if tarname != "anoblit" then return end if

    t <- view tar as Oblit
    theopdef, index <- t.findOp[self$xopname, self.isSelf, self$nargs, 0]
    theopsig <- (view theopdef as OpDef)$sig
    theparams<- (view theopsig as OpSig)$params
    thewheres<- (view theopsig as OpSig)$xwhere
    thebody  <- (view theopdef as OpDef)$body
    thestats <- (view thebody  as Block)$stats
    if thestats == nil then return end if
    if thestats.upperbound != 0 then return end if
    thestat <- thestats[0]
    theexps <- (view thestat as AssignStat)$right
    theexp  <- theexps[0]

    % Evaluate its symbols
    % This used to be
    newst <- SymbolTable.create[(view theopdef as OpDef)$st$outer, CBlock]
    %
    % but it is now
    % newst <- SymbolTable.create[env$rootst, CBlock]
    % newst <- SymbolTable.create[env$rootst$inner[0], CBlock]
    %
    % because I lose the symbol tables
    
    % so we believe that this object is manifest
    newst$depth <- 1

    %
    % Send the deferred type checks all at once if there are more than one
    %
    const params <- Array.of[Any].empty
    const psyms <- Array.of[Any].empty

    if theparams !== nil then
      for i : Integer <- 0 while i <= theparams.upperbound by i <- i + 1
	const aparam  <- view theparams[i] as Param
	const apsymdef<- view aparam$xsym as Sym
	const apsym   <- apsymdef$mysym
	const asymbol <- newst.define[ln, apsym$myident, SConst, false]
	const avalue  <- executedargs[i]
	assert avalue !== nil
	%
	% Do the type checking here.
	%
	if theparams.upperbound = 0 then
	  env.scheduleDeferredTypeCheck[self, aparam, apsym, avalue, i]
	else
	  params.addupper[aparam]
	  psyms.addupper[apsym]
	end if
	asymbol$value <- avalue
      end for
      if theparams.upperbound > 0 then
	env.scheduleDeferredTypeCheck[self, params, psyms, executedargs, 0]
      end if
    end if

    % by this point, theexp had better be an oblit
    thecopy <- view theexp.copy[0] as Oblit

    newst$myTree <- thecopy

    if thewheres !== nil then
      const todo <- seq.create[thewheres$ln]
      var xx : Any
      for i : Integer <- 0 while i <= thewheres.upperbound by i <- i + 1
	const awhere  <- view thewheres[i] as Wherewidgit
	const aop     <- awhere$xop

	if aop = OP_FORALL then
	  % This is a "for all"
	  % Ignore it for now ???
%	  const awsymdef<- awhere$xsym
%	  const awsym   <- (view awsymdef as Sym)$mysym
%	  const asymbol <- newst.define[ln, awsym$myident, SConst, false]
%	  const tcopy   <- 
%	    atlit.create[
%	      awhere$ln, 
%	      thecopy$sfname,
%	      sym.create[
%		awhere$ln, 
%		Environment$Env$ITable.Lookup["whocares", 999]], 
%	      seq.create[awhere$ln]]
%	  todo.rcons[tcopy]
%	  asymbol$value <- tcopy
	  
	elseif aop = OP_WHERE then
	  % This is a declaration, and I need to do it
	  const awsymdef<- awhere$xsym
	  const awsym   <- (view awsymdef as Sym)$mysym
	  const asymbol <- newst.define[ln, awsym$myident, SConst, false]
	  const tcopy   <- awhere$xtype.copy[0]
	  todo.rcons[tcopy]
	  asymbol$value <- tcopy
	else
	  % This is just a constraint, the only thing we need to do is type
	  % checking
	end if
      end for
      xx <- todo.removeSugar[nil]
      todo.defineSymbols[newst]
      todo.resolveSymbols[newst, 1]
      loop
	exit when !todo.findManifests
      end loop
      todo.evaluateManifests
    end if
    
    thecopy <- thecopy.removeSugar[nil]
    thecopy.defineSymbols[newst]
    thecopy.resolveSymbols[newst, 1]
    loop
      exit when ! thecopy.findManifests
    end loop
    if keystring !== nil and id !== nil then
      if Environment$env$optimizeInvocExecute and oldfilename !== nil and oldfilename != filename then
	const ict <- view thecopy$instCT as oblit
	thecopy$alreadyGenerated <- true
	ict$alreadyGenerated <- true
      end if
      thecopy$id <- id
      thecopy$codeOID <- codeid
      thecopy$instCTOID <- instcodeid
    end if
    thecopy.makeMeManifest
    if Environment$env$dumpevaluatemanifests then
      Environment$env$stdout.putString["The tree before evaluating manifests\n"]
      thecopy.Print[Environment$env$stdout, 0]
    end if
    thecopy.evaluateManifests
    if Environment$env$dumpevaluatemanifests then
      Environment$env$stdout.putString["The tree after evaluating manifests\n"]
      thecopy.Print[Environment$env$stdout, 0]
    end if
    env.tassigntypes["Invoke.execute, assigning types\n", nil]
    thecopy.assignTypes
    self$value <- thecopy
    const itsinstct <- (view thecopy$instCT as ObLit)
    if itsinstct !== nil then itsinstct.setATType end if
    r <- thecopy
    env.pass["Invoke.execute, answer is \"%s\"\n", {r.asString}]
    if keystring !== nil then
      if env$traceevaluatemanifests then
	env.printf["Invoc inserting %s, %x %x %x %x %s\n",
	  {keystring, thecopy$id, thecopy$codeOID, thecopy$instCTOID, 
	   self.toInt[thecopy], shouldCacheAnswer.asString : Any}]
      end if
      if shouldCacheAnswer then
	invoccache.Insert[keystring, thecopy$id, thecopy$codeOID, thecopy$instCTOID, filename, thecopy]
      else
	invoccache.Insert[keystring, thecopy$id, thecopy$codeOID, thecopy$instCTOID, filename, nil]
      end if
    end if
  end execute

  export operation doDeferredTypeCheck
    [params : Any, % Param
     psyms : Any,  % Symbol
     values : Any, % Tree
     whichparameter : Integer]
    const env <- Environment$env
    const tem <- env$traceEvaluateManifests
    var paramlist, psymlist, valuelist : RISA
    var aparam : Param
    var apsym : Symbol
    var avalue : Tree
    var limit : Integer

    if env$dotypecheck then
      const atypes <- AOA.empty
      const btypes <- AOA.empty
      if nameof params = "aparam" then
	limit <- 0
	aparam <- view params as Param
	apsym <- view psyms as Symbol
	avalue <- view values as Tree
      else
	limit <- (view params as RISA).upperbound
	paramlist <- view params as RISA
	psymlist <- view psyms as RISA
	valuelist <- view values as RISA
      end if
      for i : Integer <- 0 while i <= limit by i <- i + 1
	if limit > 0 then
	  aparam <- view paramlist[i] as Param
	  apsym <- view psymlist[i] as Symbol
	  avalue <- view valuelist[i] as Tree
	end if
	const parameterType <- aparam$xtype.execute.asType
	const parameterConstraint <- view apsym$value as Tree
	const argumentValue <- view avalue as hasConforms
	const argumentType <- view (view argumentValue as Tree).getAT as hasConforms
	if tem then
	  env.printf["  parameter %d type is %S\n", {i + 1, parameterType}]
	  env.printf["  parameter %d constraint is %S\n", {i + 1, parameterConstraint}]
	  env.printf["  argument %d type is %S\n", {i + 1, argumentType}]
	  env.printf["  argument %d value is %S\n", {i + 1, argumentValue}]
	end if
	
	if limit = 0 then
	  if !argumentType.conformsTo[ln, parameterType] then
	    env.SemanticError[ln, 
	      "Actual #%d to \"%S[%d]\" does not conform to formal (deferred)",
	      { whichparameter + 1, xopname, self$nargs }]
	    self$value <- Literal.NilL[0]
	  end if
	else
	  atypes.addupper[argumentType]
	  btypes.addupper[parameterType]
	end if

	if parameterConstraint !== nil then
	  if limit = 0 then
	    if !argumentValue.ConformsTo[ln, parameterConstraint] then
	      env.SemanticError[ln, 
		"Actual #%d to \"%S[%d]\" does not match constraint on formal (deferred)",
		{ whichparameter + 1, xopname, self$nargs }]
	      self$value <- Literal.NilL[0]
	    end if
	  else
	    atypes.addupper[argumentValue]
	    btypes.addupper[parameterConstraint]
	  end if
	end if
      end for
      if limit > 0 then
	if !Conformer.Conforms[ln, atypes, btypes] then
	  env.SemanticError[ln, 
	    "Actuals (as a group) to \"%S[%d]\" do not conform or do not match constraint on formals",
	    { xopname, self$nargs }]
	  self$value <- Literal.NilL[0]
	end if
      end if
    end if
  end doDeferredTypeCheck

  operation fakeResultTypes -> [r : Tree]
    const noneType <- (view BuiltinLit.findTree[0x1007,nil] as hasInstAT).getInstAT.asType
    if nress = 1 then
      r <- noneType
    else
      r <- Seq.create[ln]
      for i : Integer <- 0 while i < nress by i <- i + 1
	r.rcons[noneType]
      end for
    end if
    FTree.typeCheck[self]
  end fakeResultTypes

  export operation getAT -> [r : Tree]
    const env <- Environment$env

    if typeinfo !== nil then
    elseif self$value !== nil then
      typeinfo <- self$value.getat
    else
      self.typecheck
      if typeinfo == nil then r <- self.fakeResultTypes end if
    end if
    r <- typeinfo
  end getAT

  export operation getCT -> [r : Tree]
    if self$value !== nil then
      r <- self$value$ct
    else
      r <- self.getat
      if r !== nil then r <- (view r as hasInstCT).getinstct end if
    end if
  end getCT

  export operation evaluateManifests
    if ! self$isNotManifest then
      if self$value == nil then
	% set value to the result of doin the invoke
	self$value <- self.execute
      end if
    end if
    FTree.evaluateManifests[self]
  end evaluateManifests

  export function asString -> [r : String]
    r <- "invoc"
  end asString

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, decls : Tree]
    target, decls <- target.flatten[true, indecls]
    if args !== nil then
      args, decls <- args.flatten[true, decls]
    end if
    if ininvoke then
      const id <- newid.newid
      const asym : Sym <- sym.create[self$ln, id]
      const c : constdecl <- constdecl.create[self$ln, asym, nil, self]
      if decls == nil then 
	decls <- seq.singleton[c]
      else
	decls.rcons[c]
      end if
      r <- sym.create[self$ln, id]
    else
      r <- self
    end if
  end flatten
end Invoc

export Invoc
