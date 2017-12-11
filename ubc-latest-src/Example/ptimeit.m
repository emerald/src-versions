  const target <- object target
    export operation noparams 
    end noparams
    export operation oneparam [v : Any]
    end oneparam
  end target

  const stat <- monitor object stat
    var sum : Real <- 0.0
    var sumsq : Real <- 0.0
    var n : Integer <- 0
    var min, max : Real
    export operation Sample [t : Time]
      const r : Real <- t$seconds.asReal + t$microseconds.asReal / 1000000.0
      sum <- sum + r
      sumsq <- sumsq + r * r
      if n = 0 then
	min <- r
	max <- r
      elseif r > max then
	max <- r
      elseif r < min then
	min <- r
      end if
      n <- n + 1
    end Sample
    export operation Sum -> [r : Real]
      r <- sum
    end Sum
    export operation Min -> [r : Real]
      r <- min
    end Min
    export operation Max -> [r : Real]
      r <- max
    end Max
    operation iAverage -> [r : Real]
      r <- sum / n.asReal
    end iAverage
    operation iStdDev -> [r : Real]
      r <- (sumsq / n.asReal - self.iAverage * self.iAverage) ^ 0.5
    end iStdDev
    export operation Reset 
      sum <- 0.0 sumsq <- 0.0 n <- 0
    end Reset
    export operation Display [out : OutStream]
      out.PutString["min: "|| min.asString || " avg: " || self.iAverage.asString || " max: " || max.asString || " std: " || self.iStddev.asString || "\n"]
    end Display
  end stat
  
const Kilroy <- object Kilroy
  const trips <- 1000

  operation buildstring [logn : Integer] -> [r : String]
    r <- "a"
    for i : Integer <- 0 while i < logn by i <- i + 1
      r <- r || r
    end for
  end buildstring

  operation killEmerald 
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end killEmerald

  export operation measurelatency 
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList

    all <- home.getActiveNodes
    for hi : Integer <- 1 while hi <= all.upperbound by hi <- hi + 1
      there <- all[hi]$theNode
      stat.Reset
      move target to there
      home$stdout.PutString["Invoking from " || home$name || " to " || there$name || "\n"]
      home$stdout.PutString["Invoking noparams "||trips.asString||" times\n"]
      target.noparams
      for i : Integer <- 0 while i <= trips by i <- i + 1
	startTime <- home.getTimeOfDay
	target.noparams
	stat.Sample[home.getTimeOfDay - startTime]
      end for
      stat.Display[stdout]
    end for
  end measurelatency

  export operation measurebandwidth[nprocesses : Integer]
    const home <- locate self
    var there :     Node
    var all : NodeList
    const logn <- 14
    const bigstring : String <- self.buildstring[logn]
    var startTime : Time

    const barrier <- monitor object barrier
      var nexpected, narrived : Integer
      const done <- Condition.create
      export operation arm [n : Integer]
	nexpected <- n
	narrived <- 0
      end arm
      export operation done 
	assert narrived < nexpected
	narrived <- narrived + 1
	if narrived = nexpected then
	  signal done
	end if
      end done
      export operation waituntildone 
	if narrived < nexpected then
	  wait done
	end if
      end waituntildone
    end barrier

    all <- home.getActiveNodes
    for hi : Integer <- 1 while hi <= all.upperbound by hi <- hi + 1
      there <- all[hi]$theNode
      move target to there
  
      stat.Reset
      home$stdout.PutString["Invoking from " || home$name || " to " || there$name || "\n"]
      home$stdout.PutString[nprocesses.asString || " processes invoking oneparam "||trips.asString||" times ("||(bigstring.upperbound+1).asString||"bytes/time)\n"]
      target.oneparam[bigstring]
      barrier.arm[nprocesses]
      startTime <- home.getTimeOfDay

      for p : Integer <- 0 while p < nprocesses by p <- p + 1
	const junk <- object junk
	  process
	    for i : Integer <- 0 while i < trips / nprocesses by i <- i + 1
	      target.oneparam[bigstring]
	    end for
	    barrier.done
	  end process
	end junk
      end for
      barrier.waituntildone
      stat.Sample[home.getTimeOfDay - startTime]
      const bandwidth <- (bigstring.upperbound + 1).asReal * trips.asReal / 1000000.0 / stat.Sum
      stdout.PutString["    "||bandwidth.asString||" MBytes/sec\n"]
    end for
  end measurebandwidth
  process
    self.measurelatency
    self.measurebandwidth[1]
    self.measurebandwidth[2]
    self.measurebandwidth[5]
    self.measurebandwidth[10]
    self.killemerald
  end process
end Kilroy
