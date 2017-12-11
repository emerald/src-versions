const tstring <- object tstring
  const myTest <- runtest.create[stdin, stdout, "tstring"]
  initially
    var i, j : String
    i <- "\^@"
    myTest.check[i = "\^@", "i = \"\\^@\""]
    i <- "abcdef"
    j <- "ghi"
    myTest.check[i = "abcdef", "i = \"abcdef\""]
    myTest.check[i[3] = 'd', "i[3] = 'd'"]
    myTest.check[i != j, "i != j"]
    myTest.check[i.length = 6, "i.length = 6"]
    myTest.check[j.length = 3, "j.length = 3"]
    myTest.check["".length = 0, "\"\".length = 0"]
    myTest.check[i = i, "i = i"]
    myTest.check[i == i, "i == i"]
    myTest.check[j > i, "j > i"]
    myTest.check[i < j, "i < j"]
    myTest.check[j >= i, "j >= i"]
    myTest.check[i <= j, "i <= j"]
    myTest.check[i != j, "i != j"]
    myTest.check[i.asString = i, "i.asString = i"]
    myTest.check[("\^@").asString = "\^@", "(\"\\^@\").asString = \"\\^@\""]
    myTest.check[self.id[i] == i, "self.id[i] == i"]
    myTest.check[self.id[i] = i, "self.id[i] = i"]
    myTest.check["abcde".getslice[0,3] = "abc", "\"abcde\".getslice[0,3] = \"abc\""]
    myTest.check["abcde" || "fghij" = "abcdefghij", "\"abcde\" || \"fghij\" = \"abcdefghij\""]
    myTest.done
  end initially
  function id [s : String] -> [r : String]
    r <- s
  end id
end tstring
