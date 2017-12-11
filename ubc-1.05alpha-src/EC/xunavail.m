export Xunavail

const xunavail <- class Xunavail (Tree) [xxdecl : Tree, xxbody : Tree]
    field decl : Tree <- xxdecl
    field body : Tree <- xxbody
    field st   : SymbolTable
    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- decl
      elseif i = 1 then
	r <- body
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	decl <- r
      elseif i = 1 then
	body <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var ndecl, nbody : Tree
      if decl !== nil then ndecl <- decl.copy[i] end if
      if body !== nil then nbody <- body.copy[i] end if
      r <- xunavail.create[ln, ndecl, nbody]
    end copy

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, CUnavailableHandler]
    self$st$myTree <- self
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export function asString -> [r : String]
    r <- "xunavail"
  end asString

  export operation generate [xct : Printable]
    body.generate[xct]
  end generate
end Xunavail
