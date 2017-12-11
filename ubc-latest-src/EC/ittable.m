const envtype <- typeobject envtype
  operation printf [String, RISA]
end envtype

const Environment <- immutable object Environment
  export operation getenv -> [env : envtype]
    primitive var "GETENV" [env] <- []
  end getenv
end Environment


const ITTable <- class ITTable [size : Integer]
    const voi <- Vector.of[Integer]
    const vot <- Vector.of[Tree]

    var currentsize : Integer <- size
    var keys   : voi <- voi.create[currentsize]
    var values : vot <- vot.create[currentsize]
    var count  : Integer <- 0
    var limit  : Integer <- (currentsize * 4) / 5

    operation iInsert [s : Integer, r : Tree]
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

      currentsize <- currentsize * 2 + 1
      limit <- (currentsize * 4) / 5
      values <- vot.create[currentsize]
      keys   <- voi.create[currentsize]

      for i : Integer <- 0 while i < oldsize by i <- i + 1
	const k <- oldkeys[i]
	if k !== nil then
	  self.iInsert[k, oldvalues[i]]
	end if
      end for
    end enlarge

    export function Lookup [s : Integer] -> [r : Tree]
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

    export operation Insert [s : Integer, r : Tree]
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
    
    export operation okForNextOID [id : Integer]
      for i : Integer <- 0 while i < currentsize by i <- i + 1
	if keys[i] !== nil and keys[i] >= id then
	  Environment$env.printf["You can't start OID allocation at %d\n", {id}]
	  Environment$env.printf["Objects with higher ids already exist\n", nil]
	  const exitStatus <- 1
	  primitive "NCCALL" "MISK" "UEXIT" [] <- [exitStatus]
	end if
      end for
    end okForNextOID
end ITTable

export ITTable
