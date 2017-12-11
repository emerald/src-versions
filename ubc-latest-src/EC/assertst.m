export Assertstat

const assertstat <- class Assertstat (Tree) [xxexp : Tree]
    const ln : Integer <- xxexp$ln

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
      r <- assertstat.create[ln, nexp]
    end copy

  export operation resolveSymbols[pst : SymbolTable, nexp : Integer]
    self$exp.resolveSymbols[pst, 1]
  end resolveSymbols

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    bc.lineNumber[self$ln]
    bc.pushSize[4]
    self$exp.generate[xct]
    bc.popSize
    bc.addCode["TRAPF"]
  end generate

  export function asString -> [r : String]
    r <- "assertstat"
  end asString
end Assertstat
