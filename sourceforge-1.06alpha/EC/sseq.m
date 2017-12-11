export SSeq

const VofT <- immutableVector.of[Tree]

const SSeq <- class SSeq(Tree)
  class export operation literal [xln : Integer, v : VofT] -> [r : SSeq]
    const limit <- v.upperbound
    r <- SSeq.create[xln]
    for i : Integer <- v.lowerbound while i <= limit by i <- i + 1
      r.rcons[v[i]]
    end for
  end literal
  class export operation singleton[t : Tree] -> [r : SSeq]
    r <- SSeq.create[t$ln]
    r.rcons[t]
  end singleton
  const ln : Integer <- 0
  var size : Integer <- 1
  var upb  : Integer <- ~1
  var space : vot <- vot.create[1]

  export function upperbound -> [r : Integer]
    r <- upb
  end upperbound

  export operation copy [how : Integer] -> [r : Tree]
    r <- SSeq.create[ln]
    for j : Integer <- 0 while j <= upb by j <- j + 1
      begin
	const s : Tree <- space[j]
	if s == nil then
	  r.rcons[nil]
	else
	  r.rcons[s.copy[how]]
	end if
      end
    end for
  end copy

  operation grow
    const newsize <- size * 2
    const newspace <- vot.create[newsize]
    var i : Integer <- 0
    loop
      exit when i >= size
      newspace[i] <- space[i]
      i <- i + 1
    end loop
    space <- newspace
    size  <- newsize
  end grow

  export operation lcons [a : Tree]
    upb <- upb + 1
    if upb = size then self.grow end if
    begin
      var i : Integer <- upb - 1
      loop
	exit when i < 0
	space[i+1] <- space[i]
	i <- i - 1
      end loop
      space[0] <- a
    end
  end lcons

  export operation rcons [a : Tree]
    upb <- upb + 1
    if upb = size then self.grow end if
    space[upb] <- a
  end rcons

  export operation rappend [a : Tree]
    if a$isseq then
      const aupb <- a.upperbound
      const nupb <- upb + aupb + 1
      loop
	exit when nupb < size
	self.grow
      end loop
      for i : Integer <- a.lowerbound while i <= aupb by i <- i + 1
	upb <- upb + 1
	space[upb] <- a[i]
      end for
    else
      upb <- upb + 1
      if upb = size then self.grow end if
      space[upb] <- a
    end if
  end rappend

  export function getElement [i : Integer] -> [r : Tree]
    r <- space[i]
  end getElement

  export operation setElement [i : Integer, r : Tree]
    space[i] <- r
  end setElement

  export operation doEnvExports [st : SymbolTable]
    for i : Integer <- 0 while i <= upb by i <- i + 1
      const s : Tree <- space[i]
      if s !== nil then
	s.doEnvExports[st]
      end if
    end for
  end doEnvExports

  export operation assignIds [st : SymbolTable]
    for i : Integer <- 0 while i <= upb by i <- i + 1
      const s : Tree <- space[i]
      if s !== nil then
	s.assignIds[st]
      end if
    end for
  end assignIds

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
    for i : Integer <- 0 while i <= upb by i <- i + 1
      const s : Tree <- space[i]
      if s !== nil and s$isNotManifest then
	r <- true
	return
      end if
    end for
  end getIsNotManifest

  export operation removeSugar [o : Tree] -> [r : Tree]
    r <- FTree.removeSugar[self, o]
    assert r == self
    var decls : Tree
    var it : Tree
    var rd : Integer <- 0
    const ospace : vot <- space
    const oupb <- upb
    upb <- -1
    loop
      exit when rd > oupb
      it, decls <- ospace[rd].flatten[false, nil]
      if decls !== nil then
	if ospace == space then self.grow end if
	const dupb <- decls.upperbound
	loop
	  exit when size > upb + dupb + 2
	  self.grow
	end loop
	for i : Integer <- 0 while i <= dupb by i <- i + 1
	  upb <- upb + 1
	  space[upb] <- decls[i]
	end for
      end if
      self.rcons[it]
      rd <- rd + 1
    end loop
  end removeSugar

  export operation typeCheck 
    var lastLineNumber : Integer <- 0
    for i : Integer <- 0 while i <= upb by i <- i + 1
      const it <- space[i]
      if it$ln != 0 then
	lastLineNumber <- it$ln
      else
	lastLineNumber <- lastLineNumber + 1
      end if
      const itsname <- nameof it
      if itsname = "aninvoc" or 
	  itsname = "astarinvoc" or 
	  itsname = "aquestinvoc" then
	const junk <- it.getAT
      elseif itsname = "anexp" or
	  itsname = "anunaryexp" or
	  itsname = "aliteral" or
	  itsname = "anxview" or
	  itsname = "anewexp" or
	  itsname = "asym" then
	Environment$env.SemanticError[lastLineNumber,
	  "Found an expression where a statement was expected", nil]
      end if
    end for
    FTree.typeCheck[self]
  end typeCheck

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    r <- self
    outdecls <- indecls
  end flatten

  export function getLN -> [r : Integer]
    r <- ln
  end getLN

  export function getIsSeq -> [r : Boolean]
    r <- true
  end getIsSeq

  export function asString -> [r : String]
    r <- "a statement sequence"
  end asString
end SSeq
