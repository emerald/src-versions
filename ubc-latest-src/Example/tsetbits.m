const tint <- object tint
  initially
    var x : Integer
    x <- (0).setBits[0, 32, -1]
    for i : Integer <- 0 while i < 32 by i <- i + 1
      for j : Integer <- 1 while j <= 32 - i by j <- j + 1
	stdout.putstring[x.getBits[i, j].asString || "\n"]
      end for
    end for
  end initially
end tint
