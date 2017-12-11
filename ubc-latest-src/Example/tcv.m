const tcv <- object tcv
  initially
    const t <- VectorOfChar.create[10]
    var c : Character
    var s : String
    for i : Integer <- 0 while i < 10 by i <- i + 1
      t[i] <- Character.literal['0'.ord + i]
      c <- t[i]
      s <- c.asString
      stdout.putstring[s]
    end for
  end initially
end tcv
