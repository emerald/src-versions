const tpause <- object tpause
  process
    const here : Node <- locate 1

    for i : Integer <- 0 while i < 10 by i <- i + 1
      stdout.putstring["Pausing for "]
      stdout.putint[i, 0]
      stdout.putstring[" seconds\n"]
      stdout.flush
      here.delay[Time.create[i, 0]]
    end for
  end process
end tpause


const xer <- object xer
  process
    const here <- locate self
    const second <- Time.create[1, 0]
    
    for i : Integer <- 0 while i < 55 by i <- i + 1
      stdout.putstring["x\n"]
      here.delay[second]
    end for
  end process
end xer
