const nloops <- 5000
const nslaves <- 1
const nreps <- 999999999

const invoketons <- object invoketons
  var hops : Integer <- 0
  const target <- object target 
    export operation nothing 
      
    end nothing
    export operation nothing10 [ s : String ]
      
    end nothing10
  
    export operation nothing01 -> [ s : String ]
      s <- "abc"
    end nothing01
  
    export operation nothing11 [ s : String ] -> [t : String]
      t <- "abc"
    end nothing11
  end target

  const here <- locate self
  const alive <- here.getActiveNodes

  export op prepare
    const thenode <- alive[alive.upperbound]$theNode
    move target to thenode
  end prepare

  process
    self.prepare
    for i : Integer <- 0 while i < nslaves by i <- i + 1
      const slave <- object slave
	operation dosome
	  var s, t : String
	  const one <- Time.create[1, 0]
	  var startTime, diff, mintime: Time
	  mintime <- Time.create[1000000, 0]
      
	  loop
	    startTime <- here.getTimeOfDay
	    for i : Integer <- 0 while i < nloops by i <- i + 1
	      s <- target.nothing11["123"]
	    end for
	    diff <- here.getTimeOfDay
	    diff <- diff - startTime
	    if diff < minTime then minTIme <- diff end if
	    if i == 0 then
	      stdout.PutString[nloops.asString || " remote nothing11 invokes (with " || nslaves.asString || " slaves) took " || diff.asString || " min time " || minTime.asString || "\n"]
	    end if
	    here.delay[one]
	  end loop
	end dosome
	process
	  for i : Integer <- 0 while i < nreps by i <- i + 1
	    self.dosome
	  end for
	end process
      end slave
    end for
  end process
end invoketons
