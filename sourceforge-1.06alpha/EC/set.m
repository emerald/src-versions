const Set <- immutable object Set
  export operation of [ElementType : Type] -> [r : SetType]
    suchthat
      ElementType *> typeobject constraint 
	operation foobar [String] -> [Integer]
      end constraint
    where
      SetType <- typeobject SetType
	function  contains [ElementType] -> [Boolean]
	function  = [SetType] -> [Boolean]
	operation choose -> [ElementType]
      end SetType
    r <- object aSet
      var x : ElementType
      export function contains [e : ElementType] -> [r : Boolean]
	r <- x == e
      end contains
      
      export function = [arg : SetType] -> [r : Boolean]
	r <- arg.choose == x
      end =

      export operation choose -> [r : ElementType]
	r <- x
      end choose
    end aSet
  end of
end Set

const set1 <- Set.of[Integer]
const set2 <- Set.of[Character]

const tester <- object tester
  const aot <- Array.of[Signature].create[-8]
  var nextToPrint : Integer <- 0

  operation queue [t : Signature]
    for i : Integer <- aot.lowerbound while i <= aot.upperbound by i <- i + 1
      if aot[i] == t then return end if
    end for
    aot.addUpper[t]
  end queue

  operation printType [s : OutStream, t : Signature]
    loop
      exit when aot.empty
      const junk <- aot.removeupper
    end loop
    aot.addupper[t]
    nextToPrint <- 0
    loop
      exit when nextToPrint > aot.upperbound
      const thetype <- aot[nextToPrint]
      nextToPrint <- nextToPrint + 1
      self.xprintType[s, thetype]
    end loop
  end printType

  operation xprintType [s : OutStream, t : Signature]
    if t$isImmutable then s.putstring["immutable "] end if
    s.putstring["typeobject "]
    s.putstring[t$name]
    if t$isTypeVariable then s.putstring[" (type variable)"] end if
    s.putchar['\n']
    self.printops[s, t$ops]
    s.putstring["end "]
    s.putstring[t$name]
    s.putchar['\n']
  end xprintType
  operation printOps [s : OutStream, o : AOpVector]
    for i : Integer <- 0 while i <= o.upperbound by i <- i + 1
      s.putstring["  "]
      self.printop[s, o[i]]
    end for
  end printOps

  operation printOp[s : OutStream, o : AOpVectorE]
    var p : AParamList
    if o$isFunction then
      s.putstring["function "]
    else
      s.putString["operation "]
    end if
    s.putstring[o.getName]
    s.putchar[' ']
    p <- o$arguments
    if p !== nil then
      s.putchar['[']
      for i : Integer <- 0 while i <= p.upperbound by i <- i + 1
	const sig <- p[i]
	s.putstring[sig$name]
	self.queue[sig]
	if i < p.upperbound then s.putstring[", "] end if
      end for
      s.putchar[']']
    end if
    p <- o$results
    if p !== nil then
      s.putstring[" -> ["]
      for i : Integer <- 0 while i <= p.upperbound by i <- i + 1
	const sig <- p[i]
	s.putstring[sig$name]
	self.queue[sig]
	if i < p.upperbound then s.putstring[", "] end if
      end for
      s.putchar[']']
    end if
    s.putchar['\n']
  end printOp
  initially
    stdout.putstring["Set.of[Integer]\n"]
    self.printtype[stdout, typeof set1]
    stdout.putstring["Set.of[Character]\n"]
    self.printtype[stdout, typeof set2]
  end initially
end tester
