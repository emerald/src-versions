export Assoc

const Assoc <- immutable object Assoc
  export function of [ktype : type, etype : type] -> [r : AssocCreatorType]
    suchthat
      ktype *> immutable typeobject equalshash
	function = [equalshash] -> [boolean]
	function hash -> [Integer]
      end equalshash
    forall
      etype
    where 
      theAssocType <- typeobject theAssocType
	operation insert [ktype, etype]
	function lookup [ktype] -> [etype]
	operation delete [ktype]
      end theAssocType
    where
      AssocCreatorType <- immutable typeobject AssocCreatorType
	operation create -> [TheAssocType]
	function getSignature -> [Signature]
      end AssocCreatorType
    r <- immutable object anAssocCreator
      const vok <- Vector.of[ktype]
      const voe <- Vector.of[etype]

      export function getSignature -> [r : Signature]
	r <- TheAssocType
      end getSignature

      export operation create -> [r : TheAssocType]
	r <- object anAssoc
	  var currentsize : Integer <- 8
	  var keys : vok <- vok.create[currentsize]
	  var values : voe <- voe.create[currentsize]
	  var count  : Integer <- 0
	  var limit  : Integer <- (currentsize * 4) / 5

	  operation iInsert [k : ktype, v : etype]
	    const first <- k.hash # currentsize
	    var h : Integer <- first
	    loop
	      const key <- keys[h]
	      if key == nil then
		values[h] <- v
		keys[h] <- k
		return
	      elseif key = k then
		values[h] <- v
		count <- count - 1
		return
	      end if
	      h <- (h + 1) # currentsize
	      exit when h = first
	    end loop
	  end iInsert

	  operation enlarge
	    const oldkeys <- keys
	    const oldvalues   <- values
	    const oldsize   <- currentsize
      
	    currentsize <- currentsize * 2
	    limit <- (currentsize * 4) / 5
	    keys <- vok.create[currentsize]
	    values   <- voe.create[currentsize]
	    for i : Integer <- 0 while i < oldsize by i <- i + 1
	      const k <- oldkeys[i]
	      if k !== nil then
		self.iInsert[k, oldvalues[i]]
	      end if
	    end for
	  end enlarge
      
	  export operation Lookup [k : ktype] -> [v : etype]
	    var h : Integer <- k.hash # currentsize
	    loop
	      const key <- keys[h]
	      if key == nil then
		return
	      elseif key = k then
		v <- values[h]
		return
	      end if
	      h <- (h + 1) # currentsize
	    end loop
	  end Lookup
      
	  export operation Insert [k : ktype, v : etype]
	    count <- count + 1
	    if count > limit then self.enlarge end if
	    self.iInsert[k, v]
	  end Insert
      
	  export operation reset
	    for i : Integer <- 0 while i < currentsize by i <- i + 1
	      keys[i] <- nil
	    end for
	    count <- 0
	  end reset

	  export operation delete [k : ktype]
	    var h : Integer <- k.hash # currentsize
	    var key : ktype
	    var value : etype
	    loop
	      key <- keys[h]
	      if key == nil then
		return
	      elseif key = k then
		% found it, now remove it

		count <- count - 1
		keys[h] <- nil
		values[h] <- nil
		loop
		  % rehash until we reach nil again
		  h <- (h + 1) # currentsize
		  key <- keys[h]
		  if key == nil then
		    return
		  end if
		  value <- values[h]
		  keys[h] <- nil
		  values[h] <- nil
		  self.iInsert[key, value]
		end loop
		return
	      end if
	    end loop
	  end delete
	end anAssoc
      end create
    end anAssocCreator
  end of
end Assoc

