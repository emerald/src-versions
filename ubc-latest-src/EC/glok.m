const Set <- immutable object Set
  export function of [ElementType : Type] -> [r : SetType]
    suchthat
      ElementType *> immutable typeobject constraint 
	function = [constraint] -> [Boolean]
      end constraint
    where
      SetType <- immutable typeobject SetType
	operation create -> [AnIndividualSetType]
      end SetType
    where
      AnIndividualSetType <- typeobject AnIndividualSetType
	function  contains [ElementType] -> [Boolean]
	function  = [AnIndividualSetType] -> [Boolean]
	operation choose -> [ElementType]
      end AnIndividualSetType
    r <- class aSet
      var x : ElementType

      export function contains [e : ElementType] -> [r : Boolean]
	r <- x = e
      end contains
      
      export function = [arg : AnIndividualSetType] -> [r : Boolean]
	r <- arg.choose = x
      end =

      export operation choose -> [r : ElementType]
	r <- x
      end choose
    end aSet
  end of
end Set

const set1 <- Set.of[Integer]
const set2 <- Set.of[Character]
