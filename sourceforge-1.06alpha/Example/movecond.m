const mon <- monitor object mon
  const c : Condition <- Condition.create
  export operation stop
    wait c
  end stop
  export operation go
    signal c
  end go
end mon

const delayed <- class delayed[name : String]
  process
    mon.stop
    stdout.putstring["Done " || name || "\n"]
  end process
end delayed

const driver <- object driver
  const d1 <- delayed.create["a"]
  process
    const here <- locate self
    const alive <- here.getActiveNodes

    here.delay[Time.create[1, 0]]
    
    move mon to alive[1]$theNode
    mon.go
  end process
end driver
