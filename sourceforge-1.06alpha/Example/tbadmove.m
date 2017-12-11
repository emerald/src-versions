const target <- object target
  
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
    move target to there
    move target to here
    move target to there 
    move target to there
  end process
end tmove
