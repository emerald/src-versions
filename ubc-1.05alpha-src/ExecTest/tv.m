const tv <- object tv
  const myTest <- runtest.create[stdin, stdout, "tv"]
  initially
    const voi <- Vector.of[Integer]
    const voc <- Vector.of[Character]
    const voa <- Vector.of[Any]
    const v <- voi.create[10]
    const vc<- voc.create[4]
    const va<- voa.create[6]
    vc[2] <- 'x'
    v[0] <- 87
    va[5] <- "abc"
    myTest.check[v.lowerbound = 0, "v.lowerbound = 0"]
    myTest.check[v.upperbound = 9, "v.upperbound = 9"]

    myTest.check[v[0] = 87, "v[0] = 87"]
    myTest.check[vc[2] = 'x', "vc[2] = 'x'"]
    myTest.check[(view va[5] as String) = "abc", "va[5] = \"abc\""]
    myTest.done
  end initially
end tv
