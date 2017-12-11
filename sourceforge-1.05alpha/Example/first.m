const first <- object first
  const limit : Integer <- 10
  initially
    var i : Integer <- 1
    const space <- " "
    const nl <- "\n"
    loop
      exit when i > limit
      self.foobaz[i]
      stdout.putstring[space]
      i <- i + 1
    end loop
    stdout.putstring[nl]
    stdout.flush
  end initially
  operation foobaz [x : Integer]
    const y <- x.asString
    stdout.putstring[y]
  end foobaz
end first
