const RIS <- typeobject RIS
  function  getElement [Integer] -> [Signature]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	AParamListType <-	immutable typeobject AParamListType builtin 0x161d
		  function  getElement [Integer] -> [Signature]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [AParamListType]
		  function  getElement [Integer, Integer] -> [AParamListType]
		  operation catenate [a : AParamListType] -> [r : AParamListType]
		  operation || [a : AParamListType] -> [r : AParamListType]
		end AParamListType
const AParamList <- 	immutable object AParamList  builtin 0x101d

	  export function getSignature -> [result : Signature]
	    result <- AParamListType
	  end getSignature

	  export operation create[length : Integer] -> [result : AParamListType]
	    result <-
	      immutable object aAParamList  builtin 0x141d
		export function  getElement [index : Integer] -> [result : Signature]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : AParamListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : AParamListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : AParamListType] -> [r : AParamListType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : AParamListType] -> [r : AParamListType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aAParamList
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : AParamListType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: Signature

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
	  export operation literal [value : RIS] -> [r : AParamListType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end AParamList
export AParamList to "Builtins"
