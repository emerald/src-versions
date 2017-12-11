% This is an attempt to answer Bob Gruber's question:
%   Can Emerald express the Theta function:
%     findpath[N,A](s, d: N) returns(array[N]) signals(no_path)
%       where N has arcs() yields(A), equal(N) returns(bool),
%             A has source() returns(N), dest() returns(N)

const Graph <- immutable object Graph
  export function of[N : type, A : type] -> [something : theGraphType]
    where
      theGraphType <- typeobject theGraphType
	  function findPath [src : N, dst : N] -> [Array.of[N]]
	end theGraphType
    suchthat
      N *> typeobject aNode
	function arcs -> [Array.of[A]]
	function equal [aNode] -> [Boolean]
      end aNode
    suchthat
      A *> typeobject anArc
	function source -> [N]
	function dest -> [N]
      end anArc
    something <- object agraph
      export function findPath[src : N, dst : N] -> [ans : Array.of[N]]
	ans <- nil
      end findPath
    end agraph
  end of
end Graph

const myNode <- class myNode
  var arcs : Array.of[myArc]

  export function arcs -> [r : Array.of[myArc]]
    r <- arcs
  end arcs
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

const tester <- object tester
%  const foo <- Graph.of[Integer, String]
  const foo <- Graph.of[myNode, myArc]
  const blotto <- foo.findpath[nil, nil]
end tester
