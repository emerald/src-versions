export Elseclause

const elseclause <- class Elseclause (Tree) [xxstats : Tree]
    field stats : Tree <- xxstats
    field st  : SymbolTable

    export function upperbound -> [r : Integer]
      r <- 0
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- stats
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	stats <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nstats : Tree
      if stats !== nil then nstats <- stats.copy[i] end if
      r <- elseclause.create[ln, nstats]
    end copy

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, CBlock]
    self$st$myTree <- self
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export operation typeCheck 
    FTree.typeCheck[self]
  end typeCheck

  export function asString -> [r : String]
    r <- "elseclause"
  end asString
end Elseclause
