export Eblock

const Eblock <- class Eblock (Tree) [xxstats : Tree, xxexp : Tree]
    field stats : Tree <- xxstats
    field exp  : Tree <- xxexp

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- stats
      elseif i = 1 then
	r <- exp
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	stats <- r
      elseif i = 1 then
	exp <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nstats, nexp : Tree
      if stats !== nil then nstats <- stats.copy[i] end if
      if exp !== nil then nexp <- exp.copy[i] end if
      r <- Eblock.create[ln, nstats, nexp]
    end copy

  export operation getAT -> [r : Tree]
    r <- exp.getAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- exp.getCT
  end getCT

  export operation generate [xct : Printable]
    stats.generate[xct]
    exp.generate[xct]
  end generate

  export function asString -> [r : String]
    r <- "Eblock"
  end asString
end Eblock
