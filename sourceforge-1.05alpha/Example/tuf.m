const kilroy <- monitor object kilroy
  const c <- Condition.create
  export operation foo 
    wait c
  end foo
  export operation bar
  end bar
end kilroy

const intermediate <- object intermediate
  export operation foo 
    kilroy.foo
    failure
      stdout.putstring["Intermediate caught the failure\n"]
    end failure
  end foo
end intermediate

const invoker <- object invoker
  process
    const all <- (locate self).getActiveNodes
    kilroy.bar
    move kilroy to all[1]$theNode
    intermediate.foo
    unavailable
      stdout.putstring["It is unavailable\n"]
    end unavailable
    failure
      stdout.putstring["It failed\n"]
    end failure
  end process
end invoker
