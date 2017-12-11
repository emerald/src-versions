const tarray <- object tarray
  const myTest <- runtest.create[stdin, stdout, "tarray"]
  initially
    const aoi <- Array.of[Integer]
    var a, b : aoi
    var i : Integer
    a <- aoi.empty
    myTest.check[a.lowerbound = 0, "a.lowerbound = 0"]
    myTest.check[a.upperbound = ~1, "a.upperbound = ~1"]

    a.addUpper[0]
    myTest.check[a.lowerbound = 0, "a.lowerbound = 0"]
    myTest.check[a.upperbound = 0, "a.upperbound = 0"]
    
    i <- 1
    loop
      exit when i >= 10
      a.addUpper[i]
      i <- i + 1
    end loop

    i <- 0
    loop
      exit when i >= 10
      myTest.check[a[i] = i, "a[i] = i"]
      i <- i + 1
    end loop

    b <- a.getSlice[4, 0]
    myTest.check[b.lowerbound = 4, "b.lowerbound = 4"]
    myTest.check[b.upperbound = 3, "b.upperbound = 3"]
    
    b <- a.getSlice[4, 5]
    myTest.check[b.lowerbound = 4, "b.lowerbound = 4"]
    myTest.check[b.upperbound = 8, "b.upperbound = 8"]
    i <- b.lowerbound
    loop
      exit when i > b.upperbound
      myTest.check[b[i] = i, "b[i] = i"]
      i <- i + 1
    end loop
    myTest.done
  end initially
end tarray
