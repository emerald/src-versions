% console.m - provide a shell interface to an emerald system
% $Id: nconsole.m,v 1.1.1.1 2005/01/05 11:54:15 bertelsen Exp $
% BEMAKE() :: rm -f console.x
% BEMAKE() :: echo console.m | emc

const shell <- object shell

  const prompt : String <- "Other Emerald machine and port: "

  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  process
    var buf, machine, port: String
    var ctl : String

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
      stdout.putString[ " getTheNode.getName -> " ||
	    node.getTheNode.getName || "\n" ]
    end for
    
    % (locate 1).delay[Time.create[30,0]]
    const foo <- stdin.getString
  end process
end shell

% EOF
