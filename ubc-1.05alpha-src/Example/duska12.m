% This program generates the move outstanding message...
% testing move of group member object
% moves member round robin between several nodes
% start several nodes, start this on last one

const test13 <- object test13
  process
    const m1 <- memberObj.create[1]

    const n: Node <- locate self
    const nl: ImmutableVector.of[NodeListElement] <- n.getActiveNodes
    var count: Integer <- 0

    loop
      begin
        move m1 to nl.getElement[count].getTheNode
        stdout.PutString["Group moved to node " || count.asString || "\n"]
        failure
          stdout.putString["Unable to move group\n"]
        end failure
      end

      begin
        const m1Value: Integer <- m1.getState
        stdout.PutString["m1 value is " || m1Value.asString || " and m1 is
located at " || (locate m1).getName || "\n"]
        failure
          stdout.PutString["m1 is unavailable" || "\n"]
          return
        end failure
      end

      count <- count + 1
      if count > nl.upperBound then count <- 0 end if
      (locate self).delay[Time.create[2, 0]]
    end loop
  end process
end test13

const memberObj <- class memberObj [state: Integer]
  export operation setState [i: Integer]
    state <- i
  end setState
  export operation getState -> [i: Integer]
    I <- state
  end getState
end memberObj
