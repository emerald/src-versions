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
    r <- class Map
      const elem <- class elem[pkey : ktype, pvalue : vtype, pnext : elem]
	const field key : ktype <- pkey
	field value : vtype <- pvalue
	field next : elem <- pnext
      end elem
      const size <- 257
      const table <- Vector.of[elem].create[size]

      export operation insert [key : ktype, value : vtype]
	const index <- key.hash # size
	var runner : elem <- table[index]
	var trailer : elem <- nil
	loop
	  exit when runner == nil
	  if runner$key = key then
	    runner$value <- value
	    return
	  elseif runner$key < key then
	    trailer <- runner
	    runner <- runner$next
	  else
	    exit
	  end if
	end loop
	const n <- elem.create[key, value, runner]
	if trailer == nil then
	  table[index] <- n
	else
	  trailer$next <- n
	end if
      end insert

      export operation delete [key : ktype]
	const index <- key.hash # size
	var runner : elem <- table[index]
	var trailer : elem <- nil
	loop
	  exit when runner == nil
	  if runner$key = key then
	    if trailer == nil then
	      table[index] <- runner$next
	    else
	      trailer$next <- runner$next
	    end if
	    return
	  elseif runner$key < key then
	    trailer <- runner
	    runner <- runner$next
	  else
	    exit
	  end if
	end loop
      end delete
      export function lookup [key : ktype] -> [value : vtype]
	const index <- key.hash # size
	var runner : elem <- table[index]
	loop
	  exit when runner == nil
	  if runner$key = key then
	    value <- runner$value
	    return
	  elseif runner$key < key then
	    runner <- runner$next
	  else
	    exit
	  end if
	end loop
      end lookup
    end Map
  end of
end Map

