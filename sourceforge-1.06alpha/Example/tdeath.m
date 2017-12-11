const dier <- monitor object dier
  export operation die 
    (locate self).Delay[Time.create[10,0]]
    assert false
  end die
  export operation try 
    var a : String <- "abc"
    var d : Integer <- 45
  end try
end dier

const driver <- object driver
  operation die 
    dier.die
    failure
      stdout.putstring["Driver caught a die failure\n"]
    end failure
  end die
  operation try 
    dier.try
    failure
      stdout.putstring["Driver caught a try failure\n"]
    end failure
  end try
  process
    self.die
    self.try
  end process
end driver

const driver2 <- object driver2
  operation die 
    dier.die
    failure
      stdout.putstring["Driver2 caught a die failure\n"]
    end failure
  end die
  operation try 
    dier.try
    failure
      stdout.putstring["Driver2 caught a try failure\n"]
    end failure
  end try
  process
    self.die
    self.try
  end process
end driver2

