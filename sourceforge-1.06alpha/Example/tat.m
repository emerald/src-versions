const tat <- class tat[stdout : OutStream]
  initially
    const foo <- typeobject xx
      op y [Integer, Integer] -> [Real]
      op z [Real]
    end xx
    const foo1 <- typeobject xx1
      op y [Integer, Integer] -> [Real]
      op z [Integer]
    end xx1
    const fout <- formattedoutput.toStream[stdout]

    self.printType[stdout, foo]
   
    fout.printf["typeof 5 %s Integer\n", {{"*/>", "*>"}[((typeof 5) *> Integer).ord]}]
    fout.printf["typeof 5 %s foo\n", {{"*/>", "*>"}[((typeof 5) *> foo).ord]}]
    if foo *> foo1 then
      stdout.putstring["foo *> foo1\n"]
    else
      stdout.putstring["foo */> foo1\n"]
    end if
  end initially

  operation printType [s : OutStream, t : Signature]
    if t$isImmutable then s.putstring["immutable "] end if
    s.putstring["typeobject "]
    s.putstring[t$name]
    s.putchar['\n']
    self.printops[s, t$ops]
    s.putstring["end "]
    s.putstring[t$name]
    s.putchar['\n']
  end printType
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
	if i < p.upperbound then s.putstring[", "] end if
      end for
      s.putchar[']']
    end if
    s.putchar['\n']
  end printOp
end tat
export tat
