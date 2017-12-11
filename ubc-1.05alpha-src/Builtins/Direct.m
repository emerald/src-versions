% 
% %W%  %G%
%
export Directory to "Builtins"

const Directory <- immutable object Directory builtin 0x1020
  const DirectoryType <- typeobject DirectoryType builtin 0x1620
    operation insert [String, Any]
    function lookup [String] -> [Any]
    operation delete [ String ]
    function list -> [ImmutableVectorOfString]
  end DirectoryType

  export function getSignature -> [ r : Signature ]
    r <- DirectoryType
  end getSignature

  export operation create -> [r : DirectoryType]
    r <- monitor object aUnixDirectory builtin 0x1420
      var allocsize : Integer <- 4
      var size : Integer <- 0
      attached var names : VectorOfString <- VectorOfString.create[allocsize]
      attached var values : VectorOfAny <- VectorOfAny.create[allocsize]
      
      function find [n : String, insert : Boolean] -> [mid : Integer]
	var lwb, upb, i : Integer
	var found : Boolean <- false
	lwb <- 0
	upb <- size - 1

	loop
	  mid <- (lwb + upb) / 2
	  exit when lwb > upb
	  const aname <- names[mid]
	  if aname = n then
	    found <- true
	    exit
	  elseif aname < n then
	    lwb <- mid + 1
	  else
	    upb <- mid - 1
	  end if
	end loop
	if !found and insert then

	  % Think about growing the vectors
	  if size = allocsize then
	    if allocsize < 128 then
	      allocsize <- allocsize * 2
	    else
	      allocsize <- allocsize + 128
	    end if
	    const oldnames <- names
	    const oldvalues <- values
	    names <- VectorOfString.create[allocsize]
	    values <- VectorOfAny.create[allocsize]
	    i <- 0
	    loop
	      exit when i = size
	      names[i] <- oldnames[i]
	      values[i] <- oldvalues[i]
	      i <- i + 1
	    end loop
	  end if
	    
	  i <- size
	  loop
	    exit when i <= lwb
	    names[i] <- names[i - 1]
	    values[i] <- values[i - 1]
	    i <- i - 1
	  end loop
	  names[i] <- n
	  values[i] <- nil
	  mid <- i
	  size <- size + 1
	end if
      end find

      export operation insert [n : String, v : Any]
	const index <- self.find[n, true]
	assert names[index] = n
	values[index] <- v
      end insert

      export operation delete [n : String]
	var index : Integer <- self.find[n, false]
	if index < size and names[index] = n then
	  size <- size - 1
	  loop
	    exit when index >= size
	    names[index] <- names[index + 1]
	    values[index] <- values[index + 1]
	    index <- index + 1
	  end loop
	end if
      end delete

      export function lookup [n : String] -> [v : Any]
	const index <- self.find[n, false]
	if index < size and names[index] = n then
	  v <- values[index]
	end if
      end lookup

      export function list -> [n : ImmutableVectorOfString]
	n <- ImmutableVectorOfString.Literal[names, size]
      end list
    end aUnixDirectory
  end create
end Directory
