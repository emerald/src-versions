export Movestat

const movestat <- class Movestat (Tree) [xxexp : Tree, xxloc : Tree, xxop : Ident]
    field exp : Tree <- xxexp
    field loc : Tree <- xxloc
    field xop : Ident <- xxop

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- exp
      elseif i = 1 then
	r <- loc
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	exp <- r
      elseif i = 1 then
	loc <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nexp, nloc : Tree
      if exp !== nil then nexp <- exp.copy[i] end if
      if loc !== nil then nloc <- loc.copy[i] end if
      r <- movestat.create[ln, nexp, nloc, xop]
    end copy

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    exp, outdecls <- exp.flatten[true, indecls]
    if loc !== nil then loc, outdecls <- loc.flatten[true, outdecls] end if
    r <- self
  end flatten

  export operation resolveSymbols[thest : SymbolTable, nexp : Integer]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.resolveSymbols[thest, 1]
      end if
      ch <- ch + 1
    end loop
  end resolveSymbols

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode

    const s : String <- xop$name
    bc.pushSize[8]
    exp.generate[bc]
    if s != "unfix" then
      loc.generate[bc]
    end if
    bc.popSize
    bc.addCode["SYS"]
    if s = "move" then
      bc.addCode["JMOVE"]
    elseif s = "fix" then
      bc.addCode["JFIX"]
    elseif s = "unfix" then
      bc.addCode["JUNFIX"]
    elseif s = "refix" then
      bc.addCode["JREFIX"]
    else
      assert false
    end if
    if s = "unfix" then
      bc.addValue[2, 1]		% one argument, two words
    else
      bc.addValue[4, 1]		% two arguments, four words
    end if
  end generate

  export function asString -> [r : String]
    r <- xop$name||"stat"
  end asString
end Movestat
