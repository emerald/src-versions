export InputBuffer, InputThing

const InputThing <- typeobject InputThing
  operation getChar -> [Character]
  function eos -> [Boolean]
  operation fillVector[VectorOfChar] -> [Integer]
end InputThing

const InputBuffer <- immutable object InputBuffer

  const BufferType <- typeobject BufferType
    operation collect [Character]
    operation reset
    function getElement[Integer] -> [Character]
    function asString -> [String]
    operation readString [InputThing, Character]
  end BufferType

  export function getSignature -> [r : Signature]
    r <- BufferType
  end getSignature

  export operation create -> [r : BufferType]
    r <- object aBuffer
	const limit <- 4096
	const b : VectorOfChar <- VectorofChar.create[limit]
	var size : Integer <- 0

	export operation reset
	  size <- 0
	end reset
  
	export operation collect [c : Character]
	  b[size] <- c
	  size <- size + 1
	end collect

	export function getElement [i : Integer] -> [r : Character]
	  r <- b[i]
	end getElement
	
	export function asString -> [r : String]
	  r <- String.FLiteral[b, 0, size]
	end asString

	export operation readString[f : InputThing, eof : Character]
	  begin
	    size <- f.fillVector[b]
	    failure
	      size <- 0
	    end failure
	  end
	  b[size] <- eof
	end readString
    end aBuffer
  end create
end InputBuffer
