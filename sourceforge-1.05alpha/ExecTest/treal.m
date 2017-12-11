const treal <- object treal
  const myTest <- runtest.create[stdin, stdout, "treal"]
  initially
    % each test looks like b <- b and <boolean expression>
    var i, j : Real
    i <- 0.0
    myTest.check[i = 0.0, "i = 0.0"]
    myTest.check[i == 0.0, "i == 0.0"]
    i <- 4.0
    j <- 7.0
    myTest.check[i = 4.0, "i = 4.0"]
    myTest.check[i == 4.0, "i == 4.0"]
    myTest.check[i + j = 11.0, "i + j = 11.0"]
    myTest.check[j + i = 11.0, "j + i = 11.0"]
    myTest.check[i - j = ~3.0, "i - j = ~3.0"]
    myTest.check[j - i = 3.0, "j - i = 3.0"]
    myTest.check[i * j = 28.0, "i * j = 28.0"]
    myTest.check[j * i = 28.0, "j * i = 28.0"]
    myTest.check[j * 0.0 = 0.0, "j * 0.0 = 0.0"]
    myTest.check[j * ~1.0 = ~7.0, "j * ~1.0 = ~7.0"]
    myTest.check[j / i = 1.75, "j / i = 1.75"]
    myTest.check[i / 2.0 = 2.0, "i / 2.0 = 2.0"]
    myTest.check[~5.0 / 2.0 = ~2.5, "~5.0 / 2.0 = ~2.5"]
    myTest.check[4.0 ^ 0.5 = 2.0, "4.0 ^ 2.0 = 2.0"]

    myTest.check[self.null[i] = 4.0, "self.null[i] = 4.0"]
    myTest.check[self.null[i] == 4.0, "self.null[i] == 4.0"]
    myTest.check[self.null[i + j] = 11.0, "self.null[i + j] = 11.0"]
    myTest.check[self.null[j + i] = 11.0, "self.null[j + i] = 11.0"]
    myTest.check[self.null[i - j] = ~3.0, "self.null[i - j] = ~3.0"]
    myTest.check[self.null[j - i] = 3.0, "self.null[j - i] = 3.0"]
    myTest.check[self.null[i * j] = 28.0, "self.null[i * j] = 28.0"]
    myTest.check[self.null[j * i] = 28.0, "self.null[j * i] = 28.0"]
    myTest.check[self.null[j * 0.0] = 0.0, "self.null[j * 0.0] = 0.0"]
    myTest.check[self.null[j * ~1.0] = ~7.0, "self.null[j * ~1.0] = ~7.0"]
    myTest.check[self.null[j / i] = 1.75, "self.null[j / i] = 1.75"]
    myTest.check[self.null[i / 2.0] = 2.0, "self.null[i / 2.0] = 2.0"]
    myTest.check[self.null[~5.0 / 2.0] = ~2.5, "self.null[~5.0 / 2.0] = ~2.5"]

    myTest.check[j > i, "j > i"]
    myTest.check[i < j, "i < j"]
    myTest.check[j >= i, "j >= i"]
    myTest.check[i <= j, "i <= j"]
    myTest.check[i != j, "i != j"]
    myTest.check[i.asString = "4", "i.asString = \"4\""]
    myTest.check[i.asInteger = 4, "i.asInteger = 4"]
    myTest.check[Real.literal["3.14"] = 3.14, "Real.literal[\"3.14\"] = 3.14"]
    myTest.done
  end initially
  function null [i : Real] -> [j : Real]
    j <- i
  end null
end treal
