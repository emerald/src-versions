const matrix <- immutable object matrix
  export function of [eType : Type] -> [r : MCType]
    forall
      eType
    where voe <- Vector.of[eType]
    where
      MCType <- immutable typeobject MCType
	operation create [Integer, Integer] -> [MType]
	function getSignature -> [Signature]
      end MCType
    where
      MType <- typeobject MType
	operation setAll[eType]
	operation setElement[Integer, Integer, eType]
	operation getElement[Integer, Integer] -> [eType]
      end MType
    r <- class MClass [b1 : Integer, b2 : Integer]
      const e <- voe.create[b1 * b2]

      export operation setAll[v : eType]
	const limit <- e.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  e[i] <- v
	end for
      end setAll

      export operation setElement[i1 : Integer, i2 : Integer, v : eType]
	assert i1 < b1
	assert i2 < b2
	e[i2 + i1 * b2] <- v
      end setElement

      export function getElement[i1 : Integer, i2 : Integer] -> [v : eType]
	assert i1 < b1
	assert i2 < b2
	v <- e[i2 + i1 * b2]
      end getElement
    end MClass
  end of
end matrix

export matrix
