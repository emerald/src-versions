const Kilroy <- object Kilroy
  const target <- object target
    export operation noparams 
    end noparams
    export operation oneparam [v : Any]
    end oneparam
  end target

  operation buildstring [logn : Integer] -> [r : String]
    r <- "a"
    for i : Integer <- 0 while i < logn by i <- i + 1
      r <- r || r
    end for
  end buildstring

  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    const trips <- 100
    const logn <- 0
%    const bigstring : String <- self.buildstring[logn]
    const bigstring <- ImmutableVector.of[Character].create[16 * 1024]
%    const bigstring  <- Array.of[Character].create[16000]

    all <- home.getActiveNodes
    there <- all[1]$theNode
    move target to there
    home$stdout.PutString["Invoking from " || home$name || " to " || there$name || "\n"]
    home$stdout.PutString["Invoking noparams "||trips.asString||" times\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 0 while i <= trips by i <- i + 1
      target.noparams
    end for
    diff <- home.getTimeOfDay - startTime
    stdout.PutString["Avg = " || (diff/trips).asString || "seconds/invoke\n"]

    home$stdout.PutString["Invoking oneparam "||trips.asString||" times ("||(bigstring.upperbound+1).asString||"bytes/time)\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 0 while i <= trips by i <- i + 1
      target.oneparam[bigstring]
    end for
    diff <- home.getTimeOfDay - startTime
    const bandwidth <- (bigstring.upperbound + 1).asReal * trips.asReal / 1000000.0 / (diff$seconds.asReal + diff$microseconds.asReal/1000000.0)
    stdout.PutString["Avg = " || (diff/trips).asString || "seconds/invoke, "||bandwidth.asString||" MBytes/sec\n"]
  end process
end Kilroy
