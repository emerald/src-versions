const second <- object second
  initially
    var i : Integer
    const limit : Integer <- 10
    i <- 1
    loop
      exit when i > limit
      stdout.putstring[i.asString]
      stdout.putchar[' ']
      i <- i + 1
    end loop
    stdout.putchar['\n']
  end initially
end second
