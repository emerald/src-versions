%  type A<T, S> = {
%    foo: T
%    bar: S
%    baz: A<List<T>, List<S>>
%  }
% 
%  type B<T, S> = {
%    foo: S
%    bar: T
%    baz: B<List<T>, List<S>>
%  }
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

const A <-
  immutable object A
    export function of [T : type, S : type] -> [result : AXType]
      forall
        T
      forall
	S
      where AXType <- typeobject AXType
	function getSignature -> [Signature]
      end AXType
      where TList <- List.of[T]
      where SList <- List.of[S]
      where MyA <- A.of[TList, SList]
      where AType <-
        typeobject AType
	  function foo -> [T]
	  function bar -> [S]
	  function baz -> [MyA]
	end AType

      result <-
        immutable object AX
	  export function getSignature [] -> [s: Signature]
	    s <- AType
	  end getSignature
	end AX
    end of
  end A

const B <-
  immutable object B
    export function of [T : type, S : type] -> [result : BXType]
      forall
        T
      forall
	S
      where BXType <- typeobject BXType
	function getSignature -> [Signature]
      end BXType
      where TList <- List.of[T]
      where SList <- List.of[S]
      where MyB <- B.of[TList, SList]
      where BType <-
        typeobject BType
	  function foo -> [T]
	  function bar -> [S]
	  function baz -> [MyB]
	end BType

      result <-
        immutable object BX
	  export function getSignature [] -> [s: Signature]
	    s <- BType
	  end getSignature
	end BX
    end of
  end B

