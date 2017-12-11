const first <- object first
  const target <- object target
    export operation op1 
    end op1
    export operation op2 
    end op2
    export operation op3 
    end op3
    export operation op4 
    end op4
    export operation op5 
    end op5
    export operation op6 
    end op6
    export operation op7 
    end op7
    export operation op8 
    end op8
    export operation op9 
    end op9
    export operation op10 
    end op10
    export operation op11 
    end op11
    export operation op12 
    end op12
    export operation op13 
    end op13
    export operation op14 
    end op14
    export operation op15 
    end op15
    export operation op16 
    end op16
    export operation op17 
    end op17
    export operation op18 
    end op18
    export operation op19 
    end op19
    export operation op20 
    end op20
  end target
  process
    const here <- locate self
    const all <- here$activeNodes
    var there : Node
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      const anode <- all[i]$theNode
      if anode !== here and anode$name != here$name then
	there <- all[i]$theNode
      end if
    end for
    if there == nil then
      there <- all[all.upperbound]$theNode
      stdout.putstring["Can't find a node on another machine, picking node on " || there$name || " " || (there$lnn / 65536).asString || " " || (there$lnn # 65536).asString || "\n"]
    end if

    move target to there

    const starttime <- here$timeOfDay
    const limit <- 10000
    for i : Integer <- 0 while i < limit by i <- i + 1
      target.op19
    end for
    const endtime <- here$timeOfDay
    stdout.putstring[limit.asString||" remote invokes took "||(endtime-starttime).asString||" seconds\n"]
  end process
end first
