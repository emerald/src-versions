% 
% @(#)Any.m	1.2  3/6/91
%
const Any <- immutable object Any builtin 0x1001
  const AnyType <- typeobject AnyType builtin 0x1601
  end AnyType

  export function getSignature -> [result : Signature]
    result <- AnyType
  end getSignature
  export operation create -> [ n : AnyType ]
    n <- immutable object anAny builtin 0x1401
    end anAny
  end create
end Any

export Any to "Builtins"
