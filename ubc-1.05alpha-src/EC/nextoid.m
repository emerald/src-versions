const nextOID <- immutable object nextOID
  const howmanyatonce <- 100
  const myint <- object myint
    field next : Integer <- 0
    field limit : Integer <- ~1
    field filename : String <- nil
  end myint

  function baseStart -> [r : Integer]
    if Environment$env$compilingbuiltins then
      r <- 0x4000
    elseif Environment$env$compilingcompiler then
      r <- 0xc0000
    else
      r <- 0x100000
    end if
  end baseStart

  operation nextOIDBlock -> [r : Integer]
    if myint$filename == nil then
      r <- myint$next
      if r < self.basestart then
	r <- self.basestart
      end if
    else
      var inf : InStream
      var outf : OutStream
      var s : String
      var root : String
      var start : Integer
      
      begin
	inf <- InStream.fromUnix[myint$filename, "r"]
	failure inf <- nil end failure
      end
      if inf == nil then
	start <- self.basestart
      else
	s <- inf.getString
	start <- Integer.literal[s]
	if start < self.basestart then
	  start <- self.basestart
	end if
	inf.close
      end if
      r <- start
      outf <- OutStream.toUnix[myint$filename, "w"]
      if outf == nil then
	const env : EnvironmentType <- Environment$env
	env.SemanticError[1, "Can't open oid file \"%s\"", {myint$filename}]
      else
	outf.putint[start + howmanyatonce, 0]
	outf.putchar['\n']
	outf.close
      end if
    end if
    if !Environment$env$compilingBuiltins then
      ObjectTable.okForNextOID[r]
    end if
  end nextOIDBlock

  export operation nextOID -> [r : Integer]
    if myint$next >= myint$limit then
      myint$next <- self.nextOIDBlock[]
      myint$limit <- myint$next + howmanyatonce
    end if
    r <- myint$next
    myint$next <- myint$next + 1
  end nextOID

  export operation load[fn : String]
    self.reset
    myint$filename <- fn || ".oid"
  end load

  export operation reset
    myint$next <- 0
    myint$limit <- ~1
    myint$filename <- nil
  end reset
end nextOID

export nextOID
