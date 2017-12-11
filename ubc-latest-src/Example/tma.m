const tma <- object tma
  export operation one -> [r : Integer]
  end one
  process
    var a, b : Integer
    a, b <- 3, 4
    a, b <- 3, self.one
  end process
end tma
