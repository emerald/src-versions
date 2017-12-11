const tbigvec <- object tbigvec
  initially
    const voa <- Vector.of[Any]
    const xx <- voa.create[4]
  
    xx[0] <- "This is a string\n"
    stdout.putString[xx[0]]
  end initially
end tbigvec
