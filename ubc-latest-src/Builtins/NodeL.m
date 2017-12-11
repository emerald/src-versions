const RIS <- typeobject RIS
  function  getElement [Integer] -> [NodeListElement]
  function  upperbound -> [Integer]
  function  lowerbound -> [Integer]
end RIS
const	NodeListType <-	immutable typeobject NodeListType builtin 0x160f
		  function  getElement [Integer] -> [NodeListElement]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		  function  getSlice [Integer, Integer] -> [NodeListType]
		  function  getElement [Integer, Integer] -> [NodeListType]
		  operation catenate [a : NodeListType] -> [r : NodeListType]
		  operation || [a : NodeListType] -> [r : NodeListType]
		end NodeListType
const NodeList <- 	immutable object NodeList  builtin 0x100f

	  export function getSignature -> [result : Signature]
	    result <- NodeListType
	  end getSignature

	  export operation create[length : Integer] -> [result : NodeListType]
	    result <-
	      immutable object aNodeList  builtin 0x140f
		export function  getElement [index : Integer] -> [result : NodeListElement]
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : NodeListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : NodeListType]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : NodeListType] -> [r : NodeListType]
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : NodeListType] -> [r : NodeListType]
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aNodeList
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : NodeListType]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: NodeListElement

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
	  export operation literal [value : RIS] -> [r : NodeListType]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end NodeList
export NodeList to "Builtins"
