%
% @(#)ident.m	1.2  3/6/91
%
export Ident, LookupIdent, IdentTable

const Ident <- immutable class Ident [xxname : String, xxvalue : Integer]
  const field name : String <- xxname
  const field value : Integer <- xxvalue
  export function asString -> [r : String]
    r <- name
  end asString
end Ident

const LookupIdent <- typeobject LookupIdent
  operation Lookup [String, Integer] -> [Ident]
end LookupIdent

const IdentTable <- immutable object IdentTable
  export function getSignature -> [r : Signature]
    r <- LookupIdent
  end getSignature

  export operation create -> [r : LookupIdent]
    r <- object anIdentTable
	const voi <- Vector.of[Ident]
	const vos <- Vector.of[String]
	var currentsize : Integer <- 4327
	var values : voi <- voi.create[currentsize]
	var keys   : vos <- vos.create[currentsize]
	var count  : Integer <- 0
	var limit  : Integer <- (currentsize * 4) / 5

	operation iInsert [s : String, id : Ident]
	  const first <- s.hash # currentsize
	  var h : Integer <- first
	  loop
	    const k <- keys[h]
	    if k == nil then
	      keys[h] <- s
	      values[h] <- id
	      return
	    elseif s = k then
	      values[h] <- id
	      count <- count - 1
	      return
	    end if
	    h <- (h + 1) # currentsize
	    exit when h = first
	  end loop
	end iInsert
    
	operation enlarge
	  const oldvalues <- values
	  const oldkeys   <- keys
	  const oldsize   <- currentsize

	  currentsize <- currentsize * 2 + 1
	  limit <- (currentsize * 4) / 5
	  values <- voi.create[currentsize]
	  keys   <- vos.create[currentsize]
	  for i : Integer <- 0 while i < oldsize by i <- i + 1
	    const k <- oldkeys[i]
	    if k !== nil then
	      self.iInsert[k, oldvalues[i]]
	    end if
	  end for
	end enlarge
    
	export function Lookup [s : String, value : Integer] -> [id : Ident]
	  var h : Integer
	  if count > limit then self.enlarge end if
	  h <- s.hash # currentSize
	  loop
	    const k <- keys[h]
	    if k == nil then
	      id <- Ident.create[s, value]
	      keys[h] <- s
	      values[h] <- id
	      count <- count + 1
	      return
	    elseif k = s then
	      id <- values[h]
	      return
	    end if
	    h <- (h + 1) # currentsize
	  end loop
	end Lookup
    end anIdentTable
  end create
end IdentTable
