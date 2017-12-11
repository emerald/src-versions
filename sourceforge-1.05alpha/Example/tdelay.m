const tdelay1 <- object tdelay
  process
    const here <- locate self
    const one <- Time.create[1, 0]
    loop
      stdout.putstring["Delaying(1)..."]
      stdout.flush
      here.delay[one]
      stdout.putstring["\n"]
    end loop
  end process
end tdelay
const tdelay2 <- object tdelay
  process
    const here <- locate self
    const one <- Time.create[1, 0]
    here.delay[Time.create[0, 500000]]
    loop
      stdout.putstring["Delaying(2)..."]
      stdout.flush
      here.delay[one]
      stdout.putstring["\n"]
    end loop
  end process
end tdelay
