const xxx <- ImmutableVector.of[Integer]
const tveclit <- object tveclit
  initially
    const one <- 1
    const two <- 2
    const three <- 3
    var t : xxx <- { one, two, three }
    var i : Integer
    var x : Integer
    i <- 0
    loop
      exit when i > t.upperbound
      x <- t[i]
      stdout.putString[x.asString]
      stdout.putChar['\n']
      i <- i + 1
    end loop
  end initially
end tveclit
