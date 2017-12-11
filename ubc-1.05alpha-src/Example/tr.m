const tr <- object tr
  function foo -> [r : Integer]
    r <- 45
  end foo
  function bar -> [r : Integer]
    const x <- 34
    primitive [r] <- [x]
  end bar
  initially
    var i : Any
    i <- self.foo
    i <- self.bar
  end initially
end tr
