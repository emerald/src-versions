export StringStream

const StringStream <- class StringStream [xs : String]
  const x : String <- xs
  const limit : Integer <- x.upperbound
  var nextChar : Integer <- 0
  
  export function eos -> [r : Boolean]
    r <- nextChar > limit
  end eos
  
  export operation getChar -> [r : Character]
    if nextChar <= limit then
      r <- x[nextChar]
      nextChar <- nextChar + 1
    end if
  end getChar
  export operation fillVector[v : VectorofChar] -> [length : Integer]
    const offset <- nextChar
    loop
      exit when nextChar > limit
      exit when nextChar - offset > v.upperbound
      const c <- x[nextChar]
      v[nextChar - offset] <- c
      nextChar <- nextChar + 1
      exit when c = '\n'
    end loop
    length <- nextChar - offset
  end fillVector
end StringStream
