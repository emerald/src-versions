% 
% @(#)SequenceOfCharacter.m	1.2  3/6/91
%
const SequenceOfCharacter <- immutable object SequenceOfCharacter builtin 0x1014
  const SequenceOfCharacterType <- typeobject SequenceOfCharacterType builtin 0x1614
    function lowerbound -> [Integer]
    function upperbound -> [Integer]
    function getElement [Integer] -> [Character]
  end SequenceOfCharacterType
  export function getSignature -> [r : Signature]
    r <- SequenceOfCharacterType
  end getSignature
end SequenceOfCharacter

const RISC <- SequenceOfCharacter
export SequenceOfCharacter, RISC to "Builtins"
