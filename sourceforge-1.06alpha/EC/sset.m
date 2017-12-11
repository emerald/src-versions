const Set <- immutable object Set
  export operation of [ElementType : Type] -> [r : SetType]
    suchthat
      ElementType *> typeobject constraint 
      end constraint
    where
      SetType <- typeobject SetType
	function  contains [ElementType] -> [Boolean]
	function  = [SetType] -> [Boolean]
	operation choose -> [ElementType]
      end SetType
    r <- object aSet
      var x : ElementType
      export function contains [e : ElementType] -> [r : Boolean]
	r <- x == e
      end contains
      
      export function = [arg : SetType] -> [r : Boolean]
	r <- arg.choose == x
      end =

      export operation choose -> [r : ElementType]
	r <- x
      end choose
    end aSet
  end of
end Set

const set1 <- Set.of[Integer]
const set2 <- Set.of[Character]

const set1type <- typeof set1
const set2type <- typeof set2
