const target <- class target
  
end target

const tmove <- object tmove
  process
    const here <- locate 1
    const alive <- here.getActiveNodes
    var there : Node

    for i: Integer <- 0 while i <= alive.upperbound by i <- i + 1
      const node <- alive[i]$theNode
      if node !== here then
	there <- node
      end if
    end for
    for i : Integer <- 0 while i < 100000 by i <- i + 1
      move target.create to there
      if i # 100 = 99 then
	stdout.putchar['.'] stdout.flush
      end if
    end for
  end process
end tmove
