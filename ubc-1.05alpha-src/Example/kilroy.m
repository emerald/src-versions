const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Real

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i]$theNode
      move Kilroy to there
      there$stdout.PutString["Kilroy was here\n"]
    end for
    move Kilroy to home
    diff <- home.getTimeOfDay - startTime
    home$stdout.PutString["Back home.  Total time = " || diff.asString || "\n"]
  end process
end Kilroy
