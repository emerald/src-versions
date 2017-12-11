
const test <- object test
  process
    var a, b: L_Directory <- L_Directory.create
    var g   : DirectoryGaggle <- DirectoryGaggle.create
    var n   : ImmutableVectorOfString<- ImmutableVectorOfString.create[25]

    (locate self)$stdout.PutString["I am here\n"]
    g.instantiate[a]
    g.instantiate[b]
    g.insert["one", "1"]
    g.insert["two", "2"]
    n<- g.list
    for i: Integer <- 0 while i <= n.upperBound by i <- i+1
	(locate self)$stdout.PutString[i.asString || " " || n[i] || "\n"]
    end for
    (locate self)$stdout.PutString["I am done\n"]
  end process
end test
