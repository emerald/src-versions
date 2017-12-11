const Printable <- typeobject Printable
  function  asString -> [String]
end Printable

const ftree <- immutable object ftree
  const x <- 1
  export function getString [t : Tree] -> [r : String]
    if t !== nil then
      r <- t.asString
    end if
  end getString
  export operation print[s : OutStream, indent : Integer, t : Tree]
    var child : Tree
    var limit : Integer <- t.upperbound
    const zero <- 0
    s.putstring[t.asString]
    s.putstring[" @"]
    s.putstring[t.getln.asString]
    s.putchar['\n']
    if nameof t = "anoblit" then
      const ob <- view t as hasST
      if ob$st !== nil then 
	for i : Integer <- 0 while i < indent + 2 by i <- i + 1
	  s.putchar[' ']
	end for
        ob$st.print[s, indent+2]
	s.putChar['\n']
      end if
    end if
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      for i : Integer <- 0 while i < indent + 2 by i <- i + 1
	s.putchar[' ']
      end for
      s.putint[ch, 2]
      s.putchar[':']
      s.putchar[' ']
      child <- t[ch]
      if child == nil then
	s.putstring["nil\n"]
      else
	child.print[s, indent+2]
      end if
    end for
  end print

  export operation removeSugar[t : Tree, ob : Tree] -> [r : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	t[ch] <- child.removeSugar[ob]
      end if
    end for
    r <- t
  end removeSugar

  export operation defineSymbols[thest : SymbolTable, t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.defineSymbols[thest]
      end if
    end for
  end defineSymbols

  export operation resolveSymbols[thest : SymbolTable, t : Tree, nexp : Integer]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.resolveSymbols[thest, nexp]
      end if
    end for
  end resolveSymbols

  export operation evaluateManifests[t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.evaluateManifests
      end if
    end for
  end evaluateManifests

  export operation findManifests[t : Tree] -> [changed : Boolean]
    var child : Tree
    const limit <- t.upperbound
%    const stdout <- (locate self).getStdout
%    stdout.putstring["Doing findmanifests on a "]
%    stdout.putString[t.asString]
%    stdout.putString["\n"]
    changed <- false
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
%	stdout.putstring["Doing findmanifests on child "]
%	stdout.putInt[ch, 0]
%	stdout.putString[" of "]
%	stdout.putString[t.asString]
%	stdout.putString["\n"]
	changed <- child.findManifests | changed
      end if
    end for
  end findManifests

  export operation typeCheck[t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.typeCheck
      end if
    end for
  end typeCheck

  export operation assignTypes[t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.assignTypes
      end if
    end for
  end assignTypes

  export operation findThingsToGenerate[q : Any, t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.findThingsToGenerate[q]
      end if
    end for
  end findThingsToGenerate

  export operation generate[ct : Printable, t : Tree]
    var child : Tree
    const limit <- t.upperbound
    for ch : Integer <- 0 while ch <= limit by ch <- ch + 1
      child <- t[ch]
      if child !== nil then
	child.generate[ct]
      end if
    end for
  end generate
  
end ftree

const tree <- class tree [xln : Integer]
  const field ln : Integer <- xln

  export function getIsSeq -> [r : Boolean]
    r <- false
  end getIsSeq

  export function lowerbound -> [r : Integer]
    r <- 0
  end lowerbound
  export function upperbound -> [r : Integer]
    r <- ~1
  end upperbound
  export function getElement [i : Integer] -> [r : Tree]
  end getElement
  export operation setElement [i : Integer, r : Tree]
  end setElement
  export operation rcons [a : Tree]
    assert false
  end rcons
  export operation rappend [a : Tree]
    assert false
  end rappend
  export function asString -> [r : String]
    r <- "a tree"
  end asString
  export operation print[s : OutStream, indent : Integer]
    ftree.print[s, indent, self]
  end print
  export operation copy [how : Integer] -> [r : Tree]
    % how = 0 -> delete symbols
    % how = 1 -> reset  symbols
    % how = 2 -> copy   symbols
    assert false
  end copy
  export operation removeSugar [ob : Tree] -> [r : Tree]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	self[ch] <- child.removeSugar[ob]
      end if
      ch <- ch + 1
    end loop
    r <- self
  end removeSugar

  export operation defineSymbols[thest : SymbolTable]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.defineSymbols[thest]
      end if
      ch <- ch + 1
    end loop
  end defineSymbols

  export operation resolveSymbols[thest : SymbolTable, nexp : Integer]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.resolveSymbols[thest, nexp]
      end if
      ch <- ch + 1
    end loop
  end resolveSymbols

  export operation getIsNotManifest -> [r : Boolean]
    r <- true
  end getIsNotManifest

  export operation setIsNotManifest [r : Boolean]
    assert false
  end setIsNotManifest

  export operation findManifests -> [changed : Boolean]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    changed <- false
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	changed <- child.findManifests | changed
      end if
      ch <- ch + 1
    end loop
  end findManifests

  export operation evaluateManifests
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.evaluateManifests
      end if
      ch <- ch + 1
    end loop
  end evaluateManifests

  export operation assignIds [thest : SymbolTable]
  end assignIds

  export operation doEnvExports[thest : SymbolTable]
  end doEnvExports

  export operation assignTypes
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.assignTypes
      end if
      ch <- ch + 1
    end loop
  end assignTypes

  export operation typeCheck
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.typeCheck
      end if
      ch <- ch + 1
    end loop
  end typeCheck

  export operation getAT -> [r : Tree]
  end getAT

  export operation getCT -> [r : Tree]
  end getCT

  export operation findThingsToGenerate[q : Any]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.findThingsToGenerate[q]
      end if
      ch <- ch + 1
    end loop
  end findThingsToGenerate

  export operation generate[ct : Printable]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child.generate[ct]
      end if
      ch <- ch + 1
    end loop
  end generate
  
  export operation execute -> [r : Tree]
    r <- nil
  end execute

  export function asType -> [r : Tree]
    r <- nil
  end asType

  export function same [o : Tree] -> [r : Boolean]
    r <- false
  end same
  
  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    var child : Tree
    const limit <- self.upperbound
    var ch : Integer <- 0
    outdecls <- indecls
    loop
      exit when ch > limit
      child <- self[ch]
      if child !== nil then
	child, outdecls <- child.flatten[ininvoke, outdecls]
	self[ch] <- child
      end if
      ch <- ch + 1
    end loop
    r <- self
  end flatten
end tree

const VoT <- Vector.of[Tree]

export FTree, Tree, VoT
export Printable
