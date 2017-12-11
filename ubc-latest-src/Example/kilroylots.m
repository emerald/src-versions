const Kilroy <- object Kilroy
  var counter : Integer <- 1
  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Real

    home$stdout.PutString["Starting on " || home$name || "\n"]
    for howmany : Integer <- 1 while howmany <= 100 by howmany <- howmany + 1
	all <- home.getActiveNodes
	home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
	startTime <- home.getTimeOfDay
	for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
	  there <- all[i]$theNode
	  move Kilroy to there
	  there$stdout.PutString["Kilroy was here - counter " || counter.asString || " round " || howmany.asString || " visit " || i.asString || "\n"]
	  counter <- counter + 1
	end for
	move Kilroy to home
	diff <- home.getTimeOfDay - startTime
	home$stdout.PutString["Back home - counter " || counter.asString || " round " || howmany.asString || " visit " || (all.upperbound + 1).asString || ".  Total time = " || diff.asString || "\n"]
	counter <- counter + 1
	home.Delay[Time.create[0, 100000]]
    end for
  end process
end Kilroy
