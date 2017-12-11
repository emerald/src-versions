export Ifclause

const ifclause <- class Ifclause (Tree) [xxexp : Tree, xxstats : Tree]
    field exp : Tree <- xxexp
    field stats : Tree <- xxstats
    field st  : SymbolTable

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- exp
      elseif i = 1 then
	r <- stats
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	exp <- r
      elseif i = 1 then
	stats <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nexp, nstats : Tree
      if exp !== nil then nexp <- exp.copy[i] end if
      if stats !== nil then nstats <- stats.copy[i] end if
      r <- ifclause.create[ln, nexp, nstats]
    end copy

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    var decls : Tree
    var val : Tree
    assert !ininvoke
    val, decls <- exp.flatten[ininvoke, nil]
    if decls !== nil then
      exp <- Eblock.create[ln, decls, val]
    else
      assert val == exp
    end if
    outdecls <- indecls
    r <- self
  end flatten

    export operation shouldUseCase [xsym :Symbol, min : Integer, max : Integer]
      -> [r : Boolean, nsymb : Symbol, s : Sym, nmin : Integer, nmax : Integer, val : Integer]

      r <- false
      if nameof exp = "aninvoc" then
	const i <- view exp as Invoc
	const t <- i$target
	const o <- i$xopname
	const a <- i$args
	var arg : Tree
	var str, argstr : String

	% Check the target
	if nameof t = "asym" then
	  s <- view t as Sym
	  if xsym == nil then 
	    nsymb <- s$mysym
	  else
	    nsymb <- xsym
	  end if
	  if s$mysym !== nsymb then return end if
	else
	  return
	end if

	% check the opname
	if o$name != "=" then return end if

	% check the args
	if a.upperbound != 0 then return end if
	
	arg <- a[0]
	if nameof arg = "anarg" then arg <- arg[0] end if

	argstr <- nameof arg
	if argstr != "aliteral" then return end if
	const asLiteral <- (view arg as Literal)
	const index <- asLiteral$index
	const valstr <- asLiteral$str
	if index = IntegerIndex then
	  val <- Integer.literal[valstr]
	elseif index = CharacterIndex then
	  val <- valstr[0].ord
	else
	  return
	end if
	if min == nil or val < min then
	  nmin <- val
	else
	  nmin <- min
	end if
	if max == nil or val > max then
	  nmax <- val
	else
	  nmax <- max
	end if
	r <- true
      else
	return
      end if
    end shouldUseCase

  export operation defineSymbols[pst : SymbolTable]
    self$exp.defineSymbols[pst]
    self$st <- SymbolTable.create[pst, CBlock]
    self$st$myTree <- self
    self$stats.defineSymbols[self$st]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    self$exp.resolveSymbols[self$st, 1]
    self$stats.resolveSymbols[self$st, 0]
  end resolveSymbols

  export operation typeCheck 
    const booleantype <- (view BuiltinLit.findTree[0x1003, nil] as hasInstAT).getInstAT.asType
    
    var t : hasConforms
    t <- view exp.getAT as hasConforms
    if t !== nil then t <- view t.asType as hasConforms end if
    if t == nil then
      Environment$env.ttypecheck["No type for if clause on %d\n", 
	{ exp$ln }]
    elseif !t.conformsTo[exp$ln, booleantype] then
      Environment$env.SemanticError[exp$ln, "boolean required", nil]
    end if

    FTree.typeCheck[self]
  end typeCheck

  export function asString -> [r : String]
    r <- "ifclause"
  end asString
end Ifclause
