const	VectorOfCharType <-	typeobject VectorOfCharType builtin 0x1616
		  function  getElement [Integer] -> [Character]
		  operation setElement [Integer, Character]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getElement [Integer, Integer] -> [VectorOfCharType]
		  function  getSlice [Integer, Integer] -> [VectorOfCharType]
		end VectorOfCharType
const VectorOfChar <- 	immutable object VectorOfChar  builtin 0x1016
	  export function getSignature -> [result : Signature]
	    result <- VectorOfCharType
	  end getSignature

	  export operation create[length : Integer] -> [result : VectorOfCharType]
	    result <-
	      object aVectorOfChar  builtin 0x1416
		export function  getElement [index : Integer] -> [result : Character]
		  primitive self "GET" [result] <- [index]
		end getElement
		export operation setElement [index : Integer, e : Character]
		  primitive self "SET" [] <- [index, e]
		end setElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getElement [i1 : Integer, length : Integer] -> [r : VectorOfCharType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		  
		export function  getSlice [i1 : Integer, length : Integer] -> [r : VectorOfCharType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
	      end aVectorOfChar
	  end create
	end VectorOfChar
export VectorOfChar to "Builtins"
