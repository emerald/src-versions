export Map

const Map <- immutable object Map
  export function of [ktype : type, vtype : type] -> [r : MapCreatorType]
    suchthat
      ktype *> immutable typeobject key
	function = [key] -> [boolean]
	function < [key] -> [boolean]
	function hash -> [integer]
      end key
    forall
      vtype
    where 
      MapType <- typeobject MapType
	operation insert [key : ktype, value : vtype]
	operation delete [key : ktype]
	function  lookup [key : ktype] -> [value : vtype]
      end MapType
    where
      MapCreatorType <- immutable typeobject MapCreatorType
	operation create -> [MapType]
	function getSignature -> [Signature]
      end MapCreatorType
    r <- class aMapCreator
      const aok <- Array.of[ktype]
      const aov <- Array.of[vtype]

      const keys <- aok.empty
      const values <- aov.empty

      export operation insert [key : ktype, value : vtype]
	const limit <- keys.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  if keys[i] = key then
	    values[i] <- value
	    return
	  end if
	end for
	keys.addUpper[key]
	values.addUpper[value]
      end insert

      export operation delete [key : ktype]
	const limit <- keys.upperbound
	var found : Boolean <- false
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  if keys[i] = key then
	    assert !found
	    found <- true
	  elseif found then
	    keys[i-1] <- keys[i]
	    values[i-1] <- values[i]
	  end if
	end for
      end delete
      export function lookup [key : ktype] -> [value : vtype]
	const limit <- keys.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  if keys[i] = key then
	    value <- values[i]
	    return
	  end if
	end for
      end lookup
    end aMapCreator
  end of
end Map

