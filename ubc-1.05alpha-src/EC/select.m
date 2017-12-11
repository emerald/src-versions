export Selection

const selection <- class Selection (Tree) [xxtarget : Tree, xxopname : Ident, xxargs : Tree]
    field target : Tree <- xxtarget
    field xopname : Ident <- xxopname
    field args  : Tree <- xxargs
    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- target
      elseif i = 1 then
	r <- args
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	target <- r
      elseif i = 1 then
	args <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var ntarget, nargs : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if args !== nil then nargs <- args.copy[i] end if
      r <- selection.create[ln, ntarget, xopname, nargs]
    end copy

  export function asString -> [r : String]
    r <- "selection"
  end asString
end Selection
