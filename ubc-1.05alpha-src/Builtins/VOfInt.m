const	VectorOfIntType <-	typeobject VectorOfIntType builtin 0x161e
		  function  getElement [Integer] -> [Integer]
		  operation setElement [Integer, Integer]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getElement [Integer, Integer] -> [VectorOfIntType]
		  function  getSlice [Integer, Integer] -> [VectorOfIntType]
		end VectorOfIntType
const VectorOfInt <- 	immutable object VectorOfInt  builtin 0x101e
	  export function getSignature -> [result : Signature]
	    result <- VectorOfIntType
	  end getSignature

	  export operation create[length : Integer] -> [result : VectorOfIntType]
	    result <-
	      object aVectorOfInt  builtin 0x141e
		export function  getElement [index : Integer] -> [result : Integer]
		  primitive self "GET" [result] <- [index]
		end getElement
		export operation setElement [index : Integer, e : Integer]
		  primitive self "SET" [] <- [index, e]
		end setElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getElement [i1 : Integer, length : Integer] -> [r : VectorOfIntType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		  
		export function  getSlice [i1 : Integer, length : Integer] -> [r : VectorOfIntType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
	      end aVectorOfInt
	  end create
	end VectorOfInt
export VectorOfInt to "Builtins"
