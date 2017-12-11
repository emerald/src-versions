% Assignment 3, Ingo Jankowski

const traveller <- object traveller
  export operation ping[dummy : Integer] -> [pong : Integer]
    pong <- dummy + 1
  end ping
end traveller

const bigData <- VectorOfChar.create[1024*1024]

const detached <- object detached
  export operation tryNodes[theList : NodeList, cursor : Integer]
    const timeout <- Time.create[3, 0]
    const here <- locate self
    var theNode : Node
    var count : Integer
    var startTime, diff, ratio : Time
    var latency : Real
    for i: Integer <- 0 while i <= theList.upperbound by i <- i + 1
      theList[0]$theNode$stdout.PutString[i.asString]
      theNode <- theList[i]$theNode
      move traveller to theNode
%      unfix traveller
%      fix traveller at theNode
      startTime <- here.getTimeOfDay
      for (count <- 0 : here.getTimeOfDay - startTime < timeout
          : count <- traveller.ping[count])
      end for
      diff <- here.getTimeOfDay - startTime
      latency <- diff.getSeconds.asReal*1000000.0/count.asReal
        + diff.getMicroSeconds.asReal/count.asReal
      latency <- latency / 1000.0
      theList[0]$theNode$stdout.PutString[here$name || " <-> " || theNode$name]
      theList[0]$theNode$stdout.PutString[" : " || latency.asString || "\n"]
    end for
    theList[0]$theNode$stdout.PutString["detached: Ready\n"]
  end tryNodes
end detached

const measureMachine <- object measureMachine
  initially
    const home <- locate self
    var all : NodeList
    var cursor : Integer

    fix self at home
    all <- home.getActiveNodes
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      home$stdout.PutString[i.asString]
      home$stdout.PutString["Emeralds found on "|| all[i]$theNode$name || "\n"]
    end for
    if all.upperbound > 0 then
      for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
        all[0]$theNode$stdout.PutString[i.asString ||all[i]$theNode$name||"\n"]
        move detached to all[i]$theNode
%       unfix detached
%        fix detached at all[i]$theNode
        detached.tryNodes[ all, i]
        all[0]$theNode$stdout.PutString["Out of detached\n"]
      end for
    end if
    home$stdout.PutString["Ready.\n"]
  end initially
end measureMachine

