const foobar <- object foobar
  initially
    var x : Integer <- 34
    var y : Integer <- 45
  end initially

  process
    var z : Integer <- 6544
    var t : Integer <- 34
  end process

  recovery
    var a : Integer <- 34
    var b : Integer <- 233
  end recovery
end foobar
