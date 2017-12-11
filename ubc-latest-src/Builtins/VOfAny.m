const	VectorOfAnyType <-	typeobject VectorOfAnyType builtin 0x1628
		  function  getElement [Integer] -> [Any]
		  operation setElement [Integer, Any]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getElement [Integer, Integer] -> [VectorOfAnyType]
		  function  getSlice [Integer, Integer] -> [VectorOfAnyType]
		end VectorOfAnyType
const VectorOfAny <- 	immutable object VectorOfAny  builtin 0x1028
	  export function getSignature -> [result : Signature]
	    result <- VectorOfAnyType
	  end getSignature

	  export operation create[length : Integer] -> [result : VectorOfAnyType]
	    result <-
	      object aVectorOfAny  builtin 0x1428
		export function  getElement [index : Integer] -> [result : Any]
		  primitive self "GET" [result] <- [index]
		end getElement
		export operation setElement [index : Integer, e : Any]
		  primitive self "SET" [] <- [index, e]
		end setElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getElement [i1 : Integer, length : Integer] -> [r : VectorOfAnyType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		  
		export function  getSlice [i1 : Integer, length : Integer] -> [r : VectorOfAnyType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
	      end aVectorOfAny
	  end create
	end VectorOfAny
export VectorOfAny to "Builtins"
