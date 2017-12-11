export bag

const foo <- class foo[pa : Integer, pb : String]
  field a : Integer <- pa
  field b : String <- pb
end foo

const bag <- immutable object bag
  export function of [etype : type] -> [r : BagCreatorType]
    forall etype
    where 
      BagType <- typeobject BagType
	operation add [etype]
	operation remove [etype]
	operation select -> [etype]
	function empty -> [Boolean]
	function contains [etype] -> [Boolean]
      end BagType
    where
      Es <- typeobject Es
	function lowerbound -> [Integer]
	function upperbound -> [Integer]
	function getElement[Integer] -> [etype]
      end Es
    where
      BagCreatorType <- immutable typeobject BagCreatorType
	operation create -> [BagType]
	operation literal[Es] -> [BagType]
	operation singleton [etype] -> [BagType]
	function getSignature -> [Signature]
      end BagCreatorType
    r <- immutable object aBagCreator
      const erec <- class erec
	field prev : erec
	field next : erec
	field value : etype
      end erec

      export function getSignature -> [r : Signature]
	r <- BagType
      end getSignature

      export operation literal[values : Es] -> [r : BagType]
	r <- self.create
	for i : Integer <- values.lowerbound while i <= values.upperbound by i <- i + 1
	  r.add[values[i]]
	end for
      end literal

      export operation singleton [v : etype] -> [r : BagType]
	r <- self.create
	r.add[v]
      end singleton

      export operation create -> [r : BagType]
	r <- object aBag
	  const head : erec <- erec.create
	  export operation add [v : etype]
	    const n : erec <- erec.create
	    n$next <- head
	    n$prev <- head$prev
	    head$prev$next <- n
	    head$prev <- n
	    n$value <- v
	  end add
	  export function contains [v : eType] -> [r : Boolean]
	    r <- false
	    for e : erec <- head$next while e !== head by e <- e$next
	      if e$value == v then r <- true return end if
	    end for
	  end contains
	  export operation remove [v : etype]
	    for e : erec <- head$next while e !== head by e <- e$next
	      if e$value == v then
		e$next$prev <- e$prev
		e$prev$next <- e$next
		return
	      end if
	    end for
	  end remove
	  export operation select -> [e : eType]
	    e <- head$next$value
	  end select
	  export function empty -> [r : Boolean]
	    r <- head$next == head
	  end empty
	  initially
	    head$next <- head
	    head$prev <- head
	  end initially
	end aBag
      end create
    end aBagCreator
  end of
end Bag

const bagtest <- object bagtest
  process
    const b <- bag.of[integer].create
    const c <- bag.of[String].create
    const d <- bag.of[foo].create
    for i : Integer <- 0 while i < 10 by i <- i + 1
      b.add[i]
      c.add[i.asString]
      d.add[foo.create[i, i.asString]]
    end for
    b.remove[6]
    c.remove["6"]
    b.add[3]
    b.remove[3]
    b.remove[9]
    b.remove[0]
    loop
      exit when b.empty
      const t <- b.select
      stdout.putint[t, 0]
      stdout.putchar['\n']
      b.remove[t]
    end loop
    loop
      exit when d.empty
      const t : foo <- d.select
      stdout.putint[t$a, 0]
      stdout.putchar[' ']
      stdout.putstring[t$b]
      stdout.putchar['\n']
      d.remove[t]
    end loop
  end process
end bagtest
