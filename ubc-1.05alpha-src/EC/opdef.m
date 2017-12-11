export Opdef

const opdef <- class Opdef (Tree) [xxsig : Tree, xxbody : Tree]
  const xisInlineable <- 0
  const xisExported <- 1
  const xisMonitored <- 2
  const xisPrivate <- 3
  const xopNumber <- 16
  const xOpNumberLength <- 16
  
    field sig : OpSig <- view xxsig as OpSig
    field body : Tree <- xxbody
    var   st   : SymbolTable
    var f : Integer <- 0

    export function getST -> [r : SymbolTable]
      r <- st
    end getST
    export operation setST [v : SymbolTable]
      st <- v
      sig$st <- v
    end setST

    export operation setisInlineable [a : Boolean]
      f <- f.setBit[xisInlineable, a]
    end setisInlineable
    export function getisInlineable -> [r : Boolean]
      r <- f.getBit[xisInlineable]
    end getisInlineable
  
    export operation setisExported [a : Boolean]
      f <- f.setBit[xisExported, a]
    end setisExported
    export function getisExported -> [r : Boolean]
      r <- f.getBit[xisExported]
    end getisExported
  
    export operation setisMonitored [a : Boolean]
      f <- f.setBit[xisMonitored, a]
    end setisMonitored
    export function getisMonitored -> [r : Boolean]
      r <- f.getBit[xisMonitored]
    end getisMonitored
  
    export operation setisPrivate [a : Boolean]
      f <- f.setBit[xisPrivate, a]
    end setisPrivate
    export function getisPrivate -> [r : Boolean]
      r <- f.getBit[xisPrivate]
    end getisPrivate
  
    export operation setopNumber [a : Integer]
      f <- f.setBits[xopNumber, xOpNumberLength, a]
    end setopNumber
    export function getopNumber -> [r : Integer]
      r <- f.getBits[xopNumber, xOpNumberLength]
    end getopNumber
  
    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- sig
      elseif i = 1 then
	r <- body
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	sig <- view r as OpSig
      elseif i = 1 then
	body <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : OpDef]
      var nsig, nbody : Tree
      if sig !== nil then nsig <- sig.copy[i] end if
      if body !== nil then nbody <- body.copy[i] end if
      r <- opdef.create[ln, nsig, nbody]
      r$isExported <- self$isExported
      r$isPrivate <- self$isPrivate
      r$isMonitored <- self$isMonitored
    end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    const realob <- view ob as Monitorable
    if realob$isMonitored then
      self$isMonitored <- true
    end if
    r <- FTree.removeSugar[self, ob]
  end removeSugar

  export operation findStatement -> [isPrim : Boolean, ans : Tree]
    const xbody <- body
    const xstats : Tree <- (view xbody as Block)$stats
    if xstats !== nil and xstats.upperbound = 0 then
      const stat : Tree <- xstats[0]
      const statname <- nameof stat
      
      if statname = "aprimstat" then
	isPrim <- true
	ans <- stat 
      elseif statname = "anassignstat" then
	const a <- view stat as AssignStat
	var rhs : Tree
	var name : String
	if a$left .upperbound != 0 then return end if
	if a$right.upperbound != 0 then return end if
	rhs <- a$right[0]
	name <- nameof rhs
	if name = "asym" then
	  const sy : Symbol <- (view rhs as Sym)$mysym
	  if !sy$isNotManifest or sy$isInstVariable then
	    isPrim <- false
	    ans <- stat
	  end if
	elseif name = "aliteral" and (view rhs as Literal)$index = IntegerIndex then
	  isPrim <- false
	  ans <- stat
	end if
      end if
    end if
  end findStatement

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, COpDef]
    self$st$myTree <- self
    sig.defineSymbols[self$st]
    FTree.defineSymbols[self$st, body]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    self$st$inInitially <- false
    sig.resolveSymbols[self$st, 0]
    FTree.resolveSymbols[self$st, body, 0]
    self$st$inInitially <- true
  end resolveSymbols

  export operation findThingsToGenerate [q : Any]
    FTree.findThingsToGenerate[q, self]
  end findThingsToGenerate

  export operation assignTypes 
    FTree.assignTypes[self]

    % See if it makes sense to inline me
    var stat : Tree
    var isPrim : Boolean
    const env : EnvironmentType <- Environment$env
    const til <- env$traceinline

    if til then
      env.printf["Checking to see if  %s on %d is inlineable\n",
	{sig$name.asString, ln}]
    end if
    if sig$results == nil or sig$results.upperbound = 0 then
      isprim, stat <- self.findStatement
      if stat == nil then
	if til then env.printf["  Nope, no acceptable statement\n", nil] end if
      else
	self$isInlineable <- true
	if til then env.printf["  Yup, and isprim = %s\n", {isprim.asString}] end if
      end if
    else
      % Nope, must have either 0 or 1 result to be inlined
      if til then env.printf["  Nope, not 0 or 1 result\n", nil] end if
    end if
  end assignTypes

  export operation generate [ct : Printable]
    const ove : OpVectorE <- opvectore.create[nil]
    const ctasct <- view ct as CTCode
    const mybc : ByteCode <- bytecode.create[ctasct$literals]
    const ov : OpVector <- ctasct$opVec
    const templ : Template <- Template.create
    const returnlabel : Integer <- mybc.declareLabel

    % Look for signals at the end
    if Environment$env$generateconcurrent and self$isMonitored and self$isExported and body !== nil then
      const statseq <- body[0]
      if statseq.upperbound >= 0 then
	const last <- statseq[statseq.upperbound]
	const name <- last.asString
	if name = "signalstat" then
	  const SignalStat <- typeobject t 
	    operation setUseSignalAndExit[Integer]
	  end t
	  const s <- view last as SignalStat
	  s$useSignalAndExit <- ove$nargs
	end if
      end if
    end if

    ove$templ <- templ

    mybc.nest[returnlabel]

    ov.addUpper[ove]
    self$sig.generate[ove]
    % Generate the template
    self$st.writeTemplate[templ, 'L']

    % Generate the prolog (allocate space for locals)
    mybc.setLocalSize[st$localSize]

    % if we're using abcons, we have to generate the code that checks them

    if Environment$env$useAbCons then
      const params : Tree <- sig$params
      if params !== nil then params.generate[mybc] end if
    end if

    if Environment$env$generateconcurrent and self$isMonitored and self$isExported then
      mybc.addCode["MONENTER"]
    end if
    

    % All this does is generate the storing of concrete type information in
    % the result variables. This is only necessary if the body is a simple
    % primitive.  More precisely, if the only assignment to the result
    % variables in the body is via a primitive.
    self$body.generate[mybc]
    if mybc$usedPrimitive then
      const results : Tree <- sig$results
      if results !== nil then results.generate[mybc] end if
    end if

    mybc.lineNumber[self$ln]
    mybc.defineLabel[returnlabel]

    if Environment$env$generateconcurrent and self$isMonitored and self$isExported then
      mybc.addCode["MONEXIT"]
    end if

    % Generate the epilog (return and pop args)
    mybc.addCode["RET"]
    mybc.addValue[ove$nargs, 1]

    ove$code <- mybc.getString
    ove$others <- mybc$others
    begin
      const lninfo <- mybc.getLNInfo
      if lninfo !== nil then
	templ.addLineNumbers[lninfo]
      end if
    end
  end generate

  export function same [o : Tree] -> [r : Boolean]
    r <- false
    if nameof o = "anopdef" then
      r <- self$sig.same[(view o as OpDef)$sig]
    end if
  end same
  export function asString -> [r : String]
    r <- "opdef"
  end asString
end Opdef
