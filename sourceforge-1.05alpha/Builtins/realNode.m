% 
% @(#)Node.m	1.2  3/6/91
%
const Node <- immutable object Node builtin 0x1008
  const NodeType <- typeobject NodeType builtin 0x1608
    operation getActiveNodes -> [ NodeList ]
    operation getAllNodes    -> [ NodeList ]
    operation getNodeInformation [ Node ] -> [ NodeListElement ]
    operation getTimeOfDay -> [ Time ]
    operation delay [ Time ]
    operation waitUntil [ Time ]
    operation getLoadAverage -> [ Real ]
    operation setNodeEventHandler [ Handler ]
    operation removeNodeEventHandler [ Handler ]
    operation getStdin -> [InStream]
    operation getStdout -> [OutStream]
    function  getLNN -> [Integer]
    function  getName -> [String]
    operation setRootDirectory [Directory]
    function getRootDirectory -> [Directory]
    operation setLocationServer [Any]
    function getLocationServer -> [Any]
  end NodeType

  export function getSignature -> [ result : Signature ]
    result <- NodeType
  end getSignature
  export operation getStdin -> [ result : InStream ]
    primitive "SYS" "GETSTDIN" 0 [result] <- []
  end getStdin
  export operation getStdout -> [ result : OutStream ]
    primitive "SYS" "GETSTDOUT" 0 [result] <- []
  end getStdout
  export operation create [rd : Directory, mylnn : Integer] -> [ n : NodeType ]
    n <- object aNode builtin 0x1408
      field rootDirectory : Directory <- rd
	
      operation iGetTimeOfDay -> [secs : Integer, usecs : Integer]
	primitive "SYS" "GETTOD" 0 [ secs, usecs ] <- [ ]
      end iGetTimeOfDay
      export operation getTimeOfDay -> [ t : Time ]
	var secs, usecs : Integer
	secs, usecs <- self.iGetTimeOfDay
	t <- Time.create[secs, usecs]
      end getTimeOfDay
      export operation delay [ t : Time ]
	primitive "SYS" "DELAY" 1 [ ] <- [ t ]
      end delay
      export operation waitUntil [ t : Time ]
%	primitive 108 [ ] <- [ t ]
      end waitUntil
      export operation getActiveNodes -> [ r : NodeList ]
	primitive "SYS" "GETACTIVENODES" 0 [ r ] <- [ ]
      end getActiveNodes
      export operation getAllNodes -> [ r : NodeList ]
	primitive "SYS" "GETALLNODES" 0 [ r ] <- [ ]
      end getAllNodes
      export operation getNodeInformation [ n : Node ] -> [ r : NodeListELement ]
 %	primitive 408 [ r ] <- [ n ]
      end getNodeInformation
      export operation getLoadAverage -> [ r : Real ]
%	primitive "Node_getLoadAverage" [ r ] <- [ ]
      end getLoadAverage
      export operation setNodeEventHandler [ h : Handler ]
%	primitive 508 [ ] <- [ h ]
      end setNodeEventHandler
      export operation removeNodeEventHandler [ h : Handler ]
%	primitive 608 [ ] <- [ h ]
      end removeNodeEventHandler
      export operation getStdin -> [ result : InStream ]
	primitive "SYS" "GETSTDIN" 0 [result] <- []
      end getStdin
      export operation getStdout -> [ result : OutStream ]
	primitive "SYS" "GETSTDOUT" 0 [result] <- []
      end getStdout
      export operation getLocationServer -> [ l : Any ]
	primitive "GETLOCSRV" [l] <- []
      end getLocationServer
      export operation setLocationServer [ l : Any ]
	primitive "SETLOCSRV" [] <- [l]
      end setLocationServer
      export function getLNN -> [result : Integer]
	result <- mylnn
      end getLNN
      export function getName -> [result : String]
	primitive "SYS" "GETNAME" 0 [result] <- []
      end getName
    end aNode
  end create
end Node

export Node to "Builtins"
