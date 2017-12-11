const target <- object target
  export operation show 
    (locate self)$stdout.putstring["Target is here\n"]
  end show
  export operation fail 
    assert false
  end fail
end target

const driver <- object driver
  process
    const all <- (locate self)$activeNodes
    move target to all[1]$theNode
    target.show
    target.fail
    failure
      stdout.putstring["Caught a failure\n"]
    end failure
  end process
end driver
