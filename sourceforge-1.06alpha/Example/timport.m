const xx <- object xx
  const a : Integer <- 1 + 1
  const b : Integer <- 2 + 1
  const c : Integer <- 3 + 1
  const d : Integer <- 4 + 1
  initially
    const y <- object yy
      const x <- a
      initially
	const y <- b
      end initially
      operation foo 
	const z : integer <- c
	const zz <- object zz
	  operation foo 
	    const sjdkfjs <- d
	  end foo
	end zz
      end foo
    end yy
  end initially
  operation q 
    const m <- a
  end q
end xx
