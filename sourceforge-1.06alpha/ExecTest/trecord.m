const rec <- record rec
  var i : Integer
  var c : Character
  var r : rectype
end rec

const trecord <- object trecord
  const myTest <- runtest.create[stdin, stdout, "trecord"]
  initially
    var r, r2 : rec
    r <- rec.create[5, 'a', nil]
    myTest.check[r$I = 5, "r$I = 5"]
    myTest.check[r$c = 'a', "r$c = 'a'"]
    myTest.check[r$r == nil, "r$r == nil"]
    r$i <- 35
    r$c <- '~'
    r2 <- rec.create[100, 'c', nil]
    r2 <- rec.create[99, 'b', r2]
    r$r <- r2
    myTest.check[r$I = 35, "r$I = 35"]
    myTest.check[r$c = '~', "r$c = '~'"]
    myTest.check[r$r !== nil, "r$r !== nil"]
    myTest.check[r$r$i = 99, "r$r$i = 99"]
    myTest.check[r$r$c = 'b', "r$r$c = 'b'"]
    myTest.check[r$r$r$i = 100, "r$r$r$i = 100"]
    myTest.check[r$r$r$c = 'c', "r$r$r$c = 'c'"]
    myTest.done
  end initially
end trecord
