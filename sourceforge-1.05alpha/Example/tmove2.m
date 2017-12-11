const tmove <- object tmove
  const target <- object target
    var val : Integer <- 0
    export operation hi -> [r : String]
      r <- val.asString
      val <- val + 1
    end hi
  end target
  process
    const here <- locate 1
    const alive <- here.getActiveNodes
    stdout.putstring[target.hi || "\n"]
    for i : Integer <- 0 while i <= alive.upperbound by i <- i + 1
      const node <- alive[i].getthenode
      if node !== here then
	move target to node
	stdout.putstring[target.hi || "\n"]
	exit
      end if
    end for
  end process
end tmove
