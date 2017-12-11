const tif <- object tif
  initially
    var x, y : Integer
    x <- 0
    loop
      exit when x > 5
      if x = 1 then
	y <- 1
      elseif x = 2 then
	y <- 4
      elseif x = 3 then
	y <- 9
      elseif x = 4 then
	y <- 16
      else
	y <- 25
      end if
      stdout.putstring[y.asString]
      stdout.putchar['\n']
      x <- x + 1
    end loop
  end initially
end tif
