const all <- object all
  process
    var nodes : NodeList
    nodes <- (locate self).getAllNodes
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
  end process
end all
