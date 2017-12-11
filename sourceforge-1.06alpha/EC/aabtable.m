const VectorOfAny <- Vector.of[Any]

const AABTable <- class AABTable [size : Integer]
  var currentsize : Integer <- size
  var lefts  : VectorOfAny <- VectorOfAny.create[currentsize]
  var rights : VectorOfAny <- VectorOfAny.create[currentsize]
  var count  : Integer <- 0

  export operation Insert [left : Any, right : Any]
    if count == currentsize then self.grow end if
    lefts[count] <- left
    rights[count] <- right
    count <- count + 1
  end Insert

  operation grow
    const oldrights <- rights
    const oldlefts   <- lefts
    const oldsize   <- currentsize

    currentsize <- currentsize * 2
    rights <- VectorOfAny.create[currentsize]
    lefts   <- VectorOfAny.create[currentsize]

    var h : Integer <- 0
    loop
      exit when h == count
      lefts[h] <- oldlefts[h]
      rights[h] <- oldrights[h]
      h <- h + 1
    end loop
  end grow

  export function Lookup [left : Any, right : Any] -> [answer : Boolean]
    var h : Integer <- 0
    loop
      exit when h = count
      if lefts[h] == left and right == rights[h] then
	answer <- true
	return
      end if
      h <- h + 1
    end loop
    answer <- false
  end Lookup

  export operation Forget[left : Any, right : Any]
    var h : Integer <- 0
    count <- count - 1
    loop
      exit when lefts[h] == left and rights[h] == right
      h <- h + 1
    end loop
    loop
      exit when h = count
      lefts[h] <- lefts[h + 1]
      rights[h] <- rights[h + 1]
      h <- h + 1
    end loop
  end Forget
end AABTable

export AABTable
