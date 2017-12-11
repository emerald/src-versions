const tmove <- object tmove
  var hops : Integer <- 0
  const alive <- (locate 1).getActiveNodes

  export op doamove
    const here <- locate 1
    for i: Integer <- 0 while i <= alive.upperbound by i <- i + 1
      const node <- alive[i]$theNode
      if node == here then
	const newindex <- (i + 1) # (alive.upperbound + 1)
	const newnode <- alive[newindex]$theNode
	hops <- hops + 1
	move self to newnode
	exit
      end if
    end for
  end doamove
  process
    const howmany <- 1000
    const startTime <- (locate self).getTimeOfDay
    for i : Integer <- 0 while i < howmany by i <- i + 1
      self.doamove
    end for
    const endTime <- (locate self).getTimeOfDay
    const out <- (locate self).getStdout
    out.putstring[howmany.asString||" moves took "||(endTime-startTime).asString||" seconds\n"]
  end process
end tmove
