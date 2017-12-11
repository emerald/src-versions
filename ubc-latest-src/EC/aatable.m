const VectorOfAny <- Vector.of[Any]

const AATable <- class AATable [size : Integer]
  var currentsize : Integer <- size
  var keys   : VectorOfAny <- VectorOfAny.create[currentsize]
  var values : VectorOfAny <- VectorOfAny.create[currentsize]
  var count  : Integer <- 0

  export operation Insert [key : Any, value : Any]
    var h : Integer <- 0

    if count == currentsize then self.grow end if
    loop
      exit when h = count
      if keys[h] == key then
	values[h] <- value
	return
      end if
      h <- h + 1
    end loop
    count <- count + 1
    keys[h] <- key
    values[h] <- value
  end Insert

  operation grow
    const oldvalues <- values
    const oldkeys   <- keys
    const oldsize   <- currentsize

    currentsize <- currentsize * 2
    values <- VectorOfAny.create[currentsize]
    keys   <- VectorOfAny.create[currentsize]

    var h : Integer <- 0
    loop
      exit when h = count
      keys[h] <- oldkeys[h]
      values[h] <- oldvalues[h]
      h <- h + 1
    end loop
  end grow

  export function Lookup [key : Any] -> [value : Any]
    var h : Integer <- 0
    loop
      exit when h = count
      if keys[h] == key then
	value <- values[h]
	return
      end if
      h <- h + 1
    end loop
  end Lookup

  export operation Forget[key : Any]
    var h : Integer <- 0
    loop
      exit when h = count
      exit when keys[h] == key
      h <- h + 1
    end loop
    if h < count then
      count <- count - 1
      loop
	exit when h = count
	keys[h] <- keys[h + 1]
	values[h] <- values[h + 1]
	h <- h + 1
      end loop
      keys[h] <- nil
      values[h] <- nil
    end if
  end Forget
end AATable

export AATable
