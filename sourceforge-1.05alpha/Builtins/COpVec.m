const RIS <- typeobject RIS
  function  getElement [Integer] -> [COpVectorE]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	COpVectorType <-	immutable typeobject COpVectorType builtin 0x1619
		  function  getElement [Integer] -> [COpVectorE]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [COpVectorType]
		  function  getElement [Integer, Integer] -> [COpVectorType]
		  operation catenate [a : COpVectorType] -> [r : COpVectorType]
		  operation || [a : COpVectorType] -> [r : COpVectorType]
		end COpVectorType
const COpVector <- 	immutable object COpVector  builtin 0x1019

	  export function getSignature -> [result : Signature]
	    result <- COpVectorType
	  end getSignature

	  export operation create[length : Integer] -> [result : COpVectorType]
	    result <-
	      immutable object aCOpVector  builtin 0x1419
		export function  getElement [index : Integer] -> [result : COpVectorE]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : COpVectorType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : COpVectorType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : COpVectorType] -> [r : COpVectorType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : COpVectorType] -> [r : COpVectorType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aCOpVector
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : COpVectorType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: COpVectorE

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
	  export operation literal [value : RIS] -> [r : COpVectorType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end COpVector
export COpVector to "Builtins"
