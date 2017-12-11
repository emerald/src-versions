const questinvoc <- class Questinvoc (Tree) [xxtarget : Tree, xxopname : Ident, xxargs : Tree]
    const ln : Integer  <- xxtarget$ln
    field target : Tree <- xxtarget
    field xopname : Ident <- xxopname
    field args  : Tree <- xxargs
    field nress : Integer <- 1

    export operation getIsNotManifest -> [r : Boolean]
      r <- true
    end getIsNotManifest
    export operation setIsNotManifest [r : Boolean]
      assert r
    end setIsNotManifest
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

    export function getnargs -> [r : Integer]
      if args == nil then
	r <- 0
      else
	r <- args.upperbound + 1
      end if
    end getnargs

    export operation copy [i : Integer] -> [newt : Tree]
      var ntarget, nargs : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if args !== nil then nargs <- args.copy[i] end if
      newt <- questinvoc.create[ln, ntarget, xopname, nargs]
    end copy

    export operation resolveSymbols [st : SymbolTable, nexp : Integer]
      nress <- nexp
      target.resolveSymbols[st, 1]
      if args !== nil then args.resolveSymbols[st, 1] end if
    end resolveSymbols

  export operation assignTypes
    FTree.assignTypes[self]
  end assignTypes

  function isSelf -> [r : Boolean] 
    const t <- nameof self$target

    if t = "aselflit" then
      r <- true
    elseif t = "asym" then
      const ts <- view self$target as Sym
      r <- ts$mySym$isSelf
    else
      r <- false
    end if
  end isSelf

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode

    var targetType, targetCT : Tree

    bc.lineNumber[self$ln]

    % We need to generate:
    % if typeof target *> typeobject with one operation end then
    %   regular invoke
    % else
    %   assert false
    % end if
%    for i : Integer <- 0 while i < self$nress by i <- i + 1
%      bc.addCode["PUSHNILV"]
%    end for

%    bc.pushSize[8]
%    if self$args !== nil then 
%      self$args.generate[xct]
%    end if
%    self$target.generate[xct]
%    bc.popSize

    begin
      var name : String <- xopname$name
      if self$args == nil then
        name <- name || "@0"
      else
	name <- name || "@" || (self$args.upperbound + 1).asString
      end if
      name <- name || "@" || self$nress.asString
%      bc.addValue[opnametooid.Lookup[name], 2]

      bc.addCode["LDIB"]
      bc.addValue[0, 1]
      bc.addCode["TRAPF"]
    end
  end generate

  export operation getAT -> [r : Tree]
    
  end getAT

  export operation getCT -> [r : Tree]
    
  end getCT

  export function asString -> [r : String]
    r <- "questinvoc"
  end asString
end Questinvoc

export Questinvoc
