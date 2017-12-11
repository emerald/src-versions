const foo <- object foo
  initially
    const foobar <- Character.literal[0377]
    const v <- vectorofchar.create[10]
    var j : Integer <- 2
    var s : String
    v[0] <- 'a'
    v[1] <- 'b'
    s <- String.fliteral[v, 0, j - 1]
  end initially
end foo
