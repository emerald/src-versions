% 
% @(#)SequenceOfAny.m	1.2  3/6/91
%
const SequenceOfAny <- immutable object SequenceOfAny builtin 0x1022
  const SequenceOfAnyType <- typeobject SequenceOfAnyType builtin 0x1622
    function lowerbound -> [Integer]
    function upperbound -> [Integer]
    function getElement [Integer] -> [Any]
  end SequenceOfAnyType
  export function getSignature -> [r : Signature]
    r <- SequenceOfAnyType
  end getSignature
end SequenceOfAny

const RISA <- SequenceOfAny
export SequenceOfAny, RISA to "Builtins"
