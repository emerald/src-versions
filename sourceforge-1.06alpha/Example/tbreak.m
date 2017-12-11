const xx <- object xx
  const yy <- object yy
    export operation foo [x : Integer , y : Character] -> [z : Real]
      var foobar : String <- "abc"
      z <- (x + y.ord).asReal
      assert false
    end foo
  end yy
  const x : Integer <- 34 + 56
  initially
    const t <- yy.foo[45, 'z']
  end initially
end xx
