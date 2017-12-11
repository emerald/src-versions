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
    function  getIncarnationTime -> [Time]
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
      var eventhandlers : VectorOfAny
	
      operation iGetTimeOfDay -> [secs : Integer, usecs : Integer]
	primitive "SYS" "GETTOD" 0 [ secs, usecs ] <- [ ]
      end iGetTimeOfDay
      export operation getTimeOfDay -> [ t : Time ]
	var secs, usecs : Integer
	secs, usecs <- self.iGetTimeOfDay
	t <- Time.create[secs, usecs]
      end getTimeOfDay
      export operation delay [ t : Time ]
	primitive "SYS" "JDELAY" 1 [ ] <- [ t ]
      end delay
      export operation waitUntil [ t : Time ]
	const sep : Time <- t - self.getTimeOfDay
	primitive "SYS" "JDELAY" 1 [ ] <- [ sep ]
      end waitUntil
      export operation getActiveNodes -> [ r : NodeList ]
	primitive "SYS" "GETACTIVENODES" 0 [ r ] <- [ ]
      end getActiveNodes
      export operation getAllNodes -> [ r : NodeList ]
	primitive "SYS" "GETALLNODES" 0 [ r ] <- [ ]
      end getAllNodes
      export operation getNodeInformation [ n : Node ] -> [ r : NodeListELement ]
	var incarnationTime : Time
	primitive "SYS" "JGETINCARNATIONTIME" 0 [incarnationTime] <- []
	r <- NodeListElement.create[self, true, incarnationTime, mylnn]
      end getNodeInformation
      export operation getLoadAverage -> [ r : Real ]
	primitive "SYS" "JGETLOADAVERAGE" 0 [ r ] <- [ ]
      end getLoadAverage
      export operation setNodeEventHandler [ h : Handler ]
	if eventhandlers == nil then
	  eventhandlers <- VectorOfAny.create[8]
	end if
	const upb : Integer <- eventhandlers.upperbound
	const len : Integer <- upb + 1
	for i : Integer <- 0 while i < len by i <- i + 1
	  const th : Handler <- eventhandlers[i]
	  if th == h then
	    return
	  end if
	end for
	for i : Integer <- 0 while i < len by i <- i + 1
	  const th : Handler <- eventhandlers[i]
	  if th == nil then
	    eventhandlers[i] <- h
	    return
	  end if
	end for
	%
	% Grow the handlers
	%
	const oldeventhandlers <- eventhandlers
	eventhandlers <- VectorOfAny.create[2 * len]
	for i : Integer <- 0 while i < len by i <- i + 1
	  const th : Handler <- oldeventhandlers[i] 
	  eventhandlers[i] <- th
	end for
	eventhandlers[len] <- h
      end setNodeEventHandler
      export operation removeNodeEventHandler [ h : Handler ]
	if eventhandlers == nil then return end if
	const upb : Integer <- eventhandlers.upperbound
	const len : Integer <- upb + 1
	for i : Integer <- 0 while i < len by i <- i + 1
	  const th : Handler <- eventhandlers[i]
	  if th == h then
	    eventhandlers[i] <- nil
	    return
	  end if
	end for
      end removeNodeEventHandler
      export operation nodeUp [n : Node, t : Time]
	if eventhandlers == nil then return end if
	const upb : Integer <- eventhandlers.upperbound
	const len : Integer <- upb + 1
	for i : Integer <- 0 while i < len by i <- i + 1
	  const h : Handler <- eventhandlers[i]
	  if h !== nil then
	    const invokeUp <- object invokeUp
	      process
		h.nodeUp[n, t]
	      end process
	    end invokeUp
	  end if
	end for
      end nodeUp
      export operation nodeDown [n : Node, t : Time]
	if eventhandlers == nil then return end if
	const upb : Integer <- eventhandlers.upperbound
	const len : Integer <- upb + 1
	for i : Integer <- 0 while i < len by i <- i + 1
	  const h : Handler <- eventhandlers[i]
	  if h !== nil then
	    const invokeDown <- object invokeDown
	      process
		h.nodeDown[n, t]
	      end process
	    end invokeDown
	  end if
	end for
      end nodeDown
      export operation getStdin -> [ result : InStream ]
	primitive "SYS" "GETSTDIN" 0 [result] <- []
      end getStdin
      export operation getStdout -> [ result : OutStream ]
	primitive "SYS" "GETSTDOUT" 0 [result] <- []
      end getStdout
      export function getLNN -> [result : Integer]
	result <- mylnn
      end getLNN
      export function getName -> [result : String]
	primitive "SYS" "GETNAME" 0 [result] <- []
      end getName
      export function getIncarnationTime -> [result : Time]
	primitive "SYS" "JGETINCARNATIONTIME" 0 [result] <- []
      end getIncarnationTime
      export operation getLocationServer -> [ l : Any ]
	primitive var "GETLOCSRV" [l] <- []
      end getLocationServer
      export operation setLocationServer [ l : Any ]
	primitive "SETLOCSRV" [] <- [l]
      end setLocationServer
    end aNode
  end create
end Node

export Node to "Builtins"
