export ListFuns

const ListFuns <-
  immutable object ListFuns
    export function of [memberType : type] -> [result : LFType]
      forall memberType
      where LO <- List.of[memberType]
      where LFType <-
        typeobject LFType
	  function append [LO, LO] -> [LO]
	  function reverse [LO] -> [LO]
	end LFType

      result <-
        immutable object LF
	  function reverseto [l1 : LO, l2 : LO] -> [r : LO]
	    if l1.null
            then
	      r <- l2
	    else
	      r <- self.reverseto[l1.tail, LO.cons[l1.head, l2]]
	    end if
	  end reverseto
	  export function append [l1 : LO, l2 : LO] -> [r : LO]
	    r <- self.reverseto[self.reverse[l1], l2]
	  end append
	  export function reverse [l : LO] -> [r : LO]
	    r <- self.reverseto[l, LO.empty]
	  end reverse
	end LF
    end of
  end ListFuns
