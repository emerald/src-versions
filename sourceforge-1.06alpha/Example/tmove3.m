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
	const stdout <- here.getstdout
	stdout.putchar['[']
	stdout.putint[hops, 1]
	stdout.putstring["] Moving myself to "||newnode.getName||"\n"]
	hops <- hops + 1
	move self to newnode
	(locate self)$stdout.putstring["Here I am\n"]	
	exit
      end if
    end for
  end doamove
  process
%    loop
      self.doamove
      (locate self)$stdout.putstring["All done\n"]
%     (locate self).Delay[Time.create[1, 0]]
%    end loop
  end process
end tmove
