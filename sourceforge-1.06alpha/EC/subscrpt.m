export Subscript

const subscript <- class Subscript (Tree) [xxtarget : Tree, xxexp : Tree]
    field target : Tree <- xxtarget
    field exp : Tree <- xxexp

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- target
      elseif i = 1 then
	r <- exp
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	target <- r
      elseif i = 1 then
	exp <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var ntarget, nexp : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if exp !== nil then nexp <- exp.copy[i] end if
      r <- subscript.create[ln, ntarget, nexp]
    end copy
    export operation removeSugarOnLeft [a : Tree] -> [r : Tree]
      exp.rappend[a]
      r <- invoc.create[ln, target, OpName.Literal["setelement"], exp]
    end removeSugarOnLeft
    operation iremoveSugar -> [r : Tree]
      r <- invoc.create[ln, target, OpName.Literal["getelement"], exp]
    end iremoveSugar

  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- FTree.removeSugar[r, ob]
  end removeSugar

  export function asString -> [r : String]
    r <- "subscript"
  end asString
end Subscript
