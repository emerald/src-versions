const RIS <- typeobject RIS
  function  getElement [Integer] -> [Any]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	ImmutableVectorOfAnyType <-	immutable typeobject ImmutableVectorOfAnyType builtin 0x1621
		  function  getElement [Integer] -> [Any]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [ImmutableVectorOfAnyType]
		  function  getElement [Integer, Integer] -> [ImmutableVectorOfAnyType]
		  operation catenate [a : ImmutableVectorOfAnyType] -> [r : ImmutableVectorOfAnyType]
		  operation || [a : ImmutableVectorOfAnyType] -> [r : ImmutableVectorOfAnyType]
		end ImmutableVectorOfAnyType
const ImmutableVectorOfAny <- 	immutable object ImmutableVectorOfAny  builtin 0x1021

	  export function getSignature -> [result : Signature]
	    result <- ImmutableVectorOfAnyType
	  end getSignature

	  export operation create[length : Integer] -> [result : ImmutableVectorOfAnyType]
	    result <-
	      immutable object aImmutableVectorOfAny  builtin 0x1421
		export function  getElement [index : Integer] -> [result : Any]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfAnyType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfAnyType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : ImmutableVectorOfAnyType] -> [r : ImmutableVectorOfAnyType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : ImmutableVectorOfAnyType] -> [r : ImmutableVectorOfAnyType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aImmutableVectorOfAny
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : ImmutableVectorOfAnyType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: Any

	    i <- value.lowerbound
	    limit <- length - 1
	    r <- self.create[limit - i + 1]
	    
	    j <- 0
	    loop
	      exit when i > limit
	      e <- value[i]
	      primitive "SET" [] <- [r, j, e]
	      i <- i + 1
	      j <- j + 1
	    end loop
	  end literal
	  export operation literal [value : RIS] -> [r : ImmutableVectorOfAnyType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end ImmutableVectorOfAny
export ImmutableVectorOfAny to "Builtins"
