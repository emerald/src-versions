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
	function intersect [SetType] -> [SetType]
	function with [etype] -> [SetType]
	operation select -> [etype, SetType]
 	function elements -> [ivoe]
	function = [SetType] -> [Boolean]
	function empty -> [Boolean]
	function contains [etype] -> [Boolean]
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
	function getSignature -> [Signature]
      end SetCreatorType
    r <- immutable object aSetCreator
      const aoe <- Array.of[etype]

      export function getSignature -> [r : Signature]
	r <- SetType
      end getSignature

      export operation empty -> [r : SetType]
	const vals <- Vector.of[etype].create[0]
	r <- self.create[vals]
      end empty

      export operation singleton [v : etype] -> [r : SetType]
	const vals <- Vector.of[etype].create[1]
	vals[0] <- v
	r <- self.create[vals]
      end singleton

      export operation create [values : Es] -> [r : SetType]
	const a <- aoe.empty
	for i : Integer <- values.lowerbound while i <= values.upperbound by i <- i + 1
	  var found : Boolean <- false
	  const value <- values[i]
	  const limit <- a.upperbound
	  for j : Integer <- 0 while j <= limit by j <- j + 1
	    if value = a[j] then found <- true exit end if
	  end for
	  if !found then a.addupper[value] end if
	end for
	r <- immutable object aSet
	  const elements : ivoe <- ivoe.literal[a]
	  export function union [x : SetType] -> [r : SetType]
	    r <- aSetCreator.create[elements.catenate[x.elements]]
	  end union
	  export function with [v : etype] -> [r : SetType]
	    if self.contains[v] then
	      r <- self
	    else
	      const size <- elements.upperbound + 1
	      const vals <- Vector.of[etype].create[size + 1]
	      for i : Integer <- 0 while i < size by i <- i + 1
		vals[i] <- elements[i]
	      end for
	      vals[size] <- v
	      r <- aSetCreator.create[vals]
	    end if
	  end with
	  export function elements -> [r : ivoe]
	    r <- elements
	  end elements
	  export function contains [v : eType] -> [r : Boolean]
	    r <- false
	    const limit <- elements.upperbound
	    for i : Integer <- 0 while i <= limit by i <- i + 1
	      if elements[i] = v then r <- true return end if
	    end for
	  end contains
	  export function intersect [x : SetType] -> [r : SetType]
	    const a <- aoe.empty
	    const limit <- elements.upperbound
	    for i : Integer <- 0 while i <= limit by i <- i + 1
	      const elem <- elements[i]
	      if x.contains[elem] then a.addupper[elem] end if
	    end for
	    r <- aSetCreator.create[a]
	  end intersect
	  export operation select -> [e : eType, r : SetType]
	    e <- elements[0]
	    r <- aSetCreator.create[elements.getSlice[1, elements.upperbound]]
	  end select
	  export function = [x : SetType] -> [r : Boolean]
	    r <- false
	    if elements.upperbound != x.elements.upperbound then
	      return
	    end if
	    const limit <- elements.upperbound
	    for i : Integer <- 0 while i <= limit by i <- i + 1
	      if !x.contains[elements[i]] then return end if
	    end for
	    r <- true
	  end =
	  export function empty -> [r : Boolean]
	    r <- elements.upperbound == -1
	  end empty
	end aSet
      end create
    end aSetCreator
  end of
end Set

