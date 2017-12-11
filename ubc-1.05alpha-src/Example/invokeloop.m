const invoke <- object invoke
  const target <- object target 
    export operation nothing [a : Any]
      
    end nothing
  end target
  const here <- locate self
  const alive <- here.getActiveNodes

  process
    for i : Integer <- 0 while true by i <- (i + 1) # (alive.upperbound + 1)
      const thenode <- alive[i]$theNode
      move target to thenode
      target.nothing["abc" || ""]
    end for
  end process
end invoke
