% 
% @(#)NodeListElement.m	1.2  3/6/91
%
const NodeListElement <- immutable object NodeListElement builtin 0x100e
  const NodeListElementType <- immutable typeobject T builtin 0x160e
    function getTheNode -> [ Node ]
    function getUp -> [ Boolean ]
    function getIncarnationTime -> [ Time ]
    function getLNN -> [Integer]
  end T
    
  export function getSignature -> [ result : Signature ]
    result <- NodeListElementType
  end getSignature

  export operation create 
    [ theNode : Node, up : Boolean, incarnationTime : Time, LNN : Integer ]
    -> [ n : NodeListElementType ]
    n <- immutable object aNodeListElement builtin 0x140e
      const l_theNode : Node <- theNode
      attached const l_incarnationTime : Time <- incarnationTime
      const l_up : Boolean <- up
      const l_LNN : Integer <- LNN

      export function getTheNode -> [ r : Node ]
	r <- l_theNode
      end getTheNode

      export function getUp -> [ r : Boolean ]
	r <- l_up
      end getUp

      export function getIncarnationTime -> [ r : Time ]
	r <- l_incarnationTime
      end getIncarnationTime

      export function getLNN -> [ r : Integer ]
	r <- l_LNN
      end getLNN
    end aNodeListElement
  end create
end NodeListElement

export NodeListElement to "Builtins"
