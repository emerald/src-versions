export Loopstat

const loopstat <- class Loopstat (Tree) [xxstats : Tree]
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
      r <- loopstat.create[ln, nstats]
    end copy

    export operation generate [xct : Printable]
      const bc <- view xct as ByteCode
      const top : Integer <- bc.declareLabel
      const bottom : Integer <- bc.declareLabel
      bc.defineLabel[top]
      if stats !== nil then
	bc.nest[bottom]
	stats.generate[xct]
	bc.unnest
      end if
      bc.addCode["BR"]
      bc.addLabelReference[top, 2]
      bc.defineLabel[bottom]
    end generate

  export operation defineSymbols[pst : SymbolTable]
    self$st <- SymbolTable.create[pst, CBlock]
    self$st$mytree <- self
    FTree.defineSymbols[self$st, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export function asString -> [r : String]
    r <- "loopstat"
  end asString
end Loopstat
