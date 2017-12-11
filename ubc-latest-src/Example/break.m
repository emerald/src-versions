const xx <- object xx
  const x : Integer <- 34 + 56
  initially
    const t <- self.foo[45, 'z']
  end initially
  operation foo [x : Integer , y : Character] -> [z : Real]
    var foobar : String <- "abc"
    z <- (x + y.ord).asReal
    assert false
  end foo
end xx
