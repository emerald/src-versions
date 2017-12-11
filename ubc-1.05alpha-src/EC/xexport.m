export Xexport
const prunable <- typeobject prunable
  operation prune
end prunable

const helper <- immutable object helper
  const ids : AOI <- AOI.create[-32]
  const ats : AOT <- AOT.create[-32]
  const marked <- ISet.create[32]

  export operation needAT [id : Integer, theAT : Tree]
    const env <- Environment$env
    const fn : String <- env$namespacefile
    if env$dotypecheck and theAT !== nil and id >= 0x2000 then
      ObjectTable.Define[id, theAT]
    end if
    if fn == nil then return end if

    if id < 0x2000 then
      % it is a builtin and we ignore it
    else
      const isNew <- ! marked.includes[id]
      if isNew then
	marked.add[id]
	ids.addupper[id]
	ats.addupper[theat]
      end if
    end if
  end needAT

  export operation flush
    const env : EnvironmentType <- Environment$env
    const fn : String <- env$namespacefile
    if fn == nil then return end if

    const f : OutStream <- OutStream.toUnix[fn || ".ats", "a"]
    if f == nil then
      env.SemanticError[1, "Can't open AT file \"%s\"",{fn || ".ats"}]
    else
      loop
	exit when ids.empty
	const theid : Integer <- ids.removeLower
	var theat : ATLit <- view ats.removeLower as ATLit
	f.putint[theid, 0]
	f.putchar[' ']
	if theat == nil then
	  theat <- view ObjectTable.Lookup[theid] as ATLit
	end if
	assert nameof theat = "anatlit"
	const atext : String <- theat.asText[self]
	if ! env$exporttree then
	  theat.prune
	end if
	f.putstring[atext]
	f.putchar['\n']
      end loop
      f.close
    end if
  end flush

  export operation Split [s:String] -> [w:String,x:String, y:String, z:String, aa : String, bb : String]
    var first, last : Integer
    var c : Character
    var t : String

    first <- 0
    last <- 0
    for which : Integer <- 0 while which < 6 by which <- which + 1
      loop
	exit when first >= s.length
	c <- s[first]
	exit when c != ' ' and c != '\^I' and c != '\n'
	first <- first + 1
      end loop
      if first >= s.length then return end if
      last <- first + 1
      loop
	exit when last >= s.length
	c <- s[last]
	exit when c = ' ' or c = '\^I' or c = '\n'
	last <- last + 1
      end loop
      t <- s[first, last - first]
      if which = 0 then
	w <- t
      elseif which = 1 then
	x <- t
      elseif which = 2 then
	y <- t
      elseif which = 3 then
	z <- t
      elseif which = 4 then
	aa <- t
      else
	bb <- t
      end if
      first <- last + 1
    end for
  end Split

  export operation fetchIDs[name:String] -> [id:Integer, atOID : Integer, codeOID:Integer, instCTOID:Integer, instATOID : Integer]
    const env <- Environment$env
    const rootst <- env$rootst
    const theid  <- env$ITable.Lookup[name, 999]
    var thesym : Symbol <- rootst.Lookup[0, theid, false]

    if thesym !== nil then
      const thevalue <- thesym$value
      const itsname <- nameof thevalue
      if itsname = "anoblit" or itsname = "aglobalref" then
	const obl <- view thevalue as hasIDs
	id <- obl$id
	atOID <- obl$atoid
	codeOID <- obl$codeOID
	instCTOID <- obl$instCTOID
	instATOID <- obl$instATOID
      elseif itsname = "anatlit" then
	const atl <- view thevalue as atlit
	id <- atl$id
	atoid <- 0x1609
      elseif itsname = "aliteral" then
        % do nothing, I suppose
      else
	Environment$env.pass["Fetchids: can't get the ids from %s (a %s)\n",
	  { name, itsname }]
      end if
    end if
  end fetchIDs

  export operation doOne[name : String, value : Tree, atype : Tree]
    const env : EnvironmentType <- Environment$env
    const rootst <- env$rootst
    const theid  <- env$ITable.Lookup[name, 999]
    var thesym : Symbol <- rootst.Lookup[0, theid, false]
    if thesym == nil then
      thesym <- rootst.Define[0, theid, SConst, false]
    end if
    assert thesym !== nil
    env.pass["Exporting \"%s\" a %s\n", {name, value.asString}]
    thesym$value <- value
    thesym$atinfo <- atype

    if env$dotypecheck then
      if value !== nil then
	const valuename <- nameof value
	if valuename = "anatlit" or valuename = "anoblit" or 
	   valuename = "aglobalref" then
	  const ashasid <- view value as hasID
	  const id : Integer <- ashasid$id
	  if id !== nil then
	    ObjectTable.Define[id, value]
	  end if
	end if
      end if
      if atype !== nil then
	const atypename <- nameof atype
	if atypename = "anatlit" or atypename = "anoblit" or 
	   atypename = "aglobalref" then
	  const ashasid <- view atype as hasID
	  const id : Integer <- ashasid$id
	  if id !== nil then
	    ObjectTable.Define[id, atype]
	  end if
	end if
      end if
    end if
  end doOne

  export operation doAnId [name : String, id : Integer, atOID : Integer, codeOID : Integer, instctoid : Integer, instATOID : Integer, atype : Tree]
    if id = -1 then
      self.doOne[name, Literal.IntegerL[0, codeOID.asString], 
	builtinlit.create[0, 0x06].getInstAT]
    elseif id = -2 then
      self.doOne[name, Literal.CharacterL[0, Character.literal[codeOID].asString], 
	builtinlit.create[0, 0x04].getInstAT]
    elseif id = -3 then
      self.doOne[name, Literal.BooleanL[0, codeOID = 1], 
	builtinlit.create[0, 0x03].getInstAT]
    else
      self.doOne[name, Globalref.create[0, id, atOID, codeOID, 
	instctoid, instATOID], atype]
    end if
  end doAnId
end helper

const xexport <- class Xexport (Tree) [xxsyms : Tree, xxpath : Tree]

  class export operation loadATs [pfn : String]
    const fn <- pfn || ".ats"
    var f : InStream
    begin
      f <- InStream.fromUnix[fn, "r"]
      failure f <- nil end failure
    end
    if f == nil then return end if 
    var input, first, second, third, fourth, fifth, sixth : String
    loop
      begin
	input <- f.getString
	failure
	  input <- nil
	end failure
      end
      exit when input == nil
      const separators <- " \n\r\t"
      first, input <- input.token[separators]
      if input !== nil then second, input <- input.token[separators] end if
      if first == nil or second == nil then
	Environment$env.printf["Syntax error in load file\n", nil]
	exit
      end if
      const id <- Integer.Literal[first]
      const theat <- ATLit.fromText[second]
      ObjectTable.Define[id, theat]
    end loop
    f.close
  end loadATs

  class export operation load[fn : String]
    var f : InStream
    const env <- Environment$env
    begin
      f <- InStream.fromUnix[fn, "r"]
      failure f <- nil end failure
    end
    if f == nil then
      env.pass["Can't read file \"%s\", creating a new environment\n", {fn}]
    else
      var input, first, second, third, fourth, fifth, sixth : String
      var id, atOID, codeOID, instctoid, instatoid : Integer
      loop
	begin
	  input <- f.getString
	  failure
	    input <- nil
	  end failure
	end
	exit when input == nil
	const separators <- " \n\r\t"
	first, input <- input.token[separators]
	if input !== nil then second, input <- input.token[separators] end if
	if first == nil or second == nil or 
	   (second[0] != '-' and ('0' > second[0] or second[0] > '9')) then
	  env.printf["Syntax error in load file\n", nil]
	  exit
	end if
	id <- Integer.Literal[second]
	if input == nil then
	  atOID <- nil
	else
	  third, input <- input.token[separators]
	  if third !== nil then atOID <- Integer.Literal[third] end if
	end if
	if input == nil then
	  codeOID <- nil
	else
	  fourth, input <- input.token[separators]
	  if fourth !== nil then codeOID <- Integer.Literal[fourth] end if
	end if
	if input == nil then
	  instctoid <- nil
	else
	  fifth, input <- input.token[separators]
	  if fifth !== nil then instctoid <- Integer.Literal[fifth] end if
	end if
	if input == nil then
	  instatoid <- nil
	else
	  sixth, input <- input.token[separators]
	  if sixth !== nil then instatoid <- Integer.Literal[sixth] end if
	end if
	helper.doAnID[first, id, atOID, codeOID, instctoid, instatoid, nil]
      end loop
      f.close
    end if
    XExport.loadATs[fn]
  end load

    field syms : Tree <- xxsyms
    field path : Tree <- xxpath

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- syms
      elseif i = 1 then
	r <- path
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	syms <- r
      elseif i = 1 then
	path <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsyms, npath : Tree
      if syms !== nil then nsyms <- syms.copy[i] end if
      if path !== nil then npath <- path.copy[i] end if
      r <- xexport.create[ln, nsyms, npath]
    end copy
    export operation doEnvExports [st : SymbolTable]
      for i : Integer <- 0 while i <= syms.upperbound by i <- i + 1
	const sy <- view syms[i] as Sym
	if sy !== nil then
	  const sid <- sy$id
	  const name : String <- sid$name
	  const val <- view sy$mysym$value as Tree
	  const env : EnvironmentType <- Environment$env
	  const fn : String <- env$namespacefile

	  if val == nil then
	    env.pass["Symbol \"%s\" doesn't have a value yet\n", { name }]
	    env.SemanticError[ln, "Symbol \"%s\" doesn't have a value", {name}]
%	  elseif path !== nil then
%	    % export to the builtin place
%	    if env$exportTree then helper.doOne[name, val, nil] end if
	  else
	    const itsname <- nameof val
	    var id, atOID, codeOID, instctoid, instatoid : Integer 

	    if itsname = "anoblit" then
	      const myob <- view val as OBLit

	      if myob$isNotManifest then
		assert myob$isExported
		const badthing : String <- myob.areMyImportsManifestOrExported
		if badthing !== nil then
		  % This object imports something bad
		  env.SemanticError[sy$ln,
		    "Can't export \"%s\" as it imports \"%s\" which is not manifest",
		    { (view myob$name as Sym)$mysym$myident$name, badthing }]
		end if
	      end if
	      myob.makeMeManifest

	      id <- myob$id
	      const theat <- myob.getat
	      const theinstat <- myob.getinstat
	      if theat !== nil then
		atOID <- (view theat as hasID)$id
		helper.needAT[atOID, theat]
		if !env$exporttree then (view theat as prunable).prune end if
	      end if
	      if theinstat !== nil then
		instatOID <- (view theinstat as hasID)$id
		helper.needAT[instatOID, theinstat]
		if !env$exporttree then (view theinstat as prunable).prune end if
	      end if
	      codeOID <- myob$codeOID
	      const instct <- view myob$instct as ObLit
	      if instct !== nil then
		instctoid <- myob$instctoid
		if !env$exporttree then instct.prune end if
	      end if
	      if ! env$exporttree then myob.prune end if
	    elseif itsname = "aglobalref" then
	      const myob <- view val as hasIds
	      id <- myob$id
	      atOID <- myob$atOID
	      codeOID <- myob$codeOID
	      instctoid <- myob$instctoid
	      instatoid <- myob$instatoid
	    elseif itsname = "anatlit" then
	      const myat <- view val as atlit
	      myat.makeMeManifest
	      id <- myat$id
	      atOID <- 0x1609
	      helper.needAT[id, myat]
	      if ! env$exporttree then myat.prune end if
	    elseif itsname = "aliteral" then
	      const asLiteral <- (view val as Literal)
	      const index <- asLiteral$index
	      if index = IntegerIndex then
		id <- -1
		codeOID <- Integer.literal[asLiteral$str]
		atOID <- 0x1606
	      elseif index = CharacterIndex then
		id <- -2
		codeOID <- asLiteral$str[0].ord
		atOID <- 0x1604
	      elseif index = BooleanIndex then
		id <- -3
		if asLiteral$str = "true" then
		  codeOID <- 1
		else 
		  codeOID <- 0
		end if
		atOID <- 0x1603
	      else
		env.SemanticError[sy$ln, "Can't export such values", nil]
	      end if
	    else
	      env.SemanticError[sy$ln, "Can't export such values", nil]
	    end if
	    if env$exportTree or id == nil then
	      helper.doOne[name, val, view sy$mysym$atinfo as Tree]
	    elseif env$dotypecheck then
%	      if itsname = "anatlit" then
		helper.doOne[name, val, view sy$mysym$atinfo as Tree]
%	      else
%		helper.doAnId[name, id, atOID, codeOID, instctoid, instatoid, sy$mysym$atinfo]
%	      end if
	    else
	      helper.doAnId[name, id, atOID, codeOID, instctoid, instatoid, nil]
	    end if
	    if id !== nil and fn !== nil then
	      const f <- OutStream.toUnix[fn, "a"]
	      if f == nil then
		env.SemanticError[1, "Can't open name list file \"%s\"",{fn}]
	      else
		% chmod fn 0666
		f.putstring[name]
		f.putchar[' ']
		f.putint[id, 0]
		f.putchar[' ']
		f.putint[atOID, 0]
		if codeOID !== nil then
		  f.putchar[' ']
		  f.putint[codeOID, 0]
		  if instctOID !== nil then
		    f.putchar[' ']
		    f.putint[instctOID, 0]
		    if instatOID !== nil then
		      f.putchar[' ']
		      f.putint[instatOID, 0]
		    end if
		  end if
		end if
		f.putchar['\n']
		f.close
	      end if
	    end if
	  end if
	end if
      end for
      helper.flush
    end doEnvExports

    export operation assignIDs [st : SymbolTable]
      for i : Integer <- 0 while i <= syms.upperbound by i <- i + 1
	const sy <- view syms[i] as Sym
	if sy !== nil then
	  const sid <- sy$id
	  const name : String <- sid$name
	  const val <- view sy$mysym$value as Tree
	  const env    <- Environment$env
	  const fn : String <- env$namespacefile

	  if val == nil then
	    env.pass["Symbol \"%s\" doesn't have a value yet\n", { name }]
	  elseif path !== nil then
	    % do nothing, the builtins already know their IDs
	  else
	    var id, atoid, codeOID, instctoid, instatoid : Integer
	    const valname : String <- nameof val
	    id, atoid, codeOID, instctoid, instatoid <- helper.fetchIDs[name]
	    if valname = "anoblit" then
	      const myob <- view val as oblit

	      if myob$isNotManifest then
		myob$isExported <- true
	      end if

	      if id !== nil then
		myob$id <- id
		if atOID !== nil then myob$atoid <- atoid end if
		if codeOID !== nil then myob$codeOID <- codeOID end if
		if instCTOID !== nil then myob$instCTOID <- instCTOID end if
		if instATOID !== nil then myob$instATOID <- instATOID end if
		if ! env$exporttree and !env$dotypecheck then
		  syms[i] <- nil
		end if
	      else
		myob.makeMeManifest
	      end if
	    elseif valname = "anatlit" then
	      const myat <- view val as ATlit
	      if id !== nil then
		myat$id <- id 
		if ! (env$exporttree or env$dotypecheck) then
		  syms[i] <- nil 
		end if
	      end if
	    elseif valname = "aglobalref" then
	      % do nothing
	    elseif valname = "aliteral" then
	      % also do nothing, these things don't need ids
	    else
	      env.pass[
		"Can't figure out how to assign ID to \"%s\", a \"%s\"\n",
		{ name, val.asString : String }]
	    end if
	  end if
	end if
      end for
    end assignIDs


  export operation generate [ct : Printable]
  end generate

  export function asString -> [r : String]
    r <- "xexport"
  end asString
end Xexport
