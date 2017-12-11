export Assignstat

const assignstat <- class Assignstat (Tree) [xxleft : Tree, xxright : Tree]
    field left : Tree <- xxleft
    field right  : Tree <- xxright
    const ln : Integer <- left[0]$ln

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- left
      elseif i = 1 then
	r <- right
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	left <- r
      elseif i = 1 then
	right <- r
      end if
    end setElement
    operation iremoveSugar -> [r : Tree]
      const onleft <- typeobject onleft
	operation removesugaronleft [Tree] -> [Tree]
      end onleft
      
      r <- self
      if left !== nil and left.upperbound = 0 then
	const e <- left[0]
	const s <- nameof e
	if s = "afieldsel" or s = "asubscript" then
	  const f <- view e as onleft
	  r <- f.removeSugarOnLeft[right]
	end if
      end if
    end iremoveSugar

    export operation resolveSymbols [st : SymbolTable, nexp : Integer]
      if left !== nil then
	left.resolveSymbols[st, 0]
	if right.upperbound = 0 then
	  right.resolveSymbols[st, left.upperbound + 1]
	else
	  right.resolveSymbols[st, 1]
	end if
      else
	right.resolveSymbols[st, 0]
      end if
    end resolveSymbols
    export operation copy [i : Integer] -> [r : Tree]
      var nleft, nright : Tree
      if left !== nil then nleft <- left.copy[i] end if
      if right !== nil then nright <- right.copy[i] end if
      r <- assignstat.create[ln, nleft, nright]
    end copy

  export operation typeCheck
    const l <- self$left
    const r <- self$right
    const limit <- l.upperbound
    var theRightTypes : Tree <- nil

    if limit != r.upperbound then
      % This has to worry about the right being an invocation that returns
      % multiple results.  For now, only generate the error if length of
      % right is > 1
      if r.upperbound = 0 and nameof r[0] = "aninvoc" then
	theRightTypes <- r[0].getAT
	if therighttypes == nil then
	  % the operation is not defined, but an error will come later
	  FTree.typeCheck[self]
	  return
	end if
	assert nameof theRightTypes = "aseq"
	assert limit = theRightTypes.upperbound
      else
	Environment$env.SemanticError[self$ln, 
	  "expected %d expressions in assignment, found %d", 
	  { limit + 1, r.upperbound + 1}]
	return
      end if
    end if

    for i : Integer <- 0 while i <= limit by i <- i + 1
      const anl <- l[i]
      const anlname <- nameof anl
      var rtype : hasConforms

      if anlname = "asym" then
	if theRightTypes == nil then
	  const rexp <- r[i]
	  rtype <- view rexp.getAT as hasConforms
	else
	  rtype <- view theRightTypes[i] as hasConforms
	end if
	const lsym : Symbol <- (view l[i] as Sym)$mysym
	const ltype  <- view lsym$ATInfo as Tree
	const itskind : Integer <- lsym$mykind
	if itskind = SConst or itskind = SParam then
	  Environment$env.SemanticError[ln, "Attempt to store into constant symbol %S", { lsym$myident}]
	elseif ltype == nil then
	  if Environment$env$tracetypecheck then
	    Environment$env.printf[
	      "assign.typeCheck on %d: type of left (%s) is nil\n", 
	      { self$ln, lsym.asString }]
	  end if
	elseif rtype == nil then
	  if Environment$env$tracetypecheck then 
	    Environment$env.printf[
	      "assign.typeCheck on %d: type of right (%S) is nil\n", 
	      { self$ln, r[i] }]
	  end if
	elseif ! rtype.conformsTo[self$ln, ltype] then
	  if i == 0 and limit == 0 then
	    Environment$env.SemanticError[self$ln, 
	      "type of rhs does not conform to lhs", nil]
	  else
	    Environment$env.SemanticError[self$ln,
	      "type of rhs expression %d does not conform to lhs", { i + 1 }]
	  end if
	end if
      else
	if i == 0 and limit == 0 then
	  Environment$env.SemanticError[self$ln, 
	    "left side of assignment is not a symbol", nil]
	else
	  Environment$env.SemanticError[self$ln, 
	    "left side of assignment (expression #%d) is not a symbol", 
	    { i + 1 }]
	end if
      end if
    end for
    FTree.typeCheck[self]
  end typeCheck

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    const hasGenerateLValue <- typeobject hasGenerateLValue
      operation generateLValue[Printable]
    end hasGenerateLValue
    var lv : hasGenerateLValue

    bc.lineNumber[self$ln]
    if self$left.upperbound = 0 then
      const sr <- view self$left[0] as Sym
      const s : Symbol  <- sr$mysym
%      Environment$env.pass["assign.generate: left is %s size is %d\n",
%	{s.asString, s$size}]
      bc.pushSize[s$size]
    else
      bc.pushSize[8]
    end if
    self$right.generate[xct]

    if self$left !== nil then
      % store the results to the vars
      % This has to go backwards through the vars
      for i: Integer <- self$left.upperbound while i >= 0 by i <- i - 1
	lv <- view self$left[i] as hasGenerateLValue
	lv.generateLValue[xct]
      end for
    end if
    bc.popSize
  end generate
  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- FTree.removeSugar[r, ob]
  end removeSugar

  export function asString -> [r : String]
    r <- "assignstat"
  end asString
end Assignstat
