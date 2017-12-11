const nloops <- 5000
const nslaves <- 5
const nreps <- 999999999

const stressinvokeandmove <- object stressinvokeandmove
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

  export op moveit[o : Any]
    const thenode <- alive[self.random[alive.upperbound + 1]]$theNode
    move o to thenode
  end moveit

  export op moveiteverywhere
    for i : Integer <- 0 while i <= alive.upperbound by i <- i + 1
      const thenode <- alive[i]$theNode
      move target to thenode
    end for
  end moveiteverywhere

  export operation random [n : Integer] -> [r : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [r] <- []
    r <- r # n
  end random

  process
    self.moveiteverywhere
    for i : Integer <- 0 while i < nslaves by i <- i + 1
      const slave <- object slave
	operation dosome
	  var s, t : String
	  const one <- Time.create[1, 0]
	  var startTime, diff : Time
      
	  loop
	    startTime <- here.getTimeOfDay
	    for i : Integer <- 0 while i < nloops by i <- i + 1
	      var r : Integer <- stressinvokeandmove.random[6]
	      if r == 0 then
		target.nothing
	      elseif r == 1 then
		s <- target.nothing01
	      elseif r == 2 then
		target.nothing10["xyz"]
	      elseif r == 3 then
		s <- target.nothing11["xyz"]
	      elseif r == 4 then
		stressinvokeandmove.moveit[target]
	      elseif r == 5 then
		stressinvokeandmove.moveit[self]
	      end if
	    end for
	    diff <- here.getTimeOfDay
	    diff <- diff - startTime
	    if i == 0 then
	      stdout.PutString[nloops.asString || " operations took " || diff.asString || "\n"]
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
end stressinvokeandmove
