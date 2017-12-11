export Returnandfailstat

const returnandfailstat <- class Returnandfailstat (Tree)
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
    bc.addCode["RETFAIL"]
    bc.addValue[0, 1]		% WRONG
  end generate

  export function asString -> [r : String]
    r <- "returnandfailstat"
  end asString
end Returnandfailstat
