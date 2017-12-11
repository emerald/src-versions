const RIS <- typeobject RIS
  function  getElement [Integer] -> [Integer]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	LiteralListType <-	immutable typeobject LiteralListType builtin 0x1627
		  function  getElement [Integer] -> [Integer]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [LiteralListType]
		  function  getElement [Integer, Integer] -> [LiteralListType]
		  operation catenate [a : LiteralListType] -> [r : LiteralListType]
		end LiteralListType
const LiteralList <- 	immutable object LiteralList  builtin 0x1027

	  export function getSignature -> [result : Signature]
	    result <- LiteralListType
	  end getSignature

	  export operation create[length : Integer] -> [result : LiteralListType]
	    result <-
	      immutable object aLiteralList  builtin 0x1427
		export function  getElement [index : Integer] -> [result : Integer]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : LiteralListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : LiteralListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : LiteralListType] -> [r : LiteralListType]
		  primitive self "CAT" [r] <- [a]
		end catenate
	      end aLiteralList
	  end create
	  export operation literal[value : RIS] -> [r : LiteralListType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: Integer

	    i <- value.lowerbound
	    limit <- value.upperbound
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
	end LiteralList
export LiteralList to "Builtins"
