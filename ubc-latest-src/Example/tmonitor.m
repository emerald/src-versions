const first <- monitor object first
  var x : Integer
  const c <- Condition.create

  export operation foo 
    x <- x + 1
    signal c
  end foo
  export function bar -> [r : Integer]
    r <- x
    wait c
  end bar
  function junk -> [r : String]
    var x : Integer <- 56
    x <- awaiting c
  end junk

  initially
    x <- 5
  end initially

  process
    self.foo
  end process
end first
