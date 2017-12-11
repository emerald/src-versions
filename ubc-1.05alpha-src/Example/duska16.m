const test16 <- object test16
  process

    const m1 <- memberObj.create[1]

    const n: Node <- locate self
    const nl: ImmutableVector.of[NodeListElement] <- n.getActiveNodes
    var count: Integer <- 0

    loop
      m1.moveSelf[nl.getElement[count].getTheNode]
      count <- count + 1
      if count > nl.upperBound then count <- 0 end if
    end loop
  end process
end test16

const memberObj <- class memberObj [state: Integer]
  var movecount : Integer <- 1
  export operation setState [i: Integer]
    state <- i
  end setState

  export operation getState -> [i: Integer]
    i <- state
  end getState

  export operation moveSelf [n: Node]
    (locate self).getStdOut.putString[movecount.asString||" Beginning move\n"]
    move self to n
    (locate self).getStdOut.putString[movecount.asString||" Done move\n"]
    movecount <- movecount + 1
  end moveSelf
end memberObj
