const test13 <- object test13
      process
        var i, j: Integer
        var nl: ImmutableVector.of[NodeListElement] <- (locate
self).getActiveNodes
        var nlv: Vector.of[nodeNode]
        nlv <- Vector.of[nodeNode].create[nl.upperBound + 1]
        for ( j <- 0 : j <= nl.upperBound : j <- j + 1)
          const n: Node <- nl.getElement[j].getTheNode
          const nn: nodeNode <- nodeNode.create[n, n.getName || ":" ||
(n.getLNN/0x10000).asString]
          nlv.setElement[j, nn]
        end for
        const delay: Time <- Time.create[1, 0]

        i <- 0
        loop
          nl <- (locate self).getActiveNodes
          if nl.upperBound != nlv.upperBound then
            nlv <- Vector.of[nodeNode].create[nl.upperBound + 1]
            for ( j <- 0 : j <= nl.upperBound : j <- j + 1)
              const n: Node <- nl.getElement[j].getTheNode
              const nn: nodeNode <- nodeNode.create[n, n.getName || ":" ||
(n.getLNN/0x10000).asString]
              nlv.setElement[j, nn]
            end for
          end if
          move self to nlv.getElement[i].getNode
          (locate self).getStdOut.putString["I am on " ||
nlv.getElement[i].getName || "\n"]
          i <- i + 1
          if i > nlv.upperBound then i <- 0 end if
          (locate self).delay[delay]
        end loop
      end process
end test13

const nodeNode <- class nodeNode [n: Node, name: String]
  export operation getNode -> [on: Node]
    on <- n
  end getNode
  export operation getName -> [on: String]
    on <- name
  end getName
end nodeNode


