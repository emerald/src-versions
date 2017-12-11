const starved <- object starved
  initially
    const nl: ImmutableVector.of[NodeListElement] <- (locate
self).getActiveNodes

    var i: Integer
    for ( i <- 0 : i <= nl.upperbound : i <- i + 1 )
        const t5p1 <- starvedproc.create[1, nl.getElement[i].getTheNode]
        const t5p2 <- starvedproc.create[2, nl.getElement[i].getTheNode]
        const t5p3 <- starvedproc.create[3, nl.getElement[i].getTheNode]
    end for

  end initially
end starved

const starvedproc <- class starvedproc [id: Integer, n: Node]
  process
    move self to n

    var j: Integer <- 0
    loop
      (locate self)$stdout.PutString[id.asString || ", " || j.asString || "\n"]
      j <- j + 1
    end loop
  end process
end starvedproc

