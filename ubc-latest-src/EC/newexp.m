export newexp

const newexp <- class Newexp (Tree) [xxexp : Tree, xxargs : Tree]
    field exp : Tree <- xxexp
    field args : Tree <- xxargs

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- exp
      elseif i = 1 then
	r <- args
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	exp <- r
      elseif i = 1 then
	args <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nexp, nargs : Tree
      if exp !== nil then nexp <- exp.copy[i] end if
      if args !== nil then nargs <- args.copy[i] end if
      r <- newexp.create[ln, nexp, nargs]
    end copy

  export operation getAT -> [r : Tree]
    const ct : Tree <- exp.execute
    if ct !== nil then
      r <- (view ct as hasInstAT)$instAT
    end if
  end getAT

  export operation getCT -> [r : Tree]
    const ct : Tree <- exp.execute
    if ct !== nil then
      r <- (view ct as hasInstCT)$instCT
    end if
  end getCT

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode

% The order of stuff on the stack for a creation is:
% NIL
% arguments for the initially - 8 bytes each
% Concrete type

    bc.addCode["PUSHNIL"]

    if self$args !== nil then
      bc.pushSize[8]
      self$args.generate[xct]
      bc.popSize
    end if

    bc.pushSize[4]
    self$exp.generate[bc]
    bc.popSize
%      if self$isVector then
%	bc.addCode["LDAS"]
%	bc.addValue[0, 2]
%	bc.addCode["CREATEVEC"]
%      else
%	bc.addCode["CREATE"]
%      end if
    bc.addCode["CREATE"]
    if bc$size != 4 then bc.addCode["PUSHCT"] end if
  end generate

  export function asString -> [r : String]
    r <- "newexp"
  end asString
end Newexp
