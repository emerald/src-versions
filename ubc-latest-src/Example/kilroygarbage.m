const Kilroy <- object Kilroy
  var counter : Integer <- 1
  process
    const home <- locate self
    const limit <- 1000000
    const listlength <- 1000
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Any

    home$stdout.PutString["Starting on " || home$name || "\n"]
    for howmany : Integer <- 1 while howmany <= limit by howmany <- howmany + 1
	all <- home.getActiveNodes
	% home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
	startTime <- home.getTimeOfDay
	for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
	  there <- all[i]$theNode
	  move Kilroy to there
	  if howmany # 100 = 99 then there$stdout.PutString["Kilroy was here - counter " || counter.asString || " round " || howmany.asString || " visit " || i.asString || "\n"] end if
	  stuff <- object junk
	    var a,b,c,d,e,f,g,h,j,k: Any
	    initially
	      if i # listlength != 0 then
		a <- stuff
	      end if
	    end initially
	  end junk
	  counter <- counter + 1
	end for
	move Kilroy to home
	diff <- home.getTimeOfDay - startTime
	if howmany # 100 = 99 then home$stdout.PutString["Back home - counter " || counter.asString || " round " || howmany.asString || " visit " || (all.upperbound + 1).asString || ".  Total time = " || diff.asString || "\n"] end if
	counter <- counter + 1
	% home.Delay[Time.create[0, 100000]]
    end for
  end process
end Kilroy
