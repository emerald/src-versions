const Set <- immutable object Set
  export operation containing [ElementType : Type] -> [r : SetType]
    forall 
      ElementType
    where
      SetType <- typeobject SetType
	operation insert [ElementType]
	operation choose -> [ElementType]
	function empty -> [Boolean]
      end SetType
    r <- object aSet
      const stuff <- Array.of[ElementType].empty

      export operation insert [a : ElementType]
	stuff.addUpper[a]
      end insert

      export operation choose -> [r : ElementType]
	r <- stuff.removeLower
      end choose

      export function empty -> [r : Boolean]
	r <- stuff.empty
      end empty
    end aSet
  end containing
end Set

const driver <- object driver
  initially
    const x <- Set.containing[Integer]
    x.insert[4]
    assert !x.empty
  end initially
end driver
