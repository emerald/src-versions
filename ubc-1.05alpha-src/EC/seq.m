export Seq

const VofT <- immutableVector.of[Tree]

const Seq <- class Seq(Tree)
  class export operation literal [xln : Integer, v : VofT] -> [r : Seq]
    const limit <- v.upperbound
    r <- Seq.create[xln]
    for i : Integer <- v.lowerbound while i <= limit by i <- i + 1
      r.rcons[v[i]]
    end for
  end literal
  class export operation singleton[t : Tree] -> [r : Seq]
    r <- Seq.create[t$ln]
    r.rcons[t]
  end singleton
  class export operation pair[t : Tree, u : Tree] -> [r : Seq]
    r <- Seq.create[t$ln]
    r.rcons[t]
    r.rcons[u]
  end pair
  const ln : Integer <- 0
    var size : Integer <- 1
    var upb  : Integer <- ~1
    var space : vot <- vot.create[1]

    export function upperbound -> [r : Integer]
      r <- upb
    end upperbound

    export operation copy [how : Integer] -> [r : Tree]
      r <- seq.create[ln]
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


  export function getLN -> [r : Integer]
    r <- ln
  end getLN

  export function getIsSeq -> [r : Boolean]
    r <- true
  end getIsSeq

  export function asString -> [r : String]
    r <- "a sequence"
  end asString
end Seq
