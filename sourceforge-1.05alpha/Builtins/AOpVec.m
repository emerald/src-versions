const RIS <- typeobject RIS
  function  getElement [Integer] -> [AOpVectorE]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	AOpVectorType <-	immutable typeobject AOpVectorType builtin 0x161b
		  function  getElement [Integer] -> [AOpVectorE]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [AOpVectorType]
		  function  getElement [Integer, Integer] -> [AOpVectorType]
		  operation catenate [a : AOpVectorType] -> [r : AOpVectorType]
		  operation || [a : AOpVectorType] -> [r : AOpVectorType]
		end AOpVectorType
const AOpVector <- 	immutable object AOpVector  builtin 0x101b

	  export function getSignature -> [result : Signature]
	    result <- AOpVectorType
	  end getSignature

	  export operation create[length : Integer] -> [result : AOpVectorType]
	    result <-
	      immutable object aAOpVector  builtin 0x141b
		export function  getElement [index : Integer] -> [result : AOpVectorE]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : AOpVectorType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : AOpVectorType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : AOpVectorType] -> [r : AOpVectorType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : AOpVectorType] -> [r : AOpVectorType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aAOpVector
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : AOpVectorType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: AOpVectorE

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
	  export operation literal [value : RIS] -> [r : AOpVectorType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end AOpVector
export AOpVector to "Builtins"
