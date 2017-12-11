const tveclit <- object tveclit
  initially
    const t : ImmutableVector.of[Integer] <- { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
    const y <- { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l' }
    var i : Integer
    var x : Integer
    var c : Character
    i <- 0
    loop
      exit when i > t.upperbound
      x <- t[i]
      stdout.putString[x.asString]
      stdout.putChar[' ']
      c <- y[i]
      stdout.putChar[c]
      stdout.putChar['\n']
      i <- i + 1
    end loop
  end initially
end tveclit
