const lots <- object lots
  export op foobar -> [a : Integer, b : Character, c : String]
    a <- 45
    b <- 'n'
    c <- "Hi there"
  end foobar
end lots

const tdotstar <- object tdotstar
  initially
    var x : Any
    var y : ImmutableVector.of[Any]
    x <- 45
    
    y <- lots.*"foobar"[nil]
    stdout.putint[y.upperbound + 1, 0]
    stdout.putchar['\n']
    for i : Integer <- 0 while i <= y.upperbound by i <- i + 1
      stdout.putstring[nameof y[i]]
      stdout.putchar['\n']
    end for

    y <- x.*"+"[{45:Any}]
    stdout.putint[view y[0] as Integer, 0]
    stdout.putchar['\n']

    begin
      y <- x.*"+"[{45.0:Any}]
      stdout.putint[view y[0] as Integer, 0]
      stdout.putchar['\n']
      failure
	stdout.putstring["Oops, I goofed...\n"]
      end failure
    end
  end initially
end tdotstar
