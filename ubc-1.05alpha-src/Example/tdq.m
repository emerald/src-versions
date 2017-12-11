const lots <- object lots
  export op foobar -> [a : Integer, b : Character, c : String]
    a <- 45
    b <- 'n'
    c <- "Hi there"
  end foobar
end lots

const tdotquestion <- object tdotquestion
  initially
    var x : Any
    var y : Character
    var z : String
    x <- 45
    
    x, y, z <- lots.?foobar
    stdout.putstring[nameof x]
    stdout.putchar['\n']
    stdout.putstring[nameof y]
    stdout.putchar['\n']
    stdout.putstring[nameof z]
    stdout.putchar['\n']

    z, y, z <- lots.?foobar

    failure
      stdout.putstring["Oops, I goofed...\n"]
    end failure
  end initially
end tdotquestion
