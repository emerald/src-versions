% 
% @(#)ImmutableVector.m	1.2  3/6/91
%

const immutableVector <- 
  immutable object immutableVector builtin 0x1012
    export function of [ElementType : type] -> [result : NIMVT]
      forall
	ElementType
      where
	NV <-	immutable typeobject NV builtin 0x1612
		  function  getElement [Integer] -> [ElementType]
		    % get the element indexed by index, failing if index 
		    % out of range.
		  function  upperbound -> [Integer]
		    % return the highest valid index, ub.
		  function  lowerbound -> [Integer]
		    % return the lowest valid index, always 0.
		  function  getSlice [Integer, Integer] -> [NV]
		  function  getElement [Integer, Integer] -> [NV]
		    % See implementation comment
		  operation catenate [a : NV] -> [r : NV]
		    % return a new vector the result of catenating the 
		    % elements of a to self
		  operation || [a : NV] -> [r : NV]
		    % return a new vector the result of catenating the 
		    % elements of a to self
		end NV
      where
	RIS <-  typeobject RIS
		  function  getElement [Integer] -> [ElementType]
		  function  upperbound -> [Integer]
		  function  lowerbound -> [Integer]
		end RIS
      where
	NIMVT <-immutable typeobject NIMVT
		  operation create [Integer] -> [NV]
		  operation literal [RIS] -> [NV]
		  operation literal [RIS, Integer] -> [NV]
		  function getSignature -> [Signature]
		end NIMVT

      result <- 
	immutable object aNVT 

	  export function getSignature -> [result : Signature]
	    result <- NV
	  end getSignature

	  export operation create[length : Integer] -> [result : NV]
	    result <-
	      immutable object aNV builtin 0x1412
		export function  getElement [index : Integer] -> [result : ElementType]
		  % get the element indexed by index, failing if index 
		  % out of range.
		  primitive self "GET" [result] <- [index]
		end getElement
		export function  upperbound -> [r : Integer]
		  % return the highest valid index, ub.
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  % return the lowest valid index, always 1.
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getSlice [i1 : Integer, length : Integer] -> [r : NV]
		  % return a new Vector, a, with lower bound 0, and 
		  % upper bound length-1, such that for 0 <= i < length:
		  %     self.getElement[i1+i] == a.getElement[i]
		  % fail if i1 or i1+length is out of range.
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
		export function  getElement [i1 : Integer, length : Integer] -> [r : NV]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		export operation catenate [a : NV] -> [r : NV]
		  % return a new vector the result of catenating the 
		  % elements of a to self
		  primitive self "CAT" [r] <- [a]
		end catenate
		export operation || [a : NV] -> [r : NV]
		  % return a new vector the result of catenating the 
		  % elements of a to self
		  primitive self "CAT" [r] <- [a]
		end ||
	      end aNV
	  end create
	  export operation literal[value : RIS, length : Integer] -> [r : NV]
	    var i	: Integer
	    var j 	: Integer
	    var limit	: Integer
	    var e	: ElementType

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
	  export operation literal [value : RIS] -> [r : NV]
	    r <- self.literal[value, value.upperbound + 1]
	  end literal
	end aNVT
    end of
  end immutableVector

export immutableVector to "Builtins"
