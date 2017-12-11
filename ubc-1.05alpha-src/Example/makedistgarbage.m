const spiralrounds <- 10
const nloops <- 20

const list <- class list[l : list]
  field next : list <- l
end list

const makegarbage <- object makegarbage
  process
    const home <- locate self
    var there :     Node
    var all : NodeList
    var l1, l2 : list <- list.create[nil]

    for c : Integer <- 0 while c < nloops by c <- c + 1
      home$stdout.PutString["Starting on " || home$name || "\n"]
      all <- home.getActiveNodes
      home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
      for i : Integer <- 1 while i <= spiralrounds by i <- i + 1
	for j : Integer <- 1 while j <= all.upperbound by j <- j + 1
	  there <- all[j]$theNode
	  move makegarbage to there
	  l1 <- list.create[l1]
	  l2 <- list.create[l2]
	end for
	move makegarbage to home
	l1 <- list.create[l1]
	l2 <- list.create[l2]
      end for
      home$stdout.PutString["Created a spiral of "||spiralrounds.asString||" rounds through "||(all.upperbound+1).asString||" nodes\n"]
      home.delay[Time.create[2, 0]]
      l1 <- nil
      home$stdout.putstring["Starting distGC\n"]
      primitive "GCOLLECT" [] <- []
      home$stdout.putstring["  Sleeping\n"]
      home.delay[Time.create[30, 0]]
    end for
  end process
end makegarbage
		
