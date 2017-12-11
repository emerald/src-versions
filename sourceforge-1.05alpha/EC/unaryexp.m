% File for generating unary expressions.  Type checking code is
% missing and should be added.

export Unaryexp

const unaryexp <- class Unaryexp (Tree) [xxop : Ident, xxexp : Tree]
    field xop : Ident <- xxop
    field exp  : Tree <- xxexp
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
      r <- unaryexp.create[ln, xop, nexp]
    end copy
    operation iremoveSugar -> [r : Tree]
      const s : String <- xop$name
      if s = "nameof" then
	r <- invoc.create[
	  self$ln,
	  unaryexp.create[self$ln, opname.literal["codeof"], exp],
	  opname.literal["getname"],
	  nil]
      elseif s = "typeof" then
	r <- invoc.create[
	  self$ln,
	  unaryexp.create[self$ln, opname.literal["codeof"], exp],
	  opname.literal["gettype"],
	  nil]
      else
	r <- self
      end if
    end iremoveSugar


  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- FTree.removeSugar[r, ob]
  end removeSugar

  export operation getCT -> [r : Tree]
    const s : String <- xop$name
    var index : Integer 
    if s = "locate" then
      index <- 0x08
    elseif s = "isfixed" then
      index <- 0x03
    elseif s = "islocal" then
      index <- 0x03
    elseif s = "codeof" then
      index <- 0x18
    elseif s = "nameof" then
      index <- 0x0b
    elseif s = "awaiting" then
      index <- 0x06
    elseif s = "syntactictypeof" then
      index <- 0x09
    end if
    r <- builtinlit.create[self$ln, index].getInstCT
  end getCT

  export operation getIsNotManifest -> [r : Boolean]
    const s : String <- xop$name
    r <- s != "syntactictypeof"
  end getIsNotManifest

  export function asType -> [r : Tree]
    r <- self.execute
    if r !== nil then r <- r.asType end if
  end astype

  export operation execute -> [r : Tree]
    const s : String <- xop$name
    if s = "syntactictypeof" then
      r <- exp.getAT
      if r !== nil then r <- r.execute end if
    end if
  end execute

  export operation getAT -> [r : Tree]
    const s : String <- xop$name
    var index : Integer 
    if s = "locate" then
      index <- 0x08
    elseif s = "isfixed" then
      index <- 0x03
    elseif s = "islocal" then
      index <- 0x03
    elseif s = "codeof" then
      index <- 0x18
    elseif s = "nameof" then
      index <- 0x0b
    elseif s = "awaiting" then
      index <- 0x06
    elseif s = "syntactictypeof" then
      index <- 0x09
    end if
    r <- builtinlit.create[self$ln, index].getInstAT
  end getAT

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode

    const s : String <- xop$name
    if s = "locate" then
      bc.pushSize[8]
      exp.generate[bc]
      bc.popSize
      bc.addCode["SYS"]
      bc.addCode["JLOCATE"]
      bc.addValue[2, 1]			% takes 1 VAR argument (2 words).
      bc.finishExpr[8, 0x1808, 0x1608]
    elseif s = "isfixed" then
      bc.pushSize[8]
      self$exp.generate[bc]
      bc.addCode["SYS"]
      bc.addCode["ISFIXED"]
      bc.addValue[2, 1]		% ISFIXED takes two words of arguments.
      bc.popSize
      bc.finishExpr[8, 0x1803, 0x1603]
    elseif s = "islocal" then
      bc.pushSize[8]
      self$exp.generate[bc]
      bc.addCode["SYS"]
      bc.addCode["ISLOCAL"]
      bc.addValue[2, 1]		% ISLOCAL takes two words of arguments.
      bc.popSize
      bc.finishExpr[8, 0x1803, 0x1603]
    elseif s = "codeof" then
      % Tell the line after this one to generate both the data for the
      % object in question and its concrete type object.
      bc.pushSize[8]
      self$exp.generate[bc]
      bc.popSize
      % Use the CODEOF bytecode so that the compiler doesn't have to worry
      % about whether we are using concrete types or abcons as the second part
      % of a variable.  
      % the stack.
      bc.addCode["CODEOF"]
      % Add the second thing for concrete types if necessary.
      bc.finishExpr[4, 0x1818, 0x1618]
    elseif s = "nameof" then
      Environment$env.SemanticError[self$ln, "Nameof should have been removed as sugar", nil]
    elseif s = "typeof" then
      Environment$env.SemanticError[self$ln, "Typeof should have been removed as sugar", nil]
    elseif s = "awaiting" then
      bc.pushSize[4]
      self$exp.generate[bc]
      bc.popSize
      bc.addCode["CONDAWAITING"]
      bc.finishExpr[4, 0x1806, 0x1606]
    elseif s = "syntactictypeof" then
      const expat <- exp.getAT
      bc.pushSize[4]
      expat.generate[bc]
      bc.popSize
      bc.finishExpr[4, 0x1809, 0x1609]
    else
      Environment$env.SemanticError[self$ln, "Illegal unaryexp name (%s)", {s}]
    end if
  end generate

  export function asString -> [r : String]
    r <- "unaryexp"
  end asString
end Unaryexp
