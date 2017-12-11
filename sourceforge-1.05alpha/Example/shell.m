% shell.m - provide a shell interface to an emerald system

const shell <- object shell
  var prompt: String <- "emx# "
  var beInteractive : Boolean <- true


  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  process
    var buf: String
    if !beInteractive then return end if
    loop
      stdout.putString[ prompt ] stdout.flush
      exit when stdin.eos
      buf <- self.chop[ stdin.getString ]
      exit when buf = "exit" or buf = "quit" or buf = "q"
      if buf = "" then
      elseif buf = "node" then
        const node <- locate 1
	stdout.putString[ "getName -> " || node.getName || "\n" ]
	stdout.putString[ "getLNN -> " || node.getLNN.asString || "\n" ]
%	stdout.putString[ "getLoadAverage -> " || node.getLoadAverage.asString || "\n" ]
	stdout.putString[ "getTimeOfDay -> " || node.getTimeOfDay.asDate || "\n" ]
      elseif buf = "all" or buf = "up" then
	var nodes : NodeList
	if buf = "all" then
	  nodes <- (locate self).getAllNodes
	else
	  nodes <- (locate self).getActiveNodes
	end if
        var nnodes: Integer
        nnodes <- nodes.upperbound - nodes.lowerbound + 1
        stdout.putString[ "Number of known nodes: " ||
                          nnodes.asString || "\n" ]
	for i: Integer <- nodes.lowerbound
		while i <= nodes.upperbound by i <- i + 1
	  const node <- nodes.getElement[i]
	  stdout.putString[ "Node " || i.asString || ":\n" ]
	  stdout.putString[ " getUp -> " || node.getUp.asString || "\n" ]
	  stdout.putString[ " getIncarnationTime -> " ||
	  	node.getIncarnationTime.asDate || "\n" ]
	  stdout.putString[ " getLNN -> " || node.getLNN.asString || "\n" ]
	  if node.getUp then
	    begin
	      stdout.putString[ " getTheNode.getName -> " ||
		    node.getTheNode.getName || "\n" ]
	      failure
		stdout.putString["invoking getTheNode.getName failed\n"]
	      end failure
	    end
	  end if
	end for
      else
        stdout.putString[ "Eh?\n" ]
      end if
    end loop
    stdout.putString[ "logout\n" ]
  end process
end shell
