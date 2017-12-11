const foo <- object foo
  var prev : Integer <- 0
  var min : Integer <- 10000000000000
  var now : Integer <- 99999

  operation f -> [result : Integer]
    if now - prev < min then
      min <- now - prev
      stdout.putstring["Min is "]
      stdout.putint[min, 1]
      stdout.putchar['\n']
      result <- 1
    else
      result <- 0
    end if
    prev <- now
  end f

  process
    for i : Integer<- 0 while i < 2234954 by  i <- i +1
      const junk <- self.f
    end for
  end process
end foo
