const tbitchunk <- object tbitchunk
  const myTest <- runtest.create[stdin, stdout, "tbitchunk"]
  initially
    % each test looks like myTest.check[<Boolean expression>, "<same exp>"]
    var i, j : BitChunk
    i <- BitChunk.create[12]
    j <- BitChunk.create[12]

    myTest.check[i = j, "i = j"]
    i[3, 1] <- 1
    myTest.check[!(i = j), "!(i = j)"]
    j <- BitChunk.create[11]
    myTest.check[!(i = j), "!(i = j)"]
    myTest.done
  end initially
end tbitchunk
