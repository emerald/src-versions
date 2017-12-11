export Arg

const arg <- class Arg (Tree) [xxexp : Tree]
% If doing move/visit
%    field isMove : Boolean <- false
%    field isVisit : Boolean <- false
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
      var narg : Arg
      if exp !== nil then nexp <- exp.copy[i] end if
      narg <- arg.create[ln, nexp]
% If doing move/visit
%      narg$isMove <- isMove
%      narg$isVisit <- isVisit
      r <- narg
    end copy

  export function asString -> [r : String]
    r <- "arg"
  end asString
end Arg
