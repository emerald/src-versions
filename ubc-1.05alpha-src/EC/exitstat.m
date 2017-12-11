export Exitstat

const exitstat <- class Exitstat (Tree) [xxexp : Tree]
    field exp : Tree <- xxexp

    export function upperbound -> [r : Integer]
      r <- 0
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- exp
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	exp <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nexp : Tree
      if exp !== nil then nexp <- exp.copy[i] end if
      r <- exitstat.create[ln, nexp]
    end copy

    export operation typeCheck
      if exp !== nil then
	const booleantype <- (view BuiltinLit.findTree[0x1003, nil] as hasInstAT).getInstAT.asType

	var t : hasConforms
	t <- view exp.getAT as hasConforms
	if t !== nil then t <- view t.asType as hasConforms end if
	if t == nil then
	  Environment$env.ttypecheck["No type for if clause on %d\n",
	    { exp$ln }]
	elseif !t.conformsTo[ln, booleantype] then
	  Environment$env.SemanticError[exp$ln, "boolean required", nil]
	end if
      end if
      FTree.typecheck[self]
    end typeCheck

    export operation generate [xct : Printable]
      const bc <- view xct as ByteCode
      const label : Integer <- bc.fetchnest
      if label == nil then
	Environment.getEnv.SemanticError[ln, "Exit statement without enclosing loop", nil]
      else
	bc.lineNumber[self$ln]
	if exp == nil then
	  bc.addCode["BR"]
	else
	  bc.pushSize[4]
	  exp.generate[xct]
	  bc.popSize
	  bc.addCode["BRT"]
	end if
	bc.addLabelReference[label, 2]
      end if
    end generate

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    if self$exp !== nil then self$exp.resolveSymbols[pst, 1] end if
  end resolveSymbols

  export function asString -> [r : String]
    r <- "exitstat"
  end asString
end Exitstat
