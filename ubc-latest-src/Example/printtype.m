const tat <- class tat
  export operation printType [s : OutStream, t : Signature]
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
