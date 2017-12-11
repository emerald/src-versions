const lots <- object lots
  initially
    var i : Integer
    var c : Character
    i, c <- self.lots[0x1000, 'a']
  end initially
  operation lots [ini : Integer, inc : Character] -> [outi : Integer, outc : Character]
    outi <- ini + 10
    outc <- inc
  end lots
end lots
