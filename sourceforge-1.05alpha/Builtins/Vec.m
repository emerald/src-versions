% 
% @(#)Vector.m	1.2  3/6/91
%
const Vector <- 
  immutable object Vector builtin 0x100c
    export function of [ElementType : type] -> [result : NVT]
      forall
	ElementType
      where
	NV <-	typeobject NV builtin 0x160c
		  function  getElement [Integer] -> [ElementType]
		    % get the element indexed by index, failing if index 
		    % out of range.
		  operation setElement [Integer, ElementType]
		    % set the element, failing if index out of range
		  function  upperbound -> [Integer]
		    % return the highest valid index, ub.
		  function  lowerbound -> [Integer]
		    % return the lowest valid index, always 1.
		  function  getElement [Integer, Integer] -> [NV]
		  function  getSlice [Integer, Integer] -> [NV]
		    % See implementation comment
		end NV
      where
	NVT <-	immutable typeobject NVT
		  operation create [Integer] -> [NV]
		  function getSignature -> [Signature]
		end NVT

      result <- 
	immutable object aNVT 
	  export function getSignature -> [result : Signature]
	    result <- NV
	  end getSignature

	  export operation create[length : Integer] -> [result : NV]
	    result <-
	      object aNV builtin 0x140c
		export function  getElement [index : Integer] -> [result : ElementType]
		  % get the element indexed by index, failing if index 
		  % out of range.
		  primitive self "GET" [result] <- [index]
		end getElement
		export operation setElement [index : Integer, e : ElementType]
		  % set the element, failing if index out of range
		  primitive self "SET" [] <- [index, e]
		end setElement
		export function  upperbound -> [r : Integer]
		  % return the highest valid index, ub.
		  primitive self "UPB" [r] <- []
		end upperbound
		export function  lowerbound -> [r : Integer]
		  % return the lowest valid index, always 1.
		  primitive "LDIB" 0 [r] <- []
		end lowerbound
		export function  getElement [i1 : Integer, length : Integer] -> [r : NV]
		  primitive self "GSLICE" [r] <- [i1, length]
		end getElement
		  
		export function  getSlice [i1 : Integer, length : Integer] -> [r : NV]
		  % return a new Vector, a, with lower bound 0, and 
		  % upper bound length-1, such that for 0 <= i < length:
		  %     self.getElement[i1+i] == a.getElement[i]
		  % fail if i1 or i1+length is out of range.
		  primitive self "GSLICE" [r] <- [i1, length]
		end getSlice
	      end aNV
	  end create
	end aNVT
    end of
  end Vector

export Vector to "Builtins"
