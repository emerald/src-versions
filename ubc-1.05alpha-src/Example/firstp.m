const first <- object first
  operation foo [x : Integer]
    const y <- x.asString
    stdout.putstring[y]
  end foo
  process
    var i : Integer <- 1
    const limit : Integer <- 10
    const space <- ' '
    const nl <- '\n'
    loop
      exit when i > limit
      self.foo[i]
      stdout.putchar[space]
      i <- i + 1
    end loop
    stdout.putchar[nl]
    stdout.flush
  end process
end first
