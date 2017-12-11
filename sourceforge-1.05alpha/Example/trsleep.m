const foo <- object trsleep
  process
    const all <- (locate self).getActiveNodes
    if all.upperbound > 0 then
      stdout.putstring["RSleeping\n"]
      all[1]$theNode.delay[Time.create[30,0]]
    end if
    unavailable
      stdout.putstring["Unavailable\n"]
    end unavailable
  end process
end trsleep
