% 
% @(#)Nil.m	1.2  3/6/91
%
export None to "Builtins"

const None <- immutable object None builtin 0x1007
  const NoneType <- immutable typeobject NoneType builtin 0x1607
  end NoneType
  export function getSignature -> [result : Signature]
    result <- NoneType
  end getSignature
  export operation create -> [ n : NoneType ]
    n <- immutable object aNil builtin 0x1407
    end aNil
  end create
end None
