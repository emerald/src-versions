export Returnstat

const returnstat <- class Returnstat (Tree)
    export function upperbound -> [r : Integer]
      r <- ~1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
    end getElement
    export operation setElement [i : Integer, r : Tree]
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      r <- self
    end copy

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    const nb <- bc.nestBase
    bc.lineNumber[self$ln]
    bc.addCode["BR"]
    bc.addLabelReference[nb, 2]
  end generate

  export function asString -> [r : String]
    r <- "returnstat"
  end asString
end Returnstat
