const tmove <- object tmove
  export op doamove
    const here <- locate 1
    const alive <- here.getActiveNodes
    for i: Integer <- 0 while i <= alive.upperbound by i <- i + 1
      const node <- alive[i]$theNode
      if node == here then
	const newindex <- (i + 1) # (alive.upperbound + 1)
	const newnode <- alive[newindex]$theNode
	stdout.putstring["Moving myself to node "||newindex.asString||"\n"]
	move self to newnode
	stdout.putstring["I have arrived\n"]
	exit
      end if
    end for
  end doamove
  process
    self.doamove
  end process
end tmove
