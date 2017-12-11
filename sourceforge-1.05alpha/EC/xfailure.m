export Xfailure

const xfailure <- class Xfailure (Tree) [xxbody : Tree]
    field body : Tree <- xxbody
    field st   : SymbolTable
    export function upperbound -> [r : Integer]
      r <- 0
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- body
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	body <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nbody : Tree
      if body !== nil then nbody <- body.copy[i] end if
      r <- xfailure.create[ln, nbody]
    end copy

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, CBlock]
    self$st$myTree <- self
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export function asString -> [r : String]
    r <- "xfailure"
  end asString
  
end Xfailure
