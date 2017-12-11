const Kilroy <- object Kilroy
  process
    const           home:           Node <- locate self
    var             i:              Integer <- 0
    var             remoteNode:     Node
    var             startTime,diff: Time
    var		    minTime       : Time <- Time.create[100000, 0]
    const           onesec        : Time <- Time.create[1, 0]  
    var             myList:         NodeList
    var             theElem:        NodeListElement
    var             howmany:        Integer

    myList <- home.getActiveNodes
    (locate self).getstdout.PutInt[myList.upperbound + 1, 2]
    (locate self).getstdout.PutString[" nodes active.\^J"]

    howmany <- 0
    loop
      exit when howmany = 100
      howmany <- howmany + 1
      i <- 0
      startTime <- home.getTimeOfDay
      loop
	exit when i > myList.upperbound
	remoteNode    <- myList[i]$theNode
	move Kilroy to remoteNode
	i <- i + 1
      end loop
      move Kilroy to home
      diff <- home.getTimeOfDay
      diff <- diff - startTime
      if diff < minTime then minTIme <- diff end if
      (locate self).getstdout.PutString["Back home - total time " || diff.asString || " min time " || minTime.asString || "\n"]
      (locate self).delay[onesec]
    end loop
  end process
end Kilroy
