const	VectorOfStringType <-	typeobject VectorOfStringType builtin 0x162a
		  function  getElement [Integer] -> [String]
		  operation setElement [Integer, String]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getElement [Integer, Integer] -> [VectorOfStringType]
		  function  getSlice [Integer, Integer] -> [VectorOfStringType]
		end VectorOfStringType
const VectorOfString <- 	immutable object VectorOfString  builtin 0x102a
	  export function getSignature -> [result : Signature]
	    result <- VectorOfStringType
	  end getSignature

	  export operation create[length : Integer] -> [result : VectorOfStringType]
	    result <-
	      object aVectorOfString  builtin 0x142a
		export function  getElement [index : Integer] -> [result : String]
		  primitive self "GET" [result] <- [index]
		end getElement
		export operation setElement [index : Integer, e : String]
		  primitive self "SET" [] <- [index, e]
		end setElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getElement [i1 : Integer, length : Integer] -> [r : VectorOfStringType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		  
		export function  getSlice [i1 : Integer, length : Integer] -> [r : VectorOfStringType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
	      end aVectorOfString
	  end create
	end VectorOfString
export VectorOfString to "Builtins"
