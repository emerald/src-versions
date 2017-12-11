const failmove <- object failmove
  operation go [place : Node] -> [r : Boolean]
    move self to place
    const here <- locate self
    here$stdout.putstring["Kill this node now\n"]
    here.Delay[Time.create[100, 0]]
    r <- false
    unavailable
      (locate self)$stdout.putstring["Node unavailable\n"]
      r <- true
    end unavailable
  end go

  process
    const here <- locate self
    var alive : NodeList <- here.getActiveNodes
    const one <- Time.create[1, 0]

    loop
      for j: Integer <- alive.upperbound while j >= 0 by j <- j - 1
	const thenode <- alive[j]$theNode
	if self.go[thenode] then
	  alive <- here.getActiveNodes
	  j <- j - 1
	end if
      end for
      here.delay[one]
    end loop
  end process
end failmove
