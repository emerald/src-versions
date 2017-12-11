export List

const List <-
  immutable object List
    export function of [memberType : type] -> [result : listType]
      forall
        memberType
      where listManager <-
        typeobject listManager
	  function head [] -> [memberType]
	  function tail [] -> [listManager]
	  function null [] -> [Boolean]
	end listManager
      where listType <-
        typeobject listType
	  function getSignature [] -> [Signature]
	  function empty [] -> [listManager]
	  function cons [memberType, listManager] -> [listManager]
	end listType

      result <-
        immutable object listCons
	  export function getSignature [] -> [s: Signature]
	    s <- listManager
	  end getSignature
	  export function empty [] -> [r : listManager]
	    r <-
	      immutable object emptyList
	        export function head [] -> [r: memberType]
		  r <- nil
		end head
		export function tail [] -> [r: listManager]
		  r <- nil
		end tail
		export function null [] -> [r : Boolean]
		  r <- true
		end null
	      end emptyList
	  end empty
	  export function cons [hd: memberType, tl: listManager]
	                       -> [r: listManager]
	    r <-
	      immutable object pair
	        export function head [] -> [r: memberType]
		  r <- hd
		end head
		export function tail [] -> [r : listManager]
		  r <- tl
		end tail
		export function null [] -> [r : Boolean]
		  r <- false
		end null
	      end pair
	  end cons
	end listCons
    end of
  end List

