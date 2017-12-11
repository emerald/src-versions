const RIS <- typeobject RIS
  function  getElement [Integer] -> [String]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	ImmutableVectorOfStringType <-	immutable typeobject ImmutableVectorOfStringType builtin 0x1629
		  function  getElement [Integer] -> [String]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [ImmutableVectorOfStringType]
		  function  getElement [Integer, Integer] -> [ImmutableVectorOfStringType]
		  operation catenate [a : ImmutableVectorOfStringType] -> [r : ImmutableVectorOfStringType]
		  operation || [a : ImmutableVectorOfStringType] -> [r : ImmutableVectorOfStringType]
		end ImmutableVectorOfStringType
const ImmutableVectorOfString <- 	immutable object ImmutableVectorOfString  builtin 0x1029

	  export function getSignature -> [result : Signature]
	    result <- ImmutableVectorOfStringType
	  end getSignature

	  export operation create[length : Integer] -> [result : ImmutableVectorOfStringType]
	    result <-
	      immutable object aImmutableVectorOfString  builtin 0x1429
		export function  getElement [index : Integer] -> [result : String]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfStringType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : ImmutableVectorOfStringType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : ImmutableVectorOfStringType] -> [r : ImmutableVectorOfStringType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : ImmutableVectorOfStringType] -> [r : ImmutableVectorOfStringType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aImmutableVectorOfString
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : ImmutableVectorOfStringType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: String

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
	  export operation literal [value : RIS] -> [r : ImmutableVectorOfStringType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end ImmutableVectorOfString
export ImmutableVectorOfString to "Builtins"
