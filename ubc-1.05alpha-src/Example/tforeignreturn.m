const A <- object A
  export operation sleep [n : Integer] -> [m : Integer]
    const here <- locate self
    stdout.putstring["Sleeping\n"]
    here.delay[Time.create[n, 0]]
    stdout.putstring["Sleeping done\n"]
    m <- n * n
  end sleep
end A

const B <- object B
  process
    const y <- A.sleep[5]
    stdout.putstring["B is awake again\n"]
    stdout.putstring["  A.sleep returned "||y.asString||"\n"]
  end process
end B

const C <- object C
  process
    const here <- locate self
    const allnodes <- here.getActiveNodes
    stdout.putstring["Sleeping for 1\n"]
    here.delay[Time.create[1, 0]]
    stdout.putstring["Sleeping for 1 done\n"]
    move B to allnodes[1]$theNode
  end process
end C
