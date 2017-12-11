% This is an attempt to answer Bob Gruber's question:
%   Can Emerald express the Theta function:
%     findpath[N,A](s, d: N) returns(array[N]) signals(no_path)
%       where N has arcs() yields(A), equal(N) returns(bool),
%             A has source() returns(N), dest() returns(N)

const Graph <- immutable object Graph
  export function of[N : type, A : type] -> [something : theGraphType]
    where 
      theGraphType <- typeobject theGraphType
	  function findPath [src : N, dst : N] -> [Boolean]
	end theGraphType
    suchthat
      N *> typeobject aNode
	function arcN [Integer] -> [A]
	function equal [aNode] -> [Boolean]
      end aNode
    suchthat
      A *> typeobject anArc
	function source -> [N]
	function dest -> [N]
      end anArc
    something <- object agraph
      export function findPath[src : N, dst : N] -> [ans : Boolean]
	% The body of findPath goes here!!
      end findPath
    end agraph
  end of
end Graph

% An example of the use of graph, first create the node and arc types

const myNode <- class myNode
  var arcs : Vector.of[myArc] 
  
  export function arcN[index : Integer] -> [r : myArc]
    r <- arcs[index]
  end arcN
  export function equal [o : myNode] -> [r : Boolean]
    r <- o == self
  end equal
end myNode

const myArc <- class myArc[src : myNode, dst : myNode]
  export function source -> [r : myNode]
    r <- src
  end source
  export function dest -> [r : myNode]
    r <- dst
  end dest
end myArc

% And then build the pathfinder for graphs built out of those types

const tester <- object tester
  const foo <- Graph.of[myNode, String]
  const bar <- Graph.of[myNode, myArc]
  const blotto <- foo.findpath[nil, nil]
end tester

