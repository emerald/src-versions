const target <- object target
  export operation go [place : Node]
    move self to place
  end go
end target

const failmove <- object failmove
  process
    const here <- locate self
    var alive : NodeList <- here.getActiveNodes

    stdout.putstring["There are "||(alive.upperbound+1).asString||" active nodes.\n"]
    for j: Integer <- 0 while j <= alive.upperbound by j <- j + 1
      const thenode <- alive[j]$theNode
      target.go[thenode]
      if islocal target then
	stdout.putstring["Target is now local\n"]
      else
	stdout.putstring["Target is now not local\n"]
      end if
    end for
  end process
end failmove
