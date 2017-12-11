const test9 <- object test9
  process
    const moveObj <- object moveObj
     var state: Integer <- 0
     export operation setState [i: Integer]
       state <- i
     end setState
    end moveObj

    const n: Node <- locate self
    const nl: ImmutableVector.of[NodeListElement] <- n.getActiveNodes
    var count: Integer <- 0
    const t: Time <- Time.create[3, 0]

    loop  
      moveObj$state <- count
      (locate self)$stdout.PutString["Moving object to node " || count.asString 
|| "\n"]
      move moveObj to nl.getElement[count].getTheNode
      count <- count + 1
      moveObj$state <- count
      const whocares <- locate moveObj
      if count > nl.upperBound then count <- 0 end if
%     n.delay[t]
    end loop
    failure
      stdout.putstring["Failed!!\n"]
    end failure
  end process
end test9
