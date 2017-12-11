const matrix <- immutable object matrix
  export function of [eType : Type] -> [r : MCType]
    forall
      eType
    where
      MCType <- immutable typeobject MCType
	operation create [Integer, Integer, Integer] -> [MType]
	function getSignature -> [Signature]
      end MCType
    where
      MType <- typeobject MType
	operation setElement[Integer, Integer, Integer, eType]
	operation getElement[Integer, Integer, Integer] -> [eType]
      end MType
    r <- class M [b1 : Integer, b2 : Integer, b3 : Integer]
      const e <- Vector.of[eType].create[b1 * b2 * b3]

      export operation setElement[i1 : Integer, i2 : Integer, i3 : Integer, v : eType]
	assert i1 < b1
	assert i2 < b2
	assert i3 < b3
	e[i3 + i2 * b3 + i1 * b2 * b3] <- v
      end setElement
      export function getElement[i1 : Integer, i2 : Integer, i3 : Integer] -> [v : eType]
	assert i1 < b1
	assert i2 < b2
	assert i3 < b3
	v <- e[i3 + i2 * b3 + i1 * b2 * b3]
      end getElement
    end M
  end of
end matrix

export matrix
