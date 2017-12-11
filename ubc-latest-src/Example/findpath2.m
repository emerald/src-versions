% This is an attempt to answer Bob Gruber's question:
%   Can Emerald express the Theta function:
%     findpath[N,A](s, d: N) returns(array[N]) signals(no_path)
%       where N has arcs() yields(A), equal(N) returns(bool),
%             A has source() returns(N), dest() returns(N)

const Graph <- object Graph
  export function findPath[src : N, dst : N] -> [ans : Boolean]
    forall A
    forall N
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
    % The body of findPath goes here!!
  end findPath
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

% And then look for a path

const tester <- object tester
  initially
    const mySrc : myNode <- myNode.create
    const myDst : myNode <- myNode.create
    if graph.findpath[mySrc, myDst] then
      stdout.putstring["Found one\n"]
    else
      stdout.putstring["Can't find one\n"]
    end if
  end initially
end tester

