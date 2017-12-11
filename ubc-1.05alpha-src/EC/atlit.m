
export Atlit

const hasNeedAT <- typeobject hasNeedAT
  operation needAT[Integer, Tree]
end hasNeedAT

const atlit <- class Atlit (OTree) [xxsfname : Tree, xxname : Tree, xxops : Tree]
  class export operation build[v : Signature] -> [r : ATLit]
    const it <- Environment.getEnv.getITable
    const name <- sym.create[0, it.Lookup[v$name, 999]]
    var id_seq : Integer
    var ops : Seq <- Seq.create[0]
    
    for i : Integer <- 0 while i <= v$ops.upperbound by i <- i + 1
      const theop <- v$ops[i]
      var params, results, sig : Tree
      
      params <- seq.create[0]
      results <- seq.create[0]
      sig <- nil
      ops.rcons[sig]
    end for
    r <- ATLit.create[0, Literal.StringL[0, "No source file"], name, nil]
    r$isImmutable <- v$flags.getbit[30]
    primitive "GETIDSEQ" [id_seq] <- [v]
    r$id <- id_seq
    r$alreadyGenerated <- true
  end build
  class operation scan[s : String, si : Integer, delim1 : Character, delim2 : Character]
    -> [r : String, ni : Integer]
    const limit <- s.upperbound
    var c : Character

    ni <- si
    loop
      exit when ni > limit
      c <- s[ni]
      exit when c = delim1 or c = delim2
      ni <- ni + 1
    end loop
    r <- s[si, ni - si]
  end scan

  class operation getlist [s : String, psi : Integer] -> [r : Tree, ni : Integer]
    var si : Integer <- psi
    var n : String
    var c : Character
    c <- s[si] si <- si + 1
    assert c = '['
    if s[si] != ']' then
      const theseq <- seq.create[0]
      loop
	exit when s[si] == ']'
	n, ni <- atlit.scan[s, si, ',', ']']
	const thetype <- globalref.create[0, Integer.Literal[n], 0x1609, nil, nil, nil]
	theseq.rcons[thetype]
	if s[ni] = ',' then
	  si <- ni + 1
	else
	  si <- ni
	end if
      end loop
      r <- theseq
    end if
    c <- s[si] si <- si + 1
    assert c = ']'
    ni <- si
  end getlist

  class export operation fromText [s : String] -> [r : Tree]
    const realr <- atlit.create[0, Literal.StringL[0, "unknown"], nil, nil]
    var index : Integer <- 0
    var limit : Integer <- s.upperbound
    var term  : Integer
    var c : Character
    var name : String

    c <- s[index] index <- index + 1
    realr$isImmutable <- c = 'T'
    realr$typesAreAssigned <- true
    realr$typesHaveBeenChecked <- true
    realr$alreadyGenerated <- true
    realr$isNotManifest <- false
    realr$isPruned <- true

    c <- s[index] index <- index + 1
    assert c = ':'
    name, index <- atlit.scan[s, index, ':', ':']
    realr$name <- Sym.literal[name]

    c <- s[index] index <- index + 1
    assert c = ':'
    name, index <- atlit.scan[s, index, '{', '{']
    realr$id <- Integer.Literal[name]

    if index <= limit then
      const ops <- seq.create[0]
      c <- s[index] index <- index + 1
      assert c = '{'
      c <- s[index] index <- index + 1
      loop
	exit when c = '}'
	const isfunction <- c = 'f'
	var theseq : Tree
	c <- s[index] index <- index + 1
	assert c = ':'
	name, index <- atlit.scan[s, index, '[', '[']
	const theop <- opsig.create[0, OpName.literal[name], nil, nil, nil]
	theseq, index <- atlit.getlist[s, index]
	theop$params <- theseq
	c <- s[index] index <- index + 1
	assert c = '-'
	c <- s[index] index <- index + 1
	assert c = '>'
	theseq, index <- atlit.getlist[s, index]
	theop$results <- theseq
	c <- s[index] index <- index + 1
	
	ops.rcons[theop]
      end loop
      realr$ops <- ops
    end if
    r <- realr
  end fromText

    field codeOID : Integer
    field id : Integer
    var instct : Tree
    field sfname : Tree <- xxsfname
    field xsetq : Tree
    field name : Tree <- xxname
    field ops : Tree <- xxops
    field st  : SymbolTable

    export operation setBuiltinID [t : Tree]
      const ts <- view t as hasStr
      const thestr <- ts.getStr
      id <- Integer.Literal[thestr]
      ObjectTable.Define[id, self]
      if id = 0x160c or
	 id = 0x1612 or
	 id = 0x1616 or
	 id = 0x160b or
	 id = 0x160f or
	 id = 0x1613 or
	 id = 0x1619 or
	 id = 0x161b or
	 id = 0x161d or
	 id = 0x161e or
	 id = 0x1621 or
	 id = 0x1623 or
	 id = 0x1627 then
	f <- f.setBit[xisVector, true]
      end if
    end setBuiltinID

    export function upperbound -> [r : Integer]
      r <- 3
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- sfname
      elseif i = 1 then
	r <- xsetq
      elseif i = 2 then
	r <- name
      elseif i = 3 then
	r <- ops
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	sfname <- r
      elseif i = 1 then
	xsetq <- r
      elseif i = 2 then
	name <- r
      elseif i = 3 then
	ops <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : AtLit]
      var nsfname, nname, nops : Tree
      if sfname !== nil then nsfname <- sfname.copy[i] end if
      if name !== nil then nname <- name.copy[i] end if
      if ops !== nil then nops <- ops.copy[i] end if
      r <- atlit.create[ln, nsfname, nname, nops]
      r$isVector <- self$isVector
      r$isImmutable <- self$isImmutable
    end copy

    export operation doAllocation
      var a, b, c : Integer
      a, b, c <- st.Allocate[0, 0, 0, nil]
    end doAllocation

    export operation findOp [itsname : Ident, nargs : Integer, nress : Integer] -> [r : OpSig, index : Integer]
      const ystring : String <- itsname$name

      if ops !== nil then
	for i : Integer <- 0 while i <= ops.upperbound by i <- i + 1
	  const xsig <- view ops[i] as OpSig
	  const xname <- xsig$name
	  const xstring : String <- xname$name
	  var xnargs : Integer
	  if xsig$params == nil then
	    xnargs <- 0
	  else
	    xnargs <- xsig$params.upperbound + 1
	  end if
	  if xstring = ystring and (nargs == nil or xnargs = nargs) then
	    r <- xsig
	    index <- i
	    return
	  end if
	end for
      end if
    end findOp

    export operation setInstCT [a : Tree]
      instct <- a
      self$knowinstct <- a !== nil
    end setInstCT

    export operation getInstCT -> [r : Tree]
      if self$knowInstCT then
	r <- instct
      else
	if id == nil or IDS.IDToSize[id] = 8 then return end if
	const me <- BuiltinLit.findTree[id, self]
	if nameof me = "anoblit" then
	  const foo <- view me as hasInstCT
	  instCT <- foo.getInstCT
	else
	  const itsid : Integer <- IDS.IDToInstCTID[id]
	  if itsid !== nil then
	    instCT <- globalref.create[ln, nil, nil, itsid, nil, nil]
	  end if
	end if
	self$knowInstCT <- true
	r <- instCT
      end if
    end getInstCT

    export function getinstCTOID -> [r : Integer]
      const x <- self$instCT
      if x !== nil and nameof x = "anoblit" then
	const y <- view x as hasIDs
	r <- y$codeOID
      end if
    end getinstCTOID

    export function getAT -> [r : Tree]
      r <- (view BuiltinLit.findTree[0x1009, nil] as hasInstAT).getInstAT
    end getAT

  export operation buildSetq [s : Symbol] -> [r : Symbol]
    r <- setq.build[s, self]
  end buildSetq

  export operation defineSymbols[pst : SymbolTable]
    const nst <- SymbolTable.create[pst, CATLit]
    const s <- nst.Define[ln, (view self$name as hasIdent)$id, SConst, false]
    nst$mytree <- self
    s$isSelf <- true
    s$value  <- self
    self$st <- nst
    for i : Integer <- 0 while i <= ops.upperbound by i <- i + 1
      const isig <- view ops[i] as OpSig
      const opisname : String <- isig$name$name
      const opisnargs : Integer <- isig$nargs
      const opisnress : Integer <- isig$nress
      for j : Integer <- i + 1 while j <= ops.upperbound by j <- j + 1
	const jsig <- view ops[j] as OpSig
	const opjsname : String <- jsig$name$name
	const opjsnargs : Integer <- jsig$nargs
	const opjsnress : Integer <- jsig$nress
	% TODO:  This should also check number of results when we properly
	% overload on them
	%
	% i.e. and opisnress = opjsnress
	if opisname = opjsname and opisnargs = opjsnargs then
	  Environment$env.SemanticError[jsig$ln, "Operation %s is multiply defined", { opisname }]
	end if
      end for
    end for
    FTree.defineSymbols[nst, self]
  end defineSymbols

  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    FTree.resolveSymbols[self$st, self, 0]
  end resolveSymbols

  export operation assignTypes
    if ! self$typesAreAssigned then
      self$typesAreAssigned <- true
      %
      % Go through the imports, and set dependsOnTypeVariable for all of us
      FTree.assignTypes[self]
    end if
  end assignTypes

  export operation findThingsToGenerate[q : Any]
    if ! self$isNotManifest and !self$queuedForGeneration then
      const qt <- view q as aot
      qt.addUpper[self]
      if self$id == nil then
	self$id <- nextOID.nextOID
      end if
      self$queuedForGeneration <- true
      FTree.findThingsToGenerate[q, self]
    end if
  end findThingsToGenerate

  export operation findManifests -> [changed : Boolean]
    changed <- false
    if self$isNotManifest then
      % I'm already decided
    else
      if self$xsetq !== nil then
	for i : Integer <- 0 while i <= self$xsetq.upperbound by i <- i + 1
	  begin
	    const t <- self$xsetq[i]
	    const s <- view t as Setq
	    if s$isNotManifest then
	      self$isNotManifest <- true
	      self$name$isNotManifest <- true
	      changed <- true
	      exit
	    end if
	  end
	end for
      end if
    end if
    changed <- FTree.findManifests[self] | changed
  end findManifests

  export operation execute -> [r : Tree]
    if !self$isNotManifest then
      self.makeMeManifest
      r <- self
    end if
  end execute

  export operation makeMeManifest
    if self$id == nil then
      self$id <- nextOID.nextOID
      if Environment$env$dotypecheck then
	ObjectTable.Define[self$id, self]
      end if
    end if
  end makeMeManifest

  export operation evaluateManifests
    if self$isNotManifest then
      % Do nothing because I'm not manifest
    elseif id == nil then
      % I am in fact manifest, and need to be given an ID
      % We check whether id == nil to prevent redoing manifests on things
      % that have already been done and pruned!
      const t <- view self$name as Sym
      if t$mysym$value == nil then
	t$mysym$value <- self
      end if
      self.makeMeManifest
    end if
    FTree.evaluateManifests[self]
  end evaluateManifests

  export operation generate [ct : Printable]
    const sfnameashasStr <- view self$sfname as hasStr
    const nameashasId <- view self$name as hasIdent
    if nameof ct = "anatcode" then
      const ctasat <- view ct as ATCode
      ctasat$filename <- sfnameashasStr.getStr
      ctasat$name <- nameashasId$id$name
      ctasat$isImmutable <- self$isImmutable
      ctasat$isTypeVariable <- self$isTypeVariable
      ctasat$isVector <- self$isVector
      ctasat$id <- self$id
      if self$ops !== nil then self$ops.generate[ct] end if
    else
      const bc <- view ct as ByteCode
      % We need to treat this as an expression, and return ourself
      bc.fetchLiteral[self$id]
      bc.finishExpr[4, 0x1809, 0x1609]
    end if
  end generate

  export function variableSize -> [r : Integer]
    if self$isVector then
%      Environment$env.pass["AT.elementsize (%s) == 4 because isvector\n",
%	{self$name.asString}]
      r <- 4
    else
      r <- IDS.IDToSize[self$id]
%      Environment$env.pass["AT.elementsize (%s %#x) = %d by ids\n",
%        {self$name.asString, self$id, r}]
    end if
  end variableSize

  export function getBrand -> [r : Character]
    if self$isVector then
      r <- 'x'
    else
      r <- IDS.IDToBrand[self$id]
    end if
  end getBrand

  export function asType -> [r : Tree]
    if ! self$isNotManifest then
      r <- self
    end if
  end asType

  export operation conformsTo [theln : Integer, other : Tree] -> [r : Boolean]
    const conformtable <- Environment$env$conformtable
    const otherashasid <- view other as hasid
    const otherid : Integer <- otherashasid$id
    r <- conformtable.Lookup[self$id, otherid]
    if r == nil then
      if nameof other = "anatlit" then
	const otherat <- view other as atlit
	r <- Conformer.Conforms[theln, self, otherat]
      else
	if Environment$env$tracetypecheck then
	  Environment$env.printf["Conforms: other is an %s on line %d\n",
	    { other.asString, theln}]
	end if
	r <- IDS.ConformsById[theln, self$id, otherid]
      end if
      conformtable.Insert[self$id, otherid, r]
    end if
  end conformsTo

  export operation print [s : OutStream, indent : Integer]
    s.putstring["atlit @"]
    s.putint[ln, 0]
    s.putchar[' ']
    if self$id !== nil then
      s.putstring["id = "]
      s.putstring[self$id.asString]
      s.putchar[' ']
    end if
    self.printFlags[s]
    FTree.print[s, indent, self]
  end print

  export function asString -> [r : String]
    r <- "atlit " || (view name as hasid)$id.asString
  end asString

  operation addList [rep : AoC, list : Tree, result : Boolean, who : hasNeedAT]
    if result then
      rep.addupper['-'] rep.addupper['>']
    end if
    rep.addupper['[']
    if list !== nil then
      for i : Integer <- 0 while i <= list.upperbound by i <- i + 1
	const p <- list[i]
	const stype <- p.asType
	const ttype <- view stype as hasID
	const typeid : Integer <- ttype$id
	const idstr : String <- typeid.asString

	if nameof stype = "anatlit" then
	  who.needAT[typeid, stype]
	end if
	if i > 0 then rep.addupper[','] end if
	for j : Integer <- 0 while j <= idstr.upperbound by j <- j + 1
	  rep.addupper[idstr[j]]
	end for
      end for
    end if
    rep.addupper[']']
  end addList

  % The asText operation is invoked after an AT has been generated and when
  % it is going to be placed in the global symbol table.  It is only needed
  % for type checking.

  export operation asText[who : hasNeedAT] -> [r : String]
    const rep : AoC <- AoC.create[-256]

    if self$isImmutable then
      rep.addupper['T']
    else
      rep.addupper['t']
    end if
    rep.addupper[':']
    const namesym <- view name as Sym
    const namestring : String <- namesym$id$name

    for j : Integer <- 0 while j <= namestring.upperbound by j <- j + 1
      rep.addupper[namestring[j]]
    end for

    rep.addupper[':']
    const idstring <- id.asString
    for j : Integer <- 0 while j <= idstring.upperbound by j <- j + 1
      rep.addupper[idstring[j]]
    end for

    if ops !== nil and ops.upperbound >= 0 then
      rep.addupper['{']
      for i : Integer <- 0 while i <= ops.upperbound by i <- i + 1
	const xsig <- view ops[i] as OpSig
	const xname <- xsig$name
	const xstring : String <- xname$name
	if xsig$isFunction then
	  rep.addupper['f']
	else
	  rep.addupper['o']
	end if
	rep.addupper[':']

	for j : Integer <- 0 while j <= xstring.upperbound by j <- j + 1
	  rep.addupper[xstring[j]]
	end for

	self.addlist[rep, xsig$params, false, who]
	self.addlist[rep, xsig$results, true, who]
      end for
      rep.addupper['}']
    end if
    r <- String.Literal[rep, 0, rep.upperbound + 1]
  end asText

  % The prune operation is invoked after an AT has been generated and when
  % it is going to be placed in the global symbol table.  It is only needed
  % for type checking, so we remove from the tree everything that we can
  % safely remove.

  operation pruneList[list : Tree]
    if list !== nil then
      for i : Integer <- 0 while i <= list.upperbound by i <- i + 1
	const p <- list[i]
	const stype <- p.asType
	const ttype <- view stype as hasID
	const typeid : Integer <- ttype$id

	list[i] <- globalref.create[p$ln, typeid, 0x1609, nil, nil, nil]
      end for
    end if
  end pruneList

  export operation prune
    if self$isPruned then return end if
    self$isPruned <- true

    const namesym <- view name as Sym
    namesym.prune
    xsetq <- nil

    if ops !== nil and ops.upperbound >= 0 then
      for i : Integer <- 0 while i <= ops.upperbound by i <- i + 1
	const xsig <- view ops[i] as OpSig
	self.prunelist[xsig$params]
	self.prunelist[xsig$results]
      end for
    end if
  end prune

end Atlit

export Conformer

const Conformer <- immutable object Conformer
  const voi <- Vector.of[Integer]
  export operation Conforms[ln : Integer, A : Any, B : Any]
			-> [answer : Boolean]
    %
    % Part of me worries about having to remove entries from the cache when
    % one returns from this operation.  I'm going to do it, although I don't
    % understand whether I really should.
    %
    const cache <- object cache
      const red <- aabtable.create[20]
      const indigo <- aatable.create[20]

      export operation assume [A : Atlit, B : Atlit]
	const env <- Environment$env
	const ttc <- env$tracetypecheck
	red.insert[A, B]
	if ttc then env.printf["Assuming %S -> %S in red\n", { A, B}] end if
	if B$isTypeVariable and indigo.Lookup[B] == nil then
	  indigo.Insert[B, A]
	  red.insert[B, A]
	  if ttc then env.printf["Assuming %S -> %S in red (and indigo)\n", { B, A}] end if
	end if
      end assume

      export operation forget [A : Atlit, B : Atlit]
	red.Forget[A, B]
	if indigo.Lookup[B] !== nil then
	  indigo.Forget[B]
	  red.Forget[B, A]
	end if
      end forget

      function getString[A : Tree] -> [r : String]
	if A == nil then
	  r <- "NIL"
	elseif nameof A = "anatlit" then
	  r <- (view (view A as ATLit)$name as hasIdent)$id$name
	else
	  r <- "Type with id " || (view A as hasIds)$id.asString
	end if
      end getString

      operation Pad [pdepth : Integer, out : OutStream]
	var depth : Integer <- pdepth
	loop
	  exit when depth <= 0
	  out.putchar[' ']
	  out.putchar[' ']
	  depth <- depth - 1
	end loop
      end Pad

      operation reportWhy [depth : Integer, reason : String, args : RISA,
	A : Tree, B : Tree]
	const env <- Environment$env
	const why <- env$why
	if why then
	  const out <- env$stdout
	  self.pad[depth, out]
	  env.printf[reason, args]
	  out.putchar['\n']
	  self.pad[depth, out]
	  env.printf["Type %s doesn't conform to type %s\n",
	    { self.getString[A], self.getString[B] }]
	end if
      end reportWhy

      export operation Conforms[ln : Integer, A : ATLit, B : ATLit, depth : Integer] -> [answer : Boolean]
	var aa, ba : Tree
	var ta, tb : Tree
	var opa, opb : OpSig
	var bOps : Tree

	const env <- Environment$env
	const ttc <- env$tracetypecheck
	var abconindex : Integer
	var removeOnReturn : Boolean <- false

	if A == nil then
	  if ttc then env.printf["Conforms: A is nil on line %d\n", {ln}] end if
	  self.reportWhy[depth, "A is nil", nil, A, B]
	  answer <- false
	  return
	elseif B == nil then
	  if ttc then env.printf["Conforms: B is nil on line %d\n", {ln}] end if
	  self.reportWhy[depth, "B is nil", nil, A, B]
	  answer <- false
	  return
	end if
	if ttc then
	  env.printf["Conforms: %S to %S on line %d\n", {A, B, ln}]
	  env.printf["Conforms(tv?):  %S, %S\n", { A$isTypeVariable, B$isTypeVariable }]
	  env.printf["Conforms(im?):  %S, %S\n", { A$isImmutable, B$isImmutable }]
	  env.printf["Conforms(id?):  %S, %S\n", { A$id, B$id }]
	end if
	answer <- A$id == B$id
	if answer then
	  if ttc then env.printf["  same id -> %s\n", {answer.asString}] end if
	  return
	end if
	answer <- red.lookup[A, B]
	if answer then
	  if ttc then env.printf["  cache says %s\n", {answer.asString}] end if
	  return
	end if
	if A$id == 0x1607 then
	  if ttc then env.printf["  none conforms to everything\n", nil] end if
	  answer <- true
	  return
	end if
	if B$id == 0x1601 then
	  if ttc then env.printf["  everything conforms to any\n", nil] end if
	  answer <- true
	  return
	end if
	if B$id == 0x1607 then
	  if ttc then env.printf["  nothing conforms to none\n", nil] end if
	  answer <- false
	  return
	end if
	if B$isImmutable and !A$isImmutable then
	  if ttc then env.printf["  immutable mismatch -> false\n", nil] end if
	  self.reportWhy[depth, "Immutable mismatch", nil, A, B]
	  return
	end if

	if B$isVector then
	  if !A$isVector then
	    if ttc then env.printf["  B is a vector (A isn't) -> false\n", nil] end if
	    self.reportWhy[depth, "Vector mismatch", nil, A, B]
	    return
	  end if
	else
	  % Check for builtin types that are not conformable to
	  const bID <- b$id
	  if 0x1600 <= bID and bID <= 0x1640 then
	    const itssize : Integer <- ids.IDToSize[bID]
	    if itssize < 8 then
	      if ttc then env.printf["  B cannotbeconformedto -> false\n", nil] end if
	      self.reportWhy[depth, "%S is a primitive type which cannot be conformed to", {self.getString[B]}, A, B]
	      answer <- false
	      return
	    end if
	  end if
	end if

	red.insert[A, B]
	if ttc then env.printf["Inserting %S -> %S in red\n", { A, B}] end if
	if B$isTypeVariable and indigo.Lookup[B] == nil then
	  removeOnReturn <- true
	  indigo.Insert[B, A]
	  red.insert[B, A]
	  if ttc then env.printf["Inserting %S -> %S in red (and indigo)\n", { B, A}] end if
	end if
	bOps <- B$ops

	const limit <- bOps.upperbound
	for i : Integer <- 0 while i <= limit by i <- i + 1
	  var jlimit : Integer
	  opb <- view bOps[i] as OpSig
	  opa, abconindex <- A.findOp[opb$name, opb$nargs, 0]
	  if opa == nil then
	    if ttc then env.printf["  Can't find operation %s\n", {opb$name.asString}] end if
	    self.reportWhy[depth, "Can't find operation %S", { opb$name}, A, B]
	    return
	  end if
	  if ttc then env.printf[" Checking operation %s[%d]\n",
	    {opb$name.asString, opb$nargs}]
	  end if
	  aa <- opa$params
	  ba <- opb$params
	  jlimit <- opb$nargs
	  for j : Integer <- 0 while j < jlimit by j <- j + 1
	    ta <- aa[j].asType
	    tb <- ba[j].asType
	    if ta == nil or tb == nil then
	      if ttc then env.printf["  Missing types for param %d\n", {j+1}] end if
	      self.reportWhy[depth, "Missing types for param %d", {j+1}, A, B]
	      return
	    end if
	    if nameof ta = "anatlit" and nameof tb = "anatlit" then
	      if !self.Conforms[ln, view tb as ATLit, view ta as ATLit, depth+1] then
		if ttc then env.printf["  param %d doesn't conform\n", {j+1}] end if
		self.reportWhy[depth, "param %d to operation %S doesn't conform", {j+1, opb$name}, A, B]
		return
	      end if
	    else
	      if ttc then env.printf["  param %d: %s to %s\n",
		{ j+1, tb.asString, ta.asString} ]
	      end if
	      if !IDS.ConformsByID[ln, (view tb as hasID)$id, (view ta as hasID)$id] then
		if ttc then env.printf["  param %d doesn't conform\n", {j+1}] end if
		self.reportWhy[depth+1, "Conforms by ID fails", nil, tb, ta]
		self.reportWhy[depth, "param %d to operation %S doesn't conform", {j+1, opb$name}, A, B]
		return
	      end if
	    end if
	  end for
	  aa <- opa.getResults
	  ba <- opb.getResults
	  jlimit <- opb$nress
	  for j : Integer <- 0 while j < jlimit by j <- j + 1
	    if aa !== nil then ta <- aa[j].asType else ta <- nil end if
	    if ba !== nil then tb <- ba[j].asType else tb <- nil end if
	    if ta == nil or tb == nil then
	      if ttc then env.printf["  Missing types for result %d\n", {j+1}] end if
	      self.reportWhy[depth, "Missing types for result %d", {j+1}, A, B]
	      return
	    end if
	    if nameof ta = "anatlit" and nameof tb = "anatlit" then
	      if !self.Conforms[ln, view ta as ATLit, view tb as ATLit, depth + 1] then
		if ttc then env.printf["  result %d doesn't conform\n", {j+1}] end if
		self.reportWhy[depth, "result %d of operation %S doesn't conform", {j+1, opb$name}, A, B]
		return
	      end if
	    else
	      if ttc then env.printf["  param %d: %s to %s\n",
		{ j+1, ta.asString, tb.asString} ]
	      end if
	      if !IDS.ConformsByID[ln, (view ta as hasID)$id, (view tb as hasID)$id] then
		if ttc then env.printf["  result %d doesn't conform\n", {j+1}] end if
		self.reportWhy[depth, "result %d of operation %S doesn't conform", {j+1, opb$name}, A, B]
		return
	      end if
	    end if
	  end for
	end for
	answer <- true
	if ttc then env.printf[" Answer is yes\n", nil] end if

	if removeOnReturn then
	  red.Forget[B, A]
	  indigo.Forget[B]
	end if
      end Conforms

    end cache
    if nameof A = "anatlit" then
      answer <- cache.Conforms[ln, view A as atlit, view B as atlit, 1]
    else
      const alist <- view A as RISA
      const blist <- view B as RISA
      assert Alist.upperbound = Blist.upperbound
      for i : Integer <- 0 while i <= Alist.upperbound by i <- i + 1
	for j : Integer <- 0 while j <= Alist.upperbound by j <- j + 1
	  if i != j then
	    cache.assume[view Alist[j] as ATLit, view Blist[j] as ATLit]
	  end if
	end for
	answer <- cache.conforms[ln, view alist[i]as ATLit, view blist[i] as ATLit, 1]
	if !answer then return end if
	for j : Integer <- 0 while j <= Alist.upperbound by j <- j + 1
	  if i != j then
	    cache.forget[view Alist[j] as ATLit, view Blist[j] as ATLit]
	  end if
	end for
      end for
    end if
  end Conforms
end Conformer
