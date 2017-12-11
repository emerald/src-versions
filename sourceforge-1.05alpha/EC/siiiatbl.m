const SIIIATable <- class SIIIATable [size : Integer]
    const voi <- Vector.of[Integer]
    const vos <- Vector.of[String]
    const voa <- Vector.of[Any]
    var currentsize : Integer <- size
    var valuea : voi <- voi.create[currentsize]
    var valueb : voi <- voi.create[currentsize]
    var valuec : voi <- voi.create[currentsize]
    var valued : voa <- voa.create[currentsize]
    var values : vos <- vos.create[currentsize]
    var keys   : vos <- vos.create[currentsize]
    var count  : Integer <- 0
    var limit  : Integer <- (currentsize * 4) / 5

    operation iInsert [s : String, a:Integer,b:Integer,c:Integer,fn : String, d:Any]
      const first <- s.hash # currentsize
      var h : Integer <- first
      loop
	const k <- keys[h]
	if k == nil then
	  keys[h] <- s
	  valuea[h] <- a valueb[h] <- b valuec[h] <- c valued[h] <- d values[h] <- fn
	  return
	elseif s = k then
	  valuea[h] <- a valueb[h] <- b valuec[h] <- c valued[h] <- d values[h] <- fn
	  count <- count - 1
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
	exit when h = first
      end loop
    end iInsert

    operation enlarge
      const oldvaluea <- valuea
      const oldvalueb <- valueb
      const oldvaluec <- valuec
      const oldvalued <- valued
      const oldvalues <- values
      const oldkeys   <- keys
      const oldsize   <- currentsize

      currentsize <- currentsize * 2
      limit <- (currentsize * 4) / 5
      valuea <- voi.create[currentsize]
      valueb <- voi.create[currentsize]
      valuec <- voi.create[currentsize]
      valued <- voa.create[currentsize]
      values <- vos.create[currentsize]
      keys   <- vos.create[currentsize]
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	const k <- keys[i]
	if k !== nil then
	  self.iInsert[k, valuea[i],valueb[i],valuec[i],values[i],valued[i]]
	end if
      end for
    end enlarge

    export operation Lookup [s : String] -> [a:Integer,b:Integer,c:Integer,fn : String, d:Any]
      var h : Integer <- s.hash # currentsize
      loop
	const k <- keys[h]
	if k == nil then
	  return
	elseif k = s then
	  a <- valuea[h] b <- valueb[h] c <- valuec[h] d <- valued[h] fn <- values[h]
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
      end loop
    end Lookup
    export operation Insert [s : String, a:Integer,b:Integer,c:Integer, fn : String, d:Any]
      count <- count + 1
      if count > limit then self.enlarge end if
      self.iInsert[s, a, b, c, fn, d]
    end Insert
    export operation reset
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	keys[i] <- nil
      end for
      count <- 0
    end reset
    export operation resetForSourceFile[fn : String]
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	if keys[i] !== nil and values[i] = fn then
	  valued[i] <- nil
	end if
      end for
    end resetForSourceFile
end SIIIATable

export SIIIATable
