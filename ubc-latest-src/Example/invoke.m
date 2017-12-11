const invoke <- object invoke
  var hops : Integer <- 0
  const target <- object target 
    export operation nothing 
      
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
    self.prepare
    loop
      stdout.putstring["> "] stdout.flush
      input <- stdin.getstring
      begin
	target.nothing
	unavailable
	  stdout.putstring["It is unavailable\n"]
	end unavailable
      end
    end loop
  end process
end invoke
