const List <-
  immutable object AList
    export function of [X : type] -> [result : ListMType]
      forall
	X
      where ListType <- typeobject ListType
	function isEmpty -> [boolean]
      end ListType
      where ListMType <- typeobject ListMType
	function empty -> [ListType]
      end ListMType
        result <-
        immutable object AListMType
	  export function getSignature [] -> [s: Signature]
	    s <- ListType
	  end getSignature
	  export function empty [] -> [r: ListType]
	    r <- object aList
	      export function isEmpty -> [r : Boolean]
		r <- true
	      end isEmpty
	    end aList
	  end empty
	end AListMType
    end of
  end AList
