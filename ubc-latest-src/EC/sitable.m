const SITable <- class SITable [size : Integer]
    const voi <- Vector.of[Integer]
    const vos <- Vector.of[String]
    var currentsize : Integer <- size
    var values : voi <- voi.create[currentsize]
    var keys   : vos <- vos.create[currentsize]
    var count  : Integer <- 0
    var limit  : Integer <- (currentsize * 4) / 5

    operation iInsert [s : String, r : Integer]
      const first <- s.hash # currentsize
      var h : Integer <- first
      loop
	const k <- keys[h]
	if k == nil then
	  keys[h] <- s
	  values[h] <- r
	  return
	elseif s = k then
	  values[h] <- r
	  count <- count - 1
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
	exit when h = first
      end loop
    end iInsert

    operation enlarge
      const oldvalues <- values
      const oldkeys   <- keys
      const oldsize   <- currentsize

      currentsize <- currentsize * 2
      limit <- (currentsize * 4) / 5
      values <- voi.create[currentsize]
      keys   <- vos.create[currentsize]
      for i : Integer <- 0 while i < oldsize by i <- i + 1
	const k <- oldkeys[i]
	if k !== nil then
	  self.iInsert[k, oldvalues[i]]
	end if
      end for
    end enlarge

    export function Lookup [s : String] -> [r : Integer]
      var h : Integer <- s.hash # currentsize
      loop
	const k <- keys[h]
	if k == nil then
	  return
	elseif k = s then
	  r <- values[h]
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
      end loop
    end Lookup
    export operation Insert [s : String, r : Integer]
      count <- count + 1
      if count > limit then self.enlarge end if
      self.iInsert[s, r]
    end Insert
    export operation reset
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	keys[i] <- nil
      end for
      count <- 0
    end reset
end SITable

export SITable
