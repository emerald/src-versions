const mon <- monitor object mon
  export operation delay 
    (locate self).delay[Time.create[5, 0]]
  end delay
end mon

const delayed <- class delayed[name : String]
  process
    mon.delay
    stdout.putstring["Done " || name || "\n"]
  end process
end delayed

const driver <- object driver
  const d1 <- delayed.create["a"]
  const d2 <- delayed.create["b"]
  process
    const here <- locate self
    const alive <- here.getActiveNodes

    here.delay[Time.create[1, 0]]
    
    move mon to alive[1]$theNode
  end process
end driver
