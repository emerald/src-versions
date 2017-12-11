export Waitstat

const waitstat <- class Waitstat (Tree) [xxexp : Tree]
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
    var nexp : Tree <- exp
    if exp !== nil then nexp <- exp.copy[i] end if
    r <- waitstat.create[ln, nexp]
  end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    const realob <- view ob as Monitorable
    if !realob$isMonitored then
      Environment.getEnv.SemanticError[ln, "Wait statements must be in monitored objects", nil]
    end if
    r <- FTree.removeSugar[self, ob]
  end removeSugar

  export operation generate [xct : Printable]
    if Environment$env$generateconcurrent then
      const bc <- view xct as ByteCode
      bc.lineNumber[ln]
      bc.pushSize[4]
      exp.generate[xct]
      bc.popSize
      bc.addCode["CONDWAIT"]
    end if
  end generate

  export function asString -> [r : String]
    r <- "waitstat"
  end asString
end Waitstat
