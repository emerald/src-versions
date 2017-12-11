const moverA <- class moverA end moverA
const moverB <- class moverB end moverB

const tmove <- object tmove
  var hops : Integer <- 0
  const alive <- (locate 1).getActiveNodes

  process
    const howmany <- 1000
    const target <- alive[1]$theNode
    var startTime, endTime : Time
    startTime <- (locate self).getTimeOfDay
    move moverA.create to target
    endTime <- (locate self).getTimeOfDay
    stdout.putstring["First move took "||(endTime-startTime).asString||" seconds\n"]

    startTime <- (locate self).getTimeOfDay
    move moverB.create to target
    endTime <- (locate self).getTimeOfDay
    stdout.putstring["Second move took "||(endTime-startTime).asString||" seconds\n"]
  end process
end tmove
