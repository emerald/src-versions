const movemetons <- object movemetons
  const here <- locate self
  const howmany <- 1000
  const alive <- here.getActiveNodes

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
	  move self to thenode
	end for
      end for
      diff <- here.getTimeOfDay
      diff <- diff - startTime
      if diff < minTime then minTIme <- diff end if
      out <- here$stdout
      self.tell[out, diff, minTime]
      out <- nil
%      here.delay[one]
    end loop
  unavailable
    stdout.putstring["Some node died, aborting\n"]
  end unavailable
  end process
end movemetons
