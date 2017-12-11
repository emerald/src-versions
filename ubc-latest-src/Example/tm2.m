const foo <- object foo
  process
    const m : matrix.of[String] <- matrix.of[String].create[3, 5]
    for i : Integer <- 0 while i < 3 by i <- i + 1
      for j : Integer <- 0 while j < 5 by j <- j + 1
	m[i, j] <- i.asString || "x" || j.asString
      end for
    end for

    for i : Integer <- 0 while i < 3 by i <- i + 1
      for j : Integer <- 0 while j < 5 by j <- j + 1
	assert m[i, j] = i.asString || "x" || j.asString
      end for
    end for
  end process
end foo
