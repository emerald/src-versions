const ISet <- class ISet [size : Integer]
    const voi <- Vector.of[Integer]
    var currentsize : Integer <- size
    var keys   : voi <- voi.create[currentsize]
    var count  : Integer <- 0
    var limit  : Integer <- (currentsize * 4) / 5

    operation iAdd [s : Integer]
      const first <- s.hash # currentsize
      var h : Integer <- first
      loop
	const k <- keys[h]
	if k == nil then
	  keys[h] <- s
	  return
	elseif s = k then
	  count <- count - 1
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
	exit when h = first
      end loop
    end iAdd

    operation enlarge
      const oldkeys   <- keys
      const oldsize   <- currentsize

      currentsize <- currentsize * 2
      limit <- (currentsize * 4) / 5
      keys   <- voi.create[currentsize]

      for i : Integer <- 0 while i < oldsize by i <- i + 1
	const k <- oldkeys[i]
	if k !== nil then
	  self.iAdd[k]
	end if
      end for
    end enlarge

    export function Includes [s : Integer] -> [r : Boolean]
      var h : Integer <- s.hash # currentsize
      r <- false
      loop
	const k <- keys[h]
	if k == nil then
	  return
	elseif k = s then
	  r <- true
	  return
	end if
	h <- h + 1
	if h >= currentsize then h <- 0 end if
      end loop
    end Includes

    export operation Add [s : Integer]
      count <- count + 1
      if count > limit then self.enlarge end if
      self.iAdd[s]
    end Add

    export operation reset
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	keys[i] <- nil
      end for
      count <- 0
    end reset
end ISet

export ISet
