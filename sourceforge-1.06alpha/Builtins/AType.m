% 
% @(#)AbstractType.m	1.3  3/6/91
%
const type <- immutable object type builtin 0x1000
  const typeType <- immutable typeobject typeType builtin 0x1600
    function getSignature -> [Signature]
  end typeType
  export function getSignature -> [result : Signature]
    result <- typeType
  end getSignature
  export operation create -> [r : typeType]
    r <- immutable object aType builtin 0x1400
      export function getSignature -> [r : Signature]
	r <- typetype
      end getSignature
    end aType
  end create
end type

export type to "Builtins"
