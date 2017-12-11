% 
% @(#)Buffer.m	1.2   3/6/91
%
export Buffer to "Builtins"
const Buffer == immutable object Buffer builtin 0x1017
  const BufferType == typeobject BufferType builtin 0x1617
    operation write
    operation addChar [Character]
    operation addString [String]
    operation Pad [Character, Integer]
  end BufferType

  export function getSignature -> [r : Signature]
    r <- BufferType
  end getSignature

  export operation create [myfd : Integer]-> [r : BufferType]
    r <- object aBuffer builtin 0x1417
      const BUFSIZE == 2048
      monitor
	var nextToFillIndex : Integer <- 0
	attached const buf == VectorOfChar.create[BUFSIZE]
	export operation write 
	  if nextToFillIndex > 0 then
	    primitive "SYS" "JWRITE" 3 [] <- [myfd, buf, nextToFillIndex]
	    nextToFillIndex <- 0
	  end if
	end write
	export operation addChar [c : Character]
	  buf[nextToFillIndex] <- c
	  nextToFillIndex <- nextToFillIndex + 1
	  if nextToFillIndex >= BUFSIZE or (myfd == 1 and c == '\n') then
	    primitive "SYS" "JWRITE" 3 [] <- [myfd, buf, nextToFillIndex]
	    nextToFillIndex <- 0
	  end if
	end addChar
	export operation addString [s : String]
	  var i : Integer <- 0
	  var limit : Integer <- s.length
	  var index : Integer <- nextToFillIndex
	  var c : Character
	  loop
	    exit when i >= limit
	    c <- s[i]
	    buf[index] <- c
	    index <- index + 1
	    i <- i + 1
	    if index >= BUFSIZE or (myfd == 1 and c = '\n') then
	      primitive "SYS" "JWRITE" 3 [] <- [myfd, buf, index]
	      index <- 0
	    end if
	  end loop
	  nextToFillIndex <- index
	end addString
	export operation Pad [c : Character, w : Integer]
	  var i : Integer <- 0
	  var limit : Integer <- w
	  var index : Integer <- nextToFillIndex
	  loop
	    exit when i >= limit
	    buf[index] <- c
	    index <- index + 1
	    i <- i + 1
	    if index >= BUFSIZE then
	      primitive "SYS" "JWRITE" 3 [] <- [myfd, buf, index]
	      index <- 0
	    end if
	  end loop
	  nextToFillIndex <- index
	end Pad
      end monitor
    end aBuffer
  end create
end Buffer
