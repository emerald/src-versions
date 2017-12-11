const Sequence <- immutable object Sequence builtin 0x1024
  const SequenceType <- typeobject SequenceType builtin 0x1624
    function lowerbound -> [Integer]
    function upperbound -> [Integer]
    function getElement [Integer] -> [Any]
  end SequenceType
  export function getSignature -> [result : Signature]
    result <- SequenceType
  end getSignature

  export function of [T : Type] -> [result : Signature]
    forall T
    result <- typeobject aNewSequence
      function lowerbound -> [Integer]
      function upperbound -> [Integer]
      function getElement [Integer] -> [T]
    end aNewSequence
  end of
end Sequence

export Sequence to "Builtins"


