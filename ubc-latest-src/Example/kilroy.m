const Kilroy <- object Kilroy
  var counter : Integer <- 1
  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Real

    home.getstdout.PutString["Starting on " || home.getname || "\n"]
    all <- home.getActiveNodes
    home.getstdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    startTime <- home.getTimeOfDay
    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i].gettheNode
      move Kilroy to there
      there.getstdout.PutString["Kilroy was here " || counter.asString || "\n"]
      counter <- counter + 1
    end for
    move Kilroy to home
    diff <- home.getTimeOfDay - startTime
    home.getstdout.PutString["Back home " || counter.asString || ".  Total time = " || diff.asString || "\n"]
    counter <- counter + 1
  end process
end Kilroy
