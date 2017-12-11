const pounder <- class pounder[r : Any]
  process
    const targettype <- typeobject targettype
      operation noop
      operation noop10[String]
      operation noop01->[String]
      operation noop11[String]->[String]
    end targettype
    const target <- view r as targettype

    var howmany : Integer <- 1000
    const howoften <- howmany / 10
    const here <- locate 1
    var s, e : Time
    s <- here.getTimeOfDay
    for i : Integer <- 0 while i < howmany by i <- i + 1
      target.noop
      if i # howoften = howoften - 1 then
	stdout.putchar['.']
	stdout.flush
      end if
    end for
    e <- here.getTimeOfDay
    stdout.putchar['\n']
    stdout.putint[howmany, 0]
    stdout.putstring[" noop invokes took "]
    stdout.putstring[(e - s).asString]
    stdout.putchar['\n']
    s <- here.getTimeOfDay
    for i : Integer <- 0 while i < howmany by i <- i + 1
      target.noop10["abc"]
      if i # howoften = howoften - 1 then
	stdout.putchar['.']
	stdout.flush
      end if
    end for
    e <- here.getTimeOfDay
    stdout.putchar['\n']
    stdout.putint[howmany, 0]
    stdout.putstring[" noop10 invokes took "]
    stdout.putstring[(e - s).asString]
    stdout.putchar['\n']
    s <- here.getTimeOfDay
    for i : Integer <- 0 while i < howmany by i <- i + 1
      const foobar <- target.noop01
      if i # howoften = howoften - 1 then
	stdout.putchar['.']
	stdout.flush
      end if
    end for
    e <- here.getTimeOfDay
    stdout.putchar['\n']
    stdout.putint[howmany, 0]
    stdout.putstring[" noop01 invokes took "]
    stdout.putstring[(e - s).asString]
    stdout.putchar['\n']
    s <- here.getTimeOfDay
    for i : Integer <- 0 while i < howmany by i <- i + 1
      const foobar <- target.noop11["abc"]
      if i # howoften = howoften - 1 then
	stdout.putchar['.']
	stdout.flush
      end if
    end for
    e <- here.getTimeOfDay
    stdout.putchar['\n']
    stdout.putint[howmany, 0]
    stdout.putstring[" noop11 invokes took "]
    stdout.putstring[(e - s).asString]
    stdout.putchar['\n']
  end process
end pounder

const start <- object start
  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  process
    const prompt <- "pounder# "
    var buf: String
    const here <- (locate 1)
    here.Delay[Time.create[2, 0]]
    const all <- here.getActiveNodes
    var rootdir : Directory

    rootdir <- here.getrootdirectory
    const target <- rootdir.lookup["target"]
    loop
      stdout.putString[ prompt ] stdout.flush
      exit when stdin.eos
      buf <- self.chop[ stdin.getString ]
      exit when buf = "exit" or buf = "quit" or buf = "q"
      if buf = "" then
      elseif buf = "move" then
	const targetlocation <- locate target
        const allnodes <- here.getActiveNodes
	for i: Integer <- 0 while i <= allnodes.upperbound by i <- i + 1
	  const node <- allnodes[i]$theNode
	  if node == targetlocation then
	    const newindex <- (i + 1) # (allnodes.upperbound + 1)
	    const newnode <- allnodes[newindex]$theNode
	    stdout.putstring["Moving target to node "||newindex.asString||"\n"]
	    move target to newnode
	    exit
	  end if
	end for
      elseif buf = "pound" then
	if target !== nil then
	  const p <- Pounder.create[target]
	else
	  stdout.putstring["There is no target in the root directory\n"]
	end if
      elseif buf = "allnodes" then
        const allnodes <- (locate 1).getAllNodes
        var nodes: Integer
        nodes <- allnodes.upperbound - allnodes.lowerbound + 1
        stdout.putString[ "Number of known nodes: " ||
                          nodes.asString || "\n" ]
	for i: Integer <- allnodes.lowerbound
		while i <= allnodes.upperbound by i <- i + 1
	  const node <- allnodes.getElement[i]
	  stdout.putString[ "Node " || i.asString || ":\n" ]
	  stdout.putString[ " getUp -> " || node.getUp.asString || "\n" ]
	  stdout.putString[ " getIncarnationTime -> " ||
	  	node.getIncarnationTime.asDate || "\n" ]
	  stdout.putString[ " getLNN -> " || node.getLNN.asString || "\n" ]
	  if node.getUp then begin
	    stdout.putString[ " getTheNode.getName -> " ||
		  node.getTheNode.getName || "\n" ]
	    failure
	      stdout.putString["invoking getTheNode.getName failed\n"]
	    end failure
	  end end if
	end for
      else
        stdout.putString[ "Eh?\n" ]
      end if
    end loop
  end process
end start
