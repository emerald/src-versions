const foo <- object foo
  process
    const m : matrix.of[String] <- matrix.of[String].create[3, 5, 16]
    for i : Integer <- 0 while i < 3 by i <- i + 1
      for j : Integer <- 0 while j < 5 by j <- j + 1
	for k : Integer <- 0 while k < 16 by k <- k + 1
	  m[i, j, k] <- i.asString || "x" || j.asString || "x" || k.asString
	end for
      end for
    end for

    for i : Integer <- 0 while i < 3 by i <- i + 1
      for j : Integer <- 0 while j < 5 by j <- j + 1
	for k : Integer <- 0 while k < 16 by k <- k + 1
	  assert m[i, j, k] = i.asString || "x" || j.asString || "x" || k.asString
	end for
      end for
    end for
  end process
end foo
