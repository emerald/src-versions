
const Mover <- immutable object mover

  const moverType <- typeobject moverType
    operation moveTo [ here : Node ]
  end moverType
  export function getSignature -> [r : Signature]
    r <- moverType
  end getSignature
  export operation create -> [r : moverType]
    r <- object aMover
      export operation moveTo [n : Node]
	move self to n
      end moveTo
    end aMover
    move r to locate r
  end create
end mover

const tmove <- object tmove
  const nMoves <- 10
  const myTest <- runtest.create[stdin, stdout, "tmove ("||nMoves.asString||")"]
  const theNodes : NodeList <- (locate self).getActiveNodes
  process
    var c: Character
    var i : Integer <- 0
    const myMover <- mover.create
    var nle : NodeListElement
    var upb : Integer <- theNodes.upperbound
    myTest.check[upb - theNodes.lowerbound > 0,
       "more than 1 active nodes"]
    loop
      exit when i >= nMoves
      nle <-  theNodes(i # (upb + 1))
      % stdout.PutString["Moving mover to LNN " || nle$LNN.asString || "\^J"]
      myMover.moveTo[nle$theNode]
      i <- i + 1
    end loop
    myTest.done
  end process
end tmove
