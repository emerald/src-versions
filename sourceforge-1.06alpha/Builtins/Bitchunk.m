% 
% @(#)Bitchunk.m	1.2  3/6/91
%
const Bitchunk <- immutable object Bitchunk builtin 0x1013

  const BitchunkType <- typeobject BitchunkType builtin 0x1613
    function  addr -> [Integer]
    function  getSigned[Integer, Integer] -> [Integer]
    function  getUnsigned[Integer, Integer] -> [Integer]
    function  getElement[Integer, Integer] -> [Integer]
    operation setSigned[Integer, Integer, Integer]
    operation setUnsigned[Integer, Integer, Integer]
    operation setElement[Integer, Integer, Integer]
    operation ntoh[Integer, Integer]
    function = [Bitchunk] -> [Boolean]
    function != [Bitchunk] -> [Boolean]
  end BitchunkType

  export function getSignature -> [ result : Signature ]
    result <- BitchunkType
  end getSignature

  export operation create[n : Integer] -> [ r : BitchunkType ]
    r <- object aBitchunk builtin 0x1413
	
      export function addr -> [r : Integer]
	primitive self [r] <- []
      end addr
      export function getSigned [s : Integer, l : Integer] -> [ r : Integer ]
	primitive self "BGETS" [ r ] <- [ s, l ]
      end getSigned
      export function getUnsigned [s : Integer, l : Integer] -> [ r : Integer ]
	primitive self "BGETU" [ r ] <- [ s, l ]
      end getUnsigned
      export function getElement [s : Integer, l : Integer] -> [ r : Integer ]
	primitive self "BGETU" [ r ] <- [ s, l ]
      end getElement
      export operation setSigned [start : Integer, len : Integer, val : Integer]
	primitive self "BSET" [] <- [start, len, val]
      end setSigned
      export operation setUnsigned [start : Integer, len : Integer, val : Integer]
	primitive self "BSET" [] <- [start, len, val]
      end setUnsigned
      export operation setElement [start : Integer, len : Integer, val : Integer]
	primitive self "BSET" [] <- [start, len, val]
      end setElement
      export operation ntoh [start : Integer, len : Integer]
	primitive self "NTOH" [] <- [start, len]
      end ntoh
      export function = [other : Bitchunk] -> [r : Boolean]
	primitive self "SCMP" "EQ" [r] <- [other]
      end =
      export function != [other : Bitchunk] -> [r : Boolean]
	primitive self "SCMP" "NE" [r] <- [other]
      end !=
    end aBitchunk
  end create
end Bitchunk

export Bitchunk to "Builtins"
