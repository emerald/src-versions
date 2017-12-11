const tinteger <- object tinteger
  const myTest <- runtest.create[stdin, stdout, "tinteger"]
  initially
    self.doit[]
  end initially
  operation doit
    var i, j : Integer
    i <- 0
    myTest.check[i = 0, "i = 0"]
    myTest.check[i == 0, "i == 0"]
    i <- 4
    j <- 7
    myTest.check[i = 4, "i = 4"]
    myTest.check[i == 4, "i == 4"]
    myTest.check[i + j = 11, "i + j = 11"]
    myTest.check[j + i = 11, "j + i = 11"]
    myTest.check[i - j = ~3, "i - j = ~3"]
    myTest.check[j - i = 3, "j - i = 3"]
    myTest.check[i * j = 28, "i * j = 28"]
    myTest.check[j * i = 28, "j * i = 28"]
    myTest.check[j * 0 = 0, "j * 0 = 0"]
    myTest.check[j * ~1 = ~7, "j * ~1 = ~7"]
    myTest.check[i / j = 0, "i / j = 0"]
    myTest.check[j / i = 1, "j / i = 1"]
    myTest.check[i / 2 = 2, "i / 2 = 2"]
    myTest.check[j / 3 = 2, "j / 3 = 2"]
    myTest.check[~5 / 2 = ~2, "~5 / 2 = ~2"]
    myTest.check[i # j = 4, "i # j = 4"]
    myTest.check[j # i = 3, "j # i = 3"]
    myTest.check[~5 # 2 = ~1, "~5 # 2 = ~1"]
    myTest.check[(13 & 7) = 5, "13 & 7 = 5"]
    myTest.check[(13 | 7) = 15, "13 | 7 = 15"]
    myTest.check[0 .setBit[5, true].getBit[27] = false, "0.setBit[5, true].getBit[27] = false"]
    myTest.check[0 .setBit[5, true].getBit[26] = false, "0.setBit[5, true].getBit[26] = false"]
    myTest.check[0 .setBit[5, true].getBit[4] = false, "0.setBit[5, true].getBit[4] = false"]
    myTest.check[0 .setBit[5, true].getBit[6] = false, "0.setBit[5, true].getBit[6] = false"]
    myTest.check[0 .setBit[5, true].getBit[5] = true, "0.setBit[5, true].getBit[4] = true"]

    myTest.check[0 .setBits[5, 2, 3].getBits[5, 2] = 3, "0.setBits[5, 2, 3].getBits[5, 2] = 3"]
    myTest.check[0 .setBits[5, 2, 3].getBits[4, 2] != 0, "0.setBits[5, 2, 3].getBits[4, 2] != 0"]
    myTest.check[0 .setBits[5, 2, 3].getBits[6, 2] != 0, "0.setBits[5, 2, 3].getBits[6, 2] != 0"]
    myTest.check[0 .setBits[5, 2, 3].getBits[0, 5] = 0, "0.setBits[5, 2, 3].getBits[0, 5] = 0"]
    myTest.check[0 .setBits[5, 2, 3].getBits[7, 25] = 0, "0.setBits[5, 2, 3].getBits[7, 25] = 0"]
    myTest.check[0 .setBits[5, 2, 3].setBit[6, false].getBits[5, 2] != 3, "0.setBits[5, 2, 3].setBit[6, false].getBits[5, 2] != 3"]
    myTest.check[0 .setBits[5, 2, 3].setBits[6, 1, 0].getBits[5, 2] != 3, "0.setBits[5, 2, 3].setBits[6, 1, 0].getBits[5, 2] != 3"]

    myTest.check[self.null[i] = 4, "self.null[i] = 4"]
    myTest.check[self.null[i] == 4, "self.null[i] == 4"]
    myTest.check[self.null[i + j] = 11, "self.null[i + j] = 11"]
    myTest.check[self.null[j + i] = 11, "self.null[j + i] = 11"]
    myTest.check[self.null[i - j] = ~3, "self.null[i - j] = ~3"]
    myTest.check[self.null[j - i] = 3, "self.null[j - i] = 3"]
    myTest.check[self.null[i * j] = 28, "self.null[i * j] = 28"]
    myTest.check[self.null[j * i] = 28, "self.null[j * i] = 28"]
    myTest.check[self.null[j * 0] = 0, "self.null[j * 0] = 0"]
    myTest.check[self.null[j * ~1] = ~7, "self.null[j * ~1] = ~7"]
    myTest.check[self.null[i / j] = 0, "self.null[i / j] = 0"]
    myTest.check[self.null[j / i] = 1, "self.null[j / i] = 1"]
    myTest.check[self.null[i / 2] = 2, "self.null[i / 2] = 2"]
    myTest.check[self.null[j / 3] = 2, "self.null[j / 3] = 2"]
    myTest.check[self.null[~5 / 2] = ~2, "self.null[~5 / 2] = ~2"]
    myTest.check[self.null[i # j] = 4, "self.null[i # j] = 4"]
    myTest.check[self.null[j # i] = 3, "self.null[j # i] = 3"]
    myTest.check[self.null[~5 # 2] = ~1, "self.null[~5 # 2] = ~1"]

    myTest.check[j > i, "j > i"]
    myTest.check[i < j, "i < j"]
    myTest.check[j >= i, "j >= i"]
    myTest.check[i <= j, "i <= j"]
    myTest.check[i != j, "i != j"]
    myTest.check[i.asString = "4", "i.asString = \"4\""]
    myTest.check[i.asReal = 4.0, "i.asReal = 4.0"]
    myTest.check[0x40000000 + 0x40000000 = 0x80000000, "0x40000000 + 0x40000000 = 0x80000000"]
    myTest.done
  end doit
  function null [i : Integer] -> [j : Integer]
    j <- i
  end null
end tinteger
