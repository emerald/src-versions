const starinvoc <- class Starinvoc (Tree) [xxtarget : Tree, xxopname : Tree, xxargs : Tree]
    const ln : Integer <- xxtarget$ln
    field target : Tree <- xxtarget
    field xopname : Tree <- xxopname
    field args  : Tree <- xxargs
    field nress : Integer <- 1

    export operation getIsNotManifest -> [r : Boolean]
      r <- true
    end getIsNotManifest
    export operation setIsNotManifest [r : Boolean]
      assert r
    end setIsNotManifest
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- target
      elseif i = 1 then
	r <- xopname
      elseif i = 2 then
	r <- args
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	target <- r
      elseif i = 1 then
	xopname <- r
      elseif i = 2 then
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
      var ntarget, nopname, nargs : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if xopname !== nil then nopname <- xopname.copy[i] end if
      if args !== nil then nargs <- args.copy[i] end if
      newt <- starinvoc.create[ln, ntarget, nopname, nargs]
    end copy

    export operation resolveSymbols [st : SymbolTable, nexp : Integer]
      nress <- nexp
      target.resolveSymbols[st, 1]
      if args !== nil then args.resolveSymbols[st, 1] end if
    end resolveSymbols

  export operation assignTypes
    FTree.assignTypes[self]
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

  export operation typeCheck 
    % Check that the opname is a string and the argument is a single risa
    const env <- Environment$env

    if self$nargs != 1 then
      env.SemanticError[self$ln,
	"Number of arguments %d incorrect, .* invoke expects 1",
	{ self$nargs }]
    end if
    if self$nress != 1 then
      env.SemanticError[self$ln,
	"Number of results %d incorrect, .* invoke returns 1",
	{ self$nress }]
    end if
    begin
      const actualtype <- view self$args[0].getAT as hasconforms
      const formaltype <- (view BuiltinLit.findTree[0x1021, nil] as hasInstAT).getInstAT.asType
  
      if actualtype == nil then
	env.ttypeCheck["starinvoc.typecheck on %d, actual type is nil\n", 
	      { self$ln } ]
      elseif !actualType.conformsTo[self$ln, formalType] then
	env.SemanticError[self$ln, 
	  "Actual #1 to .* invoke does not conform to formal", nil]
      end if
      FTree.typeCheck[self]
    end
  end typeCheck

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode

    var targetType, targetCT : Tree
    bc.lineNumber[self$ln]

    bc.pushSize[4]
    self$args.generate[xct]
    bc.popSize
    bc.pushSize[8]
    self$target.generate[xct]
    bc.popSize
    bc.pushSize[4]
    self$xopname.generate[xct]
    bc.popSize
    bc.addCode["CALLSTAR"]
    bc.fetchLiteral[0x1821]
    bc.addCode["LDLB"]
    bc.addValue[0, 1]
    bc.addCode["CREATEVECLIT"]
    bc.addCode["CALLSTARCLEAN"]
    bc.finishExpr[4, 0x1821, 0x1621]
  end generate

  export operation getAT -> [r : Tree]
    r <- (view BuiltinLit.findTree[0x1021, nil] as hasInstAT).getInstAT.asType
  end getAT

  export operation getCT -> [r : Tree]
    r <- (view BuiltinLit.findTree[0x1021, nil] as hasInstCT).getInstCT
  end getCT

  export function asString -> [r : String]
    r <- "starinvoc"
  end asString
end Starinvoc

export Starinvoc
