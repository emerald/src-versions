const tcharacter <- object tcharacter
  const myTest <- runtest.create[stdin, stdout, "tcharacter"]
  initially
    var i, j : Character
    i <- '\^@'
    myTest.check[i = '\^@', "i = '\\^@'"]
    myTest.check[i == '\^@', "i == '\\^@'"]
    i <- 'd'
    j <- 'g'
    myTest.check[i = 'd', "i = 'd'"]
    myTest.check[i == 'd', "i == 'd'"]
    myTest.check[i.ord = 100, "i.ord = 100"]
    myTest.check[i.ord - 'a'.ord = 3, "i.ord - 'a'.ord = 3"]
    myTest.check[j.ord - 'a'.ord = 6, "j.ord - 'a'.ord = 6"]
    myTest.check[j > i, "j > i"]
    myTest.check[i < j, "i < j"]
    myTest.check[j >= i, "j >= i"]
    myTest.check[i <= j, "i <= j"]
    myTest.check[i != j, "i != j"]
    myTest.check[i.asString = "d", "i.asString = \"d\""]
    myTest.check[('\^@').asString = "\^@", "('\\^@').asString = \"\\^@\""]
    myTest.done
  end initially
end tcharacter
