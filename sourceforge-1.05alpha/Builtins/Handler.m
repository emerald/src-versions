% 
% @(#)Handler.m	1.2  3/6/91
%
const Handler <- immutable object Handler builtin 0x1015
  const HandlerType <- typeobject HandlerType builtin 0x1615
    operation nodeUp [ Node, Time ]
    operation nodeDown [ Node, Time ]
  end HandlerType
  export function getSignature -> [r : Signature]
    r <- HandlerType
  end getSignature
end Handler

export Handler to "Builtins"
