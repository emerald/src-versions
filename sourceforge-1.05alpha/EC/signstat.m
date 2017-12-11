export Signalstat

const signalstat <- class Signalstat (Tree) [xxexp : Tree]
  field useSignalAndExit : Integer <- -1
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
    r <- signalstat.create[ln, nexp]
  end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    const realob <- view ob as Monitorable
    if !realob$isMonitored then
      Environment.getEnv.SemanticError[ln, "Signal statements must be in monitored objects", nil]
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
      if useSignalAndExit >= 0 then      
	bc.addCode["CONDSIGNALANDEXIT"]
	bc.addValue[useSignalAndExit, 1]
      else
	bc.addCode["CONDSIGNAL"]
      end if
    end if
  end generate

  export function asString -> [r : String]
    r <- "signalstat"
  end asString
end Signalstat
