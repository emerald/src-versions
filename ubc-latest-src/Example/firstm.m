const first <- object first
  var i : Integer <- 1

  initially
    const limit : Integer == 10
    const space <- " "
    const nl <- "\n"
    loop
      exit when i > limit
      self.foo[i]
      stdout.putstring[space]
      i <- i + 1
    end loop
    stdout.putstring[nl]
  end initially
  operation foo [x : Integer]
    const y <- x.asString
    stdout.putstring[y]
  end foo
end first
