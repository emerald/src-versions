const tstrlit <- object tstrlit
  initially
    const x <- vectorofchar.create[10]
    var s : String
    x[0] <- 'a'
    x[1] <- 'b'
    x[2] <- 'c'
    s <- String.literal[x, 0, 3]
    stdout.putstring[s]
    stdout.putchar['\n']
  end initially
end tstrlit
