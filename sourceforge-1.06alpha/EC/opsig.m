
export Opsig

const opsig <- class Opsig (Tree) [xxname : Ident, xxparams : Tree, xxresults : Tree, xxwhere : Tree]
  class export operation literal [ln : Integer, xxname : Ident, pn : Ident, pt : Tree, rn : Ident, rt : Tree] -> [r : OpSigType]
    var pl, rl : Tree
    if pn !== nil then
      pl <- seq.singleton[param.create[ln, Sym.create[ln, pn], pt.copy[0]]]
    end if
    if rn !== nil then
      rl <- seq.singleton[param.create[ln, Sym.create[ln, pn], pt.copy[0]]]
    end if
    r <- self.create[ln, xxname, pl, rl, nil]
  end literal
  
    field isFunction : Boolean <- false
    field mustBeCompilerExecuted : Boolean <- false
    field name : Ident <- xxname
    field params : Tree <- xxparams
    field results  : Tree <- xxresults
    field xwhere : Tree <- xxwhere
    field st : SymbolTable
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- params
      elseif i = 1 then
	r <- results
      elseif i = 2 then
	r <- xwhere
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	params <- r
      elseif i = 1 then
	results <- r
      elseif i = 2 then
	xwhere <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nparams, nresults, nxwhere : Tree
      if params !== nil then nparams <- params.copy[i] end if
      if results !== nil then nresults <- results.copy[i] end if
      if xwhere !== nil then nxwhere <- xwhere.copy[i] end if
      const realr <- opsig.create[ln, name, nparams, nresults, nxwhere]
      realr$isFunction <- isFunction
      realr$mustBeCompilerExecuted <- mustBeCompilerExecuted
      r <- realr
    end copy

    operation initTypeVariable [psym : Symbol]
      if !psym$isTypeVariable then
	psym$isTypeVariable <- true
	if psym$value == nil then
	  const tcopy : Tree  <- 
	    Environment$env$atlit.create[
	      self$ln, 
	      Literal.StringL[0, "junk"],
	      sym.create[self$ln,
		Environment$Env$ITable.Lookup["whocares", 999]], 
	      seq.create[self$ln]
	    ]
	  (view tcopy as typeobject t operation setIsTypeVariable[Boolean] end t)$isTypeVariable <- true
	  psym$value <- tcopy
	end if
      end if
    end initTypeVariable

    export operation findManifests -> [changed : Boolean]
      changed <- false
      if params !== nil then
	for i : Integer <- 0 while i < params.upperbound by i <- i + 1
	  const psym : Symbol <- (view (view params[i] as Param)$xsym as Sym)$mysym
	  if !psym$isTypeVariable then
 	    for j : Integer <- i + 1 while j <= params.upperbound by j <- j + 1
	      const t : Tree <- (view params[j] as Param)$xtype
	      if nameof t = "asym" then
		const tsym : Symbol <- (view t as Sym)$mysym
		if psym == tsym then
		  self.initTypeVariable[psym]
		  changed <- true
		end if
	      end if
	    end for
	    if results !== nil then
	      for j : Integer <- 0 while j <= results.upperbound by j <- j + 1
		const t : Tree <- (view results[j] as Param)$xtype
		if nameof t = "asym" then
		  const tsym : Symbol <- (view t as Sym)$mysym
		  if psym == tsym then
		    self.initTypeVariable[psym]
		    changed <- true
		  end if
		end if
	      end for
	    end if
	  end if
	end for
      end if
      changed <- changed | FTree.findManifests[self]
    end findManifests

    export operation isInDefinition 
      % Make sure that each parameter and result has a name
      if params !== nil then
	for i : Integer <- 0 while i <= params.upperbound by i <- i + 1
	  const p <- view params[i] as Param
	  if p$xsym == nil then
	    Environment$env.SemanticError[ln, "Parameter %d needs a name", { i + 1}]
	  end if
	end for
      end if
      if results !== nil then
	for i : Integer <- 0 while i <= results.upperbound by i <- i + 1
	  const p <- view results[i] as Param
	  if p$xsym == nil then
	    Environment$env.SemanticError[ln, "Result %d needs a name", { i + 1}]
	  end if
	end for
      end if
    end isInDefinition

    export operation defineSymbols[pst : SymbolTable]
      % Check restrictions on functions
      %
      if isFunction and self$nress != 1 then
	Environment$env.SemanticError[ln, "Function must return 1 result, not %d", {self$nress}]
      end if
      if pst$context != COpDef then
	st <- SymbolTable.create[pst, COpSig]
	st$myTree <- self
      else
	st <- pst
      end if
      if params !== nil then
	st$kind <- SParam
	params.defineSymbols[st]
      end if
      if results !== nil then
	st$kind <- SResult
	results.defineSymbols[st]
      end if
      if xwhere !== nil then
	for i : Integer <- 0 while i <= xwhere.upperbound by i <- i + 1
	  const X <- typeobject hasNeedsToBeCompilerExecuted
	    function getNeedsToBeCompilerExecuted -> [Boolean]
	  end hasNeedsToBeCompilerExecuted
	  const awhere <- view xwhere[i] as X
	  if awhere$needsToBeCompilerExecuted then
	    self$mustBeCompilerExecuted <- true
	    exit
	  end if
	end for
	xwhere.defineSymbols[st]
      end if
    end defineSymbols

    export operation getNArgs -> [r : Integer]
      if params == nil then
	r <- 0
      else
	r <- params.upperbound + 1
      end if
    end getNArgs
    export operation getNRess -> [r : Integer]
      if results == nil then
	r <- 0
      else
	r <- results.upperbound + 1
      end if
    end getNRess

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export operation generate [ct : Printable]
    const par <- self$params
    const res <- self$results
    var nameasstring : String <- name$name
    const ctname <- nameof ct
    const env : EnvironmentType <- Environment$env
    if ctname = "abytecode" then
      if env$useAbCons and par !== nil then
	par.generate[ct]
      end if
      if res !== nil then res.generate[ct] end if
    elseif ctname = "anopvectore" then
      const opve <- view ct as OpVectorE
      
      opve$name <- nameasstring
      if par == nil then
        nameasstring <- nameasstring || "@0"
      else
	opve$nargs <- par.upperbound + 1
	nameasstring <- nameasstring || "@" || (par.upperbound + 1).asString
      end if
      if res !== nil then
	opve$nress <- res.upperbound + 1
      end if
      nameasstring <- nameasstring || "@" || opve$nress.asString
      opve$id <- opnametooid.Lookup[nameasstring]
    elseif ctname =  "anatcode" then
      % build an entry in the op vector ct.ops for me
      const ctasat <- view ct as ATCode
      const ops <- ctasat$ops
      const ove : ATOpVectorE <- ATOpVectorE.create[nameasstring]
      ops.addUpper[ove]
      ove$isFunction <- self$isFunction
      if par == nil then
        nameasstring <- nameasstring || "@0"
      else
	nameasstring <- nameasstring || "@" || (par.upperbound + 1).asString
      end if
      if res == nil then
	nameasstring <- nameasstring || "@0"
      else
	nameasstring <- nameasstring || "@" || (res.upperbound + 1).asString
      end if
      ove$id <- opnametooid.Lookup[nameasstring]
      if par !== nil then
	const limit <- par.upperbound
	ove$Arguments <- ATTypeVector.create
	for i : Integer <- 0 while i <= limit by i<-i+1
	  const t <- par[i].asType
	  if t !== nil then
	    const r <- view t as hasID
	    if env$traceassignTypes then
	      env.printf["Found a thing %S with id %x\n", { r, r$id }]
	    end if
	    ove$arguments.addUpper[RefByID.create[r$id]]
	  else
	    if env$traceassignTypes then
	      env.printf["Found a thing %S whose astype is nil\n", {par[i]}]
	    end if
	    ove$arguments.addUpper[nil]
	  end if
	end for
      end if
      if res !== nil then
	const limit <- res.upperbound
	ove$Results <- ATTypeVector.create
	for i : Integer <- 0 while i <= limit by i<-i+1
	  const t <- res[i].asType
	  if t !== nil then
	    const r <- view t as hasID
	    if env$traceassigntypes then
	      env.printf["Found a thing %S with id %x\n",  { r, r$id }]
	    end if
	    ove$results.addUpper[RefByID.create[r$id]]
	  else
	    if env$traceassignTypes then
	      env.printf["Found a thing %S whose astype is nil\n", {res[i]}]
	    end if
	    ove$results.addUpper[nil]
	  end if
	end for
      end if
    end if
  end generate

  export function same [o : Tree] -> [r : Boolean]
    r <- false
    if nameof o = "anopsig" then
      const oo <- view o as OpSig
      r <- self$name$name = oo$name$name and
        (self$nargs = oo$nargs or self$name$name = "create")
    end if
  end same
  export function asString -> [r : String]
    r <- "opsig"
  end asString
end Opsig
