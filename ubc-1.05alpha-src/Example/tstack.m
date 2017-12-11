const lots <- object lots
  operation lots [ini : Integer]
    if ini > 0 then
      self.lots[ini - 1]
    end if
  end lots
  initially
    var i : Integer <- 1000
    self.lots[i]
  end initially
end lots
