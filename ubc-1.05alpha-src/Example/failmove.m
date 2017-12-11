const failmove <- object failmove
  const here <- locate self
  var alive : NodeList <- here.getActiveNodes
  const howmany <- 100

  operation go [place : Node] -> [r : Boolean]
    move self to place
    r <- false
    unavailable
      (locate self)$stdout.putstring["Node unavailable\n"]
      r <- true
    end unavailable
  end go

  operation tell [out : OutStream, diff : Time, minTime : Time]
    out.PutString[howmany.asString || " cycles of "||(alive.upperbound+1).asString||" took " || diff.asString || " min time " || minTime.asString || "\n"]
  end tell
  process
    const one <- Time.create[1, 0]
    var startTime, diff, mintime: Time
    mintime <- Time.create[1000000, 0]
    var out : OutStream
    loop
      startTime <- here.getTimeOfDay
      for i : Integer <- 0 while i < howmany by i <- i + 1
	for j: Integer <- alive.upperbound while j >= 0 by j <- j - 1
	  const thenode <- alive[j]$theNode
	  if self.go[thenode] then
	    alive <- here.getActiveNodes
	    j <- j - 1
	  end if
	end for
      end for
      diff <- here.getTimeOfDay
      diff <- diff - startTime
      if diff < minTime then minTIme <- diff end if
      out <- here$stdout
      self.tell[out, diff, minTime]
      out <- nil
      here.delay[one]
    end loop
  end process
end failmove
