const RIS <- typeobject RIS
  function  getElement [Integer] -> [Integer]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	ImmutableVectorOfIntType <-	immutable typeobject ImmutableVectorOfIntType builtin 0x1623
		  function  getElement [Integer] -> [Integer]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [ImmutableVectorOfIntType]
		  function  getElement [Integer, Integer] -> [ImmutableVectorOfIntType]
		  operation catenate [a : ImmutableVectorOfIntType] -> [r : ImmutableVectorOfIntType]
		  operation || [a : ImmutableVectorOfIntType] -> [r : ImmutableVectorOfIntType]
		end ImmutableVectorOfIntType
const ImmutableVectorOfInt <- 	immutable object ImmutableVectorOfInt  builtin 0x1023

	  export function getSignature -> [result : Signature]
	    result <- ImmutableVectorOfIntType
	  end getSignature

	  export operation create[length : Integer] -> [result : ImmutableVectorOfIntType]
	    result <-
	      immutable object aImmutableVectorOfInt  builtin 0x1423
		export function  getElement [index : Integer] -> [result : Integer]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfIntType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfIntType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : ImmutableVectorOfIntType] -> [r : ImmutableVectorOfIntType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : ImmutableVectorOfIntType] -> [r : ImmutableVectorOfIntType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aImmutableVectorOfInt
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : ImmutableVectorOfIntType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: Integer

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
	  export operation literal [value : RIS] -> [r : ImmutableVectorOfIntType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end ImmutableVectorOfInt
export ImmutableVectorOfInt to "Builtins"
