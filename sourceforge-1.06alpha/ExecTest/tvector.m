const tvector <- object tvector
  const myTest <- runtest.create[stdin, stdout, "tvector"]
  initially
    const v <- { 4 }
    const w <- { }
    const y <- { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
    const z <- Vector.of[Integer].create[10]

    var i : Integer
    myTest.check[v.lowerbound = 0, "v.lowerbound = 0"]
    myTest.check[v.upperbound = 0, "v.upperbound = 0"]

    myTest.check[w.lowerbound = 0, "w.lowerbound = 0"]
    myTest.check[w.upperbound = ~1, "w.upperbound = ~1"]
    
    myTest.check[y.lowerbound = 0, "y.lowerbound = 0"]
    myTest.check[y.upperbound = 9, "y.upperbound = 9"]

    i <- 0
    loop
      exit when i > y.upperbound
      myTest.check[i = y[i], "y[i] = i (i = " || i.asString || ")"]
      i <- i + 1
    end loop

    i <- 0
    loop
      exit when i > y.upperbound
      z[i] <- y[i] * y[i] + y[i] + y[i]
      myTest.check[z[i] = i*i+i+i, "z[i] = i*i+i+i"]
      z[i] <- i * i + i + i
      myTest.check[z[i] = i*i+i+i, "z[i] = i*i+i+i"]
      i <- i + 1
    end loop

    const newthing <- ImmutableVectorOfInt.literal[z]
    i <- 0
    loop
      exit when i > newthing.upperbound
      myTest.check[newthing[i] = i*i+i+i, "newthing[i] = i*i+i+i"]
      i <- i + 1
    end loop
    
    myTest.done
  end initially
end tvector
