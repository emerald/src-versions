const invoke <- object invoke
  const target <- object target 
    export operation nothing [a : Any]
      
    end nothing
  end target
  const here <- locate self
  const alive <- here.getActiveNodes

  export op prepare
    const thenode <- alive[1]$theNode
    assert thenode !== here 
    move target to thenode
  end prepare

  process
    var input : String
    const thething <- Vector.of[Character].create[16 * 1024]
    self.prepare
    loop
      const before <- here.getTimeOfDay
      for i : Integer <- 0 while i < 100 by i <- i + 1
	target.nothing[thething]
      end for
      const after <- here.getTimeOfDay
      stdout.putstring["100 remote invokes of ~16k = "||(after - before).asString||"\n"]
    end loop
  end process
end invoke
