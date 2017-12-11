const IIBTable <- class IIBTable [size : Integer]
    const voi <- Vector.of[Integer]
    const vob <- Vector.of[Boolean]
    var currentsize : Integer <- size
    var keya : voi <- voi.create[currentsize]
    var keyb : voi <- voi.create[currentsize]
    var value: vob <- vob.create[currentsize]
    var count  : Integer <- 0
    var limit  : Integer <- (currentsize * 4) / 5

    operation iInsert [a:Integer,b:Integer,v:Boolean]
      const first <- (a + b).abs # currentsize
      var h : Integer <- first
      loop
	const ka <- keya[h]
	if ka == nil then
	  value[h] <- v
	  keya[h] <- a keyb[h] <- b
	  return
	elseif a = ka and b = keyb[h] then
	  value[h] <- v
	  count <- count - 1
	  return
	end if
	h <- (h + 1) # currentsize
	exit when h = first
      end loop
    end iInsert

    operation enlarge
      const oldkeya <- keya
      const oldkeyb <- keyb
      const oldvalue   <- value
      const oldsize   <- currentsize

      currentsize <- currentsize * 2
      limit <- (currentsize * 4) / 5
      keya <- voi.create[currentsize]
      keyb <- voi.create[currentsize]
      value   <- vob.create[currentsize]
      for i : Integer <- 0 while i < oldsize by i <- i + 1
	const ka <- oldkeya[i]
	if ka !== nil then
	  self.iInsert[ka, oldkeyb[i], oldvalue[i]]
	end if
      end for
    end enlarge

    export operation Lookup [a:Integer,b:Integer] -> [v:Boolean]
      var h : Integer <- (a + b).abs # currentsize
      loop
	const ka <- keya[h]
	if ka == nil then
	  return
	elseif ka = a and keyb[h] = b then
	  v <- value[h]
	  return
	end if
	h <- (h + 1) # currentsize
      end loop
    end Lookup

    export operation Insert [a:Integer,b:Integer,v:Boolean]
      count <- count + 1
      if count > limit then self.enlarge end if
      self.iInsert[a, b, v]
    end Insert

    export operation reset
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	keya[i] <- nil
      end for
      count <- 0
    end reset
end IIBTable

export IIBTable
