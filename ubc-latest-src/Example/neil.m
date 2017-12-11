  const target <- object target
    export operation noparams 
    end noparams
    export operation oneparam [v : Any]
    end oneparam
  end target

  const stat <- object stat
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
    export operation Average -> [r : Real]
      r <- sum / n.asReal
    end Average
    export operation StdDev -> [r : Real]
      r <- (sumsq / n.asReal - self.Average * self.Average) ^ 0.5
    end StdDev
    export operation Reset 
      sum <- 0.0 sumsq <- 0.0 n <- 0
    end Reset
    export operation Display [out : OutStream]
      out.PutString["min: "||stat.Min.asString || " avg: " || stat.Average.asString||" max: "||stat.max.asString||" std: "||stat.stddev.asString||"\n"]
    end Display
  end stat
  
const Kilroy <- monitor object Kilroy
  var Done : Condition <- Condition.create 
  var forRoom : Condition <- Condition.create
  var iVal : Integer <- 0
  var iCount : Integer <- 0

  operation buildstring [logn : Integer] -> [r : String]
    r <- "a"
    for i : Integer <- 0 while i < logn by i <- i + 1
      r <- r || r
    end for
  end buildstring

  operation killEmerald 
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end killEmerald

  export operation increment
    iVal <- iVal + 1
    iCount <- iCount + 1
    %if(iVal >= 20) then wait forRoom end if
    %stdout.PutString["Call: " || iCount.asString || ", Val: " || iVal.asString || "\n"];
  end increment

  export operation decrement
    iVal <- iVal - 1
    if(iVal == 0) then signal Done end if
    %if iVal < 20 then signal forRoom end if
    %stdout.PutString[iVal.asString || "\n"];
  end decrement

  export operation waitdone
    wait Done
  end waitdone
end Kilroy


const driver <- object driver
  operation buildstring [logn : Integer] -> [r : String]
    r <- "a"
    for i : Integer <- 0 while i < logn by i <- i + 1
      r <- r || r
    end for
  end buildstring

  operation killEmerald 
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end killEmerald

  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    const trips <- 200
    const logn <- 14
    const bigstring : String <- self.buildstring[logn]

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
  
      stat.Reset
      home$stdout.PutString["Invoking oneparam "||trips.asString||" times ("||(bigstring.upperbound+1).asString||"bytes/time)\n"]
      target.oneparam[bigstring]

	startTime <- home.getTimeOfDay

      	    for i : Integer <- 0 while i <= trips by i <- i + 1

		const caller <- object caller	
			process
				target.oneparam[bigstring]
				Kilroy.decrement
			end process
		end caller
	 	Kilroy.increment

      	    end for

	kilroy.waitdone
	stat.Sample[home.getTimeOfDay - startTime]

      const bandwidth <- (bigstring.upperbound + 1).asReal * trips.asReal / 1000000.0 / stat.Sum
      stat.Display[stdout]
      stdout.PutString["    "||bandwidth.asString||" MBytes/sec\n"]
    end for
    self.killEmerald
  end process
end driver

