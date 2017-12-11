const set <- immutable object set
  export function of [etype : type] -> [r : SetCreatorType]
    suchthat
      etype *> immutable typeobject equals
	function = [equals] -> [boolean]
      end equals
    where 
      SetType <- immutable typeobject SetType
	function union [SetType] -> [SetType]
	function with [etype] -> [SetType]
      end SetType
    where
      SetCreatorType <- immutable typeobject SetCreatorType
	operation create -> [SetType]
      end SetCreatorType
    r <- immutable object aSetCreator
      export operation create -> [r : SetType]
	r <- immutable object aSet
	  export function union [x : SetType] -> [r : SetType]
	    
	  end union
	  export function with [v : etype] -> [r : SetType]

	  end with
	end aSet
      end create
    end aSetCreator
  end of
end Set

const y <- object y
  initially
    const sc <- Set.of[Any]
    const s <- sc.create
    const t <- s.union[nil]
  end initially
end y
