% console.m - provide a shell interface to an emerald system
% $Id$
% BEMAKE() :: rm -f console.x
% BEMAKE() :: echo console.m | emc

const shell <- object shell

  var prompt: String
  var rePing: Integer

  function chop[ i: String ] -> [ o: String ]
    o <- i.getSlice[ 0, i.length - 1 ]
  end chop

  operation isPing[ buf: String ] -> [ b: Boolean ]
    primitive "NCCALL" "REGEXP" "REG_EXEC" [ b ] <- [ rePing, buf ]
  end isPing
  
  initially
    begin
      const re <- "^ping ([-a-z0-9.]+) ([0-9]+)$"
      primitive "NCCALL" "REGEXP" "REG_COMP" [ rePing ] <- [ re ]
    end
    prompt <- "emx# "
  end initially
  
  process
    var buf: String

    loop
      stdout.putString[ prompt ] stdout.flush
      exit when stdin.eos
      buf <- self.chop[ stdin.getString ]
      exit when buf = "exit"
      if buf = "" then
        exit when false % bogosity
      elseif buf = "node" then
        const node <- locate 1
	stdout.putString[ "getName -> " || node.getName || "\n" ]
	stdout.putString[ "getLNN -> " || node.getLNN.asString || "\n" ]
%	stdout.putString[ "getLoadAverage -> " || node.getLoadAverage.asString || "\n" ]
	stdout.putString[ "getTimeOfDay -> " || node.getTimeOfDay.asDate || "\n" ]
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
	  begin
	    stdout.putString[ " getTheNode.getName -> " ||
		  node.getTheNode.getName || "\n" ]
	    failure
	      stdout.putString["invoking getTheNode.getName failed\n"]
	    end failure
	  end
	end for
      else
        stdout.putString[ "Confarbulation error.\n" ]
      end if
    end loop
    stdout.putString[ "logout\n" ]
  end process
end shell

% EOF
