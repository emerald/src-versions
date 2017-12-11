export set

const set <- immutable object set
  export function of [etype : type] -> [r : SetCreatorType]
    suchthat
      etype *> immutable typeobject equals
	function = [equals] -> [boolean]
      end equals
    where
      ivoe <- ImmutableVector.of[etype]
    where 
      SetType <- immutable typeobject SetType
	function union [SetType] -> [SetType]
	function with [etype] -> [SetType]
	function elements -> [ivoe]
      end SetType
    where
      Es <- typeobject Es
	function lowerbound -> [Integer]
	function upperbound -> [Integer]
	function getElement[Integer] -> [etype]
      end Es
    where
      SetCreatorType <- immutable typeobject SetCreatorType
	operation create[Es] -> [SetType]
	operation empty -> [SetType]
	operation singleton [etype] -> [SetType]
      end SetCreatorType
    r <- immutable object aSetCreator

      export operation empty -> [r : SetType]
	r <- self.create[{:etype}]
      end empty

      export operation singleton [v : etype] -> [r : SetType]
	r <- self.create[{ v : etype }]
      end singleton

      export operation create [values : Es] -> [r : SetType]
	const aoe <- Array.of[etype]
	const a <- aoe.empty
	for i : Integer <- values.lowerbound while i <= values.upperbound by i <- i + 1
	  var found : Boolean <- false
	  const value <- values[i]
	  for j : Integer <- 0 while j <= a.upperbound by j <- j + 1
	    if value = a[j] then found <- true exit end if
	  end for
	  if !found then a.addupper[value] end if
	end for
	r <- immutable object aSet
	  const elements : ivoe <- ivoe.literal[a]
	  export function union [x : SetType] -> [r : SetType]
	    r <- x
	  end union
	  export function with [v : etype] -> [r : SetType]
	    r <- nil
	  end with
	  export function elements -> [r : ivoe]
	    r <- elements
	  end elements
	end aSet
      end create
    end aSetCreator
  end of
end Set

const sc <- Set.of[Integer]
