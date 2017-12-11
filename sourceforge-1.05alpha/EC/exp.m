export Exp

const exp <- class Exp (Tree) [xxleft : Tree, xxop : Ident, xxright : Tree]
    field left : Tree <- xxleft
    field xop : Ident <- xxop
    field right  : Tree <- xxright
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
    export operation copy [i : Integer] -> [r : Tree]
      var nleft, nright : Tree
      if left !== nil then nleft <- left.copy[i] end if
      if right !== nil then nright <- right.copy[i] end if
      r <- exp.create[ln, nleft, xop, nright]
    end copy

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    const s <- xop$name
    left, outdecls <- left.flatten[true, indecls]
    if s = "and" or s = "or" then
      var decls : Tree
      var val : Tree
      val, decls <- right.flatten[true, nil]
      if decls !== nil then
	right <- Eblock.create[ln, decls, val]
      else
	assert val == right
      end if
    end if
    if ininvoke then
      const id <- newid.newid
      const asym : Sym <- sym.create[self$ln, id]
      const c : constdecl <- constdecl.create[self$ln, asym, nil, self]
      if outdecls == nil then 
	outdecls <- seq.singleton[c]
      else
	outdecls.rcons[c]
      end if
      r <- sym.create[self$ln, id]
    else
      r <- self
    end if
  end flatten

  export operation removeSugar [o : Tree] -> [r : Tree]
    const s <- xop$name
    if s = "*>" then
      left <- invoc.create[
		left$ln,
		left,
		opname.literal["getsignature"],
		nil]
      right <- invoc.create[
		right$ln,
		right,
		opname.literal["getsignature"],
		nil]
    end if
    r <- FTree.removeSugar[self, o]
  end removeSugar

  export operation typeCheck
    const s <- xop$name
    const env <- Environment$env
    var t : hasConforms

    left.typeCheck
    right.typeCheck

    if s = "or" or s = "and" then
      const booleantype <- (view BuiltinLit.findTree[0x1003, nil] as hasInstAT).getInstAT.asType

      t <- view left.getAT as hasConforms
      if t !== nil then t <- view t.asType as hasConforms end if
      if t == nil then
	env.ttypecheck["Found nil on left of %s on %d\n", 
	  { s, self$ln }]	
      elseif !t.conformsTo[ln, booleantype] then
	env.SemanticError[self$ln, "boolean required", nil]	
      end if

      t <- view right.getAT as hasConforms
      if t !== nil then t <- view t.asType as hasConforms end if
      if t == nil then
	env.ttypecheck["Found nil on right of %s on %d\n", 
	  { s, self$ln }]	
      elseif !t.conformsTo[ln, booleantype] then
	env.SemanticError[self$ln, "boolean required", nil]	
      end if
    elseif s = "*>" then
      const signaturetype <- (view BuiltinLit.findTree[0x1009, nil] as hasInstAT).getInstAT.asType
      const typetype <- (view BuiltinLit.findTree[0x1000, nil] as hasInstAT).getInstAT.asType
      t <- view left.getAT as hasConforms
      if t !== nil then t <- view t.asType as hasConforms end if
      if t == nil then
	env.ttypecheck["Found nil on left of %s on %d\n", 
	  { s, self$ln }]	
      elseif !t.conformsTo[ln, typetype] then
	env.SemanticError[self$ln, "type required", nil]	
      else
	const oldWhy <- env$why
	env$why <- false
	if !t.conformsTo[ln, signaturetype] then
	  left <- invoc.create[
		    left$ln,
		    left,
		    opname.literal["getsignature"],
		    nil]
	end if
	env$why <- oldWhy
      end if

      t <- view right.getAT as hasConforms
      if t !== nil then t <- view t.asType as hasConforms end if
      if t == nil then
	env.ttypecheck["Found nil on right of %s on %d\n", 
	  { s, self$ln }]	
      elseif !t.conformsTo[ln, typetype] then
	env.SemanticError[self$ln, "type required", nil]	
      else
	const oldWhy <- env$why
	env$why <- false
	if !t.conformsTo[ln, signaturetype] then
	  right <- invoc.create[
		    right$ln,
		    right,
		    opname.literal["getsignature"],
		    nil]
	end if
	env$why <- oldWhy
      end if
    elseif s = "==" then
    elseif s = "!==" then
    else
      env.printf["Can't type check a %s.\n", { s }]
    end if
  end typeCheck

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    const s <- xop$name
    if s = "or" or s = "and" then
      const isand : Boolean <- s = "and"
      const endLabel : Integer <- bc.declareLabel
      var opcode : String
      bc.pushSize[4]
      self$left.generate[xct]
      bc.addCode["DUP"]
      if isand then
	opcode <- "BRF"
      else
	opcode <- "BRT"
      end if
      bc.addCode[opcode]
      bc.addLabelReference[endLabel, 2]
      bc.addCode["POOP"]
      self$right.generate[xct]
      bc.popSize
      bc.defineLabel[endLabel]
      bc.finishExpr[4, 0x1803, 0x1603]
    elseif s = "==" then
      bc.pushSize[4]
      self$left.generate[xct]
      self$right.generate[xct]
      bc.popSize
      bc.addCode["SUB"]
      bc.addCode["EQ"]
      bc.finishExpr[4, 0x1803, 0x1603]
    elseif s = "!==" then
      bc.pushSize[4]
      self$left.generate[xct]
      self$right.generate[xct]
      bc.popSize
      bc.addCode["SUB"]
      bc.addCode["NE"]
      bc.finishExpr[4, 0x1803, 0x1603]
    elseif s = "*>" then
      bc.pushSize[4]
      left.generate[xct]
      right.generate[xct]
      bc.popSize
      bc.addCode["CONFORMS"]
      bc.finishExpr[4, 0x1803, 0x1603]
    end if
  end generate
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, 0x03].getInstAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, 0x03].getInstCT
  end getCT
  export function asString -> [r : String]
    r <- "exp"
  end asString
end Exp
