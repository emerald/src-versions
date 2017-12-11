const final <- object final
  export operation sleep [n : Integer]
    (locate self).delay[Time.create[n, 0]]
  end sleep
end final

const tbreakme <- object tbreakme
  export operation passthrough 
    final.sleep[4]
  end passthrough

  export operation stayhere 
    loop
    end loop
  end stayhere

  export operation die 
    primitive self "BREAKME" [] <- []
  end die
end tbreakme

const driver <- object driver
  const junk1 <- object j1
    process
      tbreakme.passthrough
    failure
      stdout.putstring["j1 caught failure\n"]
    end failure
    end process
  end j1
  const junk2 <- object j2
    process
      tbreakme.passthrough
    failure
      stdout.putstring["j2 caught failure\n"]
    end failure
    end process
  end j2
  const junk3 <- object j3
    process
      tbreakme.stayhere
    failure
      stdout.putstring["j3 caught failure\n"]
    end failure
    end process
  end j3
  const junk4 <- object j4
    process
      tbreakme.stayhere
    failure
      stdout.putstring["j4 caught failure\n"]
    end failure
    end process
  end j4
  const junk5 <- object j5
    process
      (locate self).delay[Time.create[2, 0]]
      tbreakme.die
    failure
      stdout.putstring["j5 caught failure\n"]
    end failure
    end process
  end j5
end driver
