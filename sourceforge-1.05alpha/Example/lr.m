const Remote <- monitor object Remote
  var n : Integer <- 1
  export operation NoParams
    (locate self)$stdout.putint[n, 0]
    (locate self)$stdout.putchar['\n']
    n <- n + 1
  end NoParams
  export operation StringParam[s:String]
    (locate self)$stdout.putint[n, 0]
    (locate self)$stdout.putchar['\n']
    n <- n + 1
  end StringParam
end Remote

const Local <- object Local
  process
    const home <- locate self
    var all : NodeList
    var there : Node

    all <- home.getActiveNodes

    fix Local at home

    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i]$theNode
      fix Remote at there

      var startTime, diff : Time
      startTime <- home.getTimeOfDay
      Remote.NoParams
      diff <- home.getTimeOfDay - startTime
      home$stdout.PutString["Time to call NoParams on " || there.getName ||
        " from " || home.getName || " was " || diff.asString || "\n"]

      startTime <- home.getTimeOfDay
      Remote.StringParam["hi there, frank.\n"]
      diff <- home.getTimeOfDay - startTime
      home$stdout.PutString["Time to call StringParam on " || there.getName ||
        " from " || home.getName || " was " || diff.asString || "\n"]
    end for
  end process
end Local
