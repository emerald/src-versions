const size <- 32
const BBuffer <- class BBuffer
  const buf <- Vector.of[Integer].create[size]
  var front : Integer <- 0
  var back : Integer <- 0
  var elements : Integer <- 0

  export operation get -> [r : Integer]
    r <- buf[back]
    back <- (back + 1) # size
    elements <- elements - 1
    (locate self)$stdout.putstring[">> "|| elements.asString || "\n"]
  end get

  export operation put [r : Integer]
    buf[front] <- r
    front <- (front + 1) # size
    elements <- elements + 1
    (locate self)$stdout.putstring["<< "|| elements.asString || "\n"]
  end put

  process
    loop
      if elements = 0 then
	accept typeobject t op put[Integer] end t
      elseif elements == size then
	accept typeobject t op get->[Integer] end t
      else
	accept typeobject t op put[Integer] op get -> [Integer] end t
      end if
    end loop
  end process
end BBuffer

const ran <- object ran
  export operation dom -> [r : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [r] <- []
  end dom
  initially
    const usec <- (locate self)$timeOfDay$microseconds
    primitive "NCCALL" "RAND" "SRANDOM" [] <- [usec]
  end initially
end ran

const driver <- object driver
  const b <- BBuffer.create
  process
    for i : Integer <- 0 while i < size/2 by i <- i + 1
      b.put[ran.dom # 100]
    end for
    for i : Integer <- 0 while i < 100 by i <- i + 1
      const j1 <- object foo
	process
	  loop
	    (locate self).Delay[Time.create[0, ran.dom # 100000]]
	    if ran.dom # 2 = 1 then
	      const trash <- b.get
	    else
	      b.put[ran.dom # 100]
	    end if
	  end loop
	end process
      end foo
    end for
  end process
end driver
