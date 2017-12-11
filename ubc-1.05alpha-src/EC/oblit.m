
export Oblit

const oblit <- class Oblit (OTree) [xxsfname : Tree, xxname : Tree, xxdecls : Tree, xxops : Tree]
    field codeOID : Integer
    field id : Integer
    field st  : SymbolTable
    field sfname : Tree <- xxsfname
    field xsetq : Tree
    field name : Tree <- xxname
    field myat : Tree
    field xparam : Tree
    field decls : Tree <- xxdecls
    field ops : Tree <- xxops
    field instanceSize : Integer <- 0
    field vectorBrand : Character
    var instct : ObLit
    var instat : Tree

    export operation setBuiltinID [t : Tree]
      const ts <- view t as hasStr
      const thestr : String <- ts.getStr
      const theid <- Integer.Literal[thestr]
      codeOID <- theid + 0x400

      if 0x1000 <= theid and theid <= 0x1040 then
	id <- theid
	ObjectTable.Define[id, self]
	if id = 0x100c then		% VECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	elseif id = 0x1012 then		% IMMUTABLEVECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	end if
      elseif 0x1400 <= theid and theid <= 0x1440 then
	if theid = 0x140c then			% VECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	elseif theid = 0x1412 then		% IMMUTABLEVECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	elseif theid = 0x1416 then		% VECTOROFCHAR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	  vectorBrand <- 'c'
	elseif theid = 0x140b then		% STRING
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	  vectorBrand <- 'c'
	elseif theid = 0x140f then		% NODELIST
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'X'
	elseif theid = 0x1413 then		% BITCHUNK
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~1
	  vectorBrand <- 'b'
	elseif theid = 0x1419 then		% COPVECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'X'
	elseif theid = 0x141b then		% AOPVECTOR
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'X'
	elseif theid = 0x141d then		% APARAMLIST
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'x'
	elseif theid = 0x141e then		% VECTOROFINT
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'd'
	elseif theid = 0x1421 then		% IVECTOROFANY
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~8
	  vectorBrand <- 'v'
	elseif theid = 0x1423 then		% IVECTOROFINT
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'd'
	elseif theid = 0x1427 then		% LITERALLIST
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'l'
	elseif theid = 0x1428 then		% VECTOROFANY
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~8
	  vectorBrand <- 'v'
	elseif theid = 0x1429 then		% IVECTOROFSTRING
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'X'
	elseif theid = 0x142a then		% VECTOROFSTRING
	  f <- f.setBit[xisVector, true]
	  instanceSize <- ~4
	  vectorBrand <- 'X'
	end if
	ObjectTable.Define[codeOID, self]
      end if
    end setBuiltinID

    export function upperbound -> [r : Integer]
      r <- 5
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- sfname
      elseif i = 1 then
	r <- xparam
      elseif i = 2 then
	r <- xsetq
      elseif i = 3 then
	r <- name
      elseif i = 4 then
	r <- decls
      elseif i = 5 then
	r <- ops
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	sfname <- r
      elseif i = 1 then
	xparam <- r
      elseif i = 2 then
	xsetq <- r
      elseif i = 3 then
	name <- r
      elseif i = 4 then
	decls <- r
      elseif i = 5 then
	ops <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsfname, nname, ndecls, nops : Tree
      var newob : Oblit
      if sfname !== nil then nsfname <- sfname.copy[i] end if
      if name !== nil then nname <- name.copy[i] end if
      if decls !== nil then ndecls <- decls.copy[i] end if
      if ops !== nil then nops <- ops.copy[i] end if
      newob <- oblit.create[ln, nsfname, nname, ndecls, nops]
      newob$isImmutable <- f.getBit[xisImmutable]
      newob$isVector <- f.getBit[xisVector]
      newob$isMonitored <- f.getBit[xisMonitored]
      newob$monitorMayBeElided <- f.getBit[xmonitorMayBeElided]
      newob$typesAreAssigned <- false
      newob$typesHaveBeenChecked <- false
      newob$alreadyGenerated <- false
      newob$queuedForGeneration <- false
      r <- newob
    end copy
    
  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    outdecls <- indecls
    if ininvoke then
      const sid <- newid.newid
      const asym : Sym <- sym.create[self$ln, sid]
      const c : constdecl <- constdecl.create[self$ln, asym, nil, self]
      if outdecls == nil then 
	outdecls <- seq.singleton[c]
      else
	outdecls.rcons[c]
      end if
      r <- sym.create[self$ln, sid]
    else
      r <- self
    end if
  end flatten

    operation iremoveSugar -> [r : Oblit]
      ops <- sugar.doFields[decls, ops]
      r <- self
    end iremoveSugar

    export operation setATType 
      if f.getBit[xisVector] then
	var et : Ident <- Environment$env$ITable.Lookup["nv", 999]
	var s : Symbol <- st.Lookup[ln, et, false]
	if s !== nil then
	  var thetype : Tree <- view s$value as Tree
	  if thetype !== nil then thetype <- thetype.asType end if
	  if thetype == nil then
	    Environment$env.pass["Vector.NV's value is nil\n",nil]
	  else
	    Environment$env.pass["Vector.NV is %s\n", {thetype.asString}]
	    if nameof thetype = "anatlit" then
	      (view thetype as ATLit)$instct <- self
	      Environment$env.pass["Setting instct to %s\n", { self.asString }]
	    end if
	  end if
	else
	  Environment$env.printf["Couldn't find NV for a vector", nil]
	end if
      end if
      if f.getBit[xisVector] and instanceSize = 0 then
	var et : Ident <- Environment$env$ITable.Lookup["elementtype", 999]
	var s : Symbol <- st.Lookup[ln, et, false]
	if s !== nil then
	  var thetype : Tree <- view s$value as Tree
	  var xx : hasVariableSize
	  if thetype !== nil then thetype <- thetype.asType end if
	  if thetype == nil then
	    Environment$env.pass["Vector.elementtype's value is nil\n",nil]
	  else
	    Environment$env.pass["Vec.etype is %s\n", {thetype.asString}]
	    xx <- view thetype as hasVariableSize
	    Environment$env.pass["Vec.etype size is %d\n", {xx.variableSize}]
	    if nameof thetype = "anatlit" then
	      const rr <- view thetype as ATLit
	      Environment$env.pass["Vec.eType.name %s\n", {rr$name.asString}]
	    end if
	    instanceSize <- ~xx.variableSize
	    vectorBrand <- xx.getBrand
	  end if
	else
	  Environment$env.printf["Couldn't find elementtype for a vector", nil]
	end if

      end if
    end setATType

    export operation doAllocation 
      var a, b, c : Integer
      a, b, c <- st.Allocate[0, 0, 0, nil]
    end doAllocation

    export operation findOp [itsname : Ident, isSelf : Boolean, nargs : Integer, nress : Integer] -> [r : OpDef, index : Integer]
      const ystring : String <- itsname$name
      const env <- Environment$env

      if ops !== nil then
	for i : Integer <- 3 while i <= ops.upperbound by i <- i + 1
	  const xop <- view ops[i] as OpDef
	  const xsig <- view xop$sig as OpSig
	  const xname <- xsig$name
	  const xstring : String <- xname$name
	  var xnargs : Integer
	  if xsig$params == nil then 
	    xnargs <- 0
	  else
	    xnargs <- xsig$params.upperbound + 1
	  end if
	  if xstring = ystring and (nargs == nil or xnargs = nargs) then
	    if xop$isExported or isSelf then
	      r <- xop
	      index <- i
	    end if
	    return
	  end if
	end for
      end if
    end findOp
    operation needInitially -> [r : Boolean]
      r <- false
      if f.getBit[xisMonitored] and !f.getBit[xmonitorMayBeElided] then
	r <- true
	return
      end if
      if ops[0] !== nil then
	r <- true
	return
      end if
      if decls !== nil then
	for i : Integer <- 0 while i <= decls.upperbound by i <- i + 1
	  const d <- decls[i]
	  if d$isNotManifest then
	    r <- true
	    return
	  end if
	end for
      end if
      if xsetq !== nil then
	for i : Integer <- 0 while i <= xsetq.upperbound by i <- i + 1
	  const d <- xsetq[i]
	  if d$isNotManifest then
	    r <- true
	    return
	  end if
	end for
      end if
    end needInitially

  export operation assignTypes 
    if !self$typesAreAssigned then
      const namesym <- (view self$name as Sym)$mysym
      self$typesAreAssigned <- true
      if namesym !== nil then
	namesym$ATInfo <- self.getAT
	namesym$CTInfo <- self
      end if
      FTree.assignTypes[self]
      if myat !== nil then myat.assignTypes end if
    end if
  end assignTypes

  export operation print [s : OutStream, indent : Integer]
    s.putstring["oblit @"]
    s.putint[ln, 0]
    s.putchar[' ']
    if self$id !== nil then
      s.putstring["id = "]
      s.putstring[self$id.asString]
      s.putchar[' ']
    end if
    if self$codeOID !== nil then
      s.putstring["codeoid = "]
      s.putstring[self$id.asString]
      s.putchar[' ']
    end if
    self.printFlags[s]
    if myat !== nil then
      s.putchar['\n']
      for i : Integer <- 0 while i < indent + 2 by i <- i + 1
	s.putchar[' ']
      end for
      s.putstring["at"]
      s.putchar[':']
      myat.print[s, indent]
    end if
    FTree.print[s, indent, self]
  end print

  export operation printsummary
    var t : Integer
    const env <- Environment$env
    primitive self [t] <- []
    env.printf["oblit at %x named %S on line %d ", 
      { t, (view self$name as Sym)$mysym$myident, ln }]
    if self$id !== nil then
      env.printf["id = %x ", { self$id} ]
    end if
    if self$codeOID !== nil then
      env.printf["codeoid = %x ", { self$codeoid} ]
    end if
    self.printFlags[env$stdout]
    env.printf["\n", nil]
  end printsummary

  export operation isAFunction [itsname:Ident, nargs:Integer, nress:Integer] -> [r : Boolean]
    var xop : OpDef
    var index : Integer
    xop, index <- self.findOp[itsname, true, nargs, nress]
    if xop == nil then
      r <- false
    else
      r <- (view xop$sig as OpSig)$isFunction
    end if
  end isAFunction

  export operation findInvocResult [itsname:Ident, nargs:Integer, nress:Integer] -> [ans : Tree]
    var xop : OpDef
    var index : Integer
    xop, index <- self.findOp[itsname, true, nargs, nress]
    if xop !== nil then
      const xbody <- xop$body
      const xstats <- (view xbody as Block)$stats
      if xstats !== nil and xstats.upperbound = 0 then
	const stat <- xstats[0]
	if nameof stat = "anassignstat" then
	  const xassign <- view stat as Assignstat
	  const r <- xassign$right
	  const l <- xassign$left
	
	  if r.upperbound = 0 and l !== nil and l.upperbound = 0 then
	    ans <- r[0]
	  end if
	end if
      end if
    end if
  end findInvocResult
    
  export operation buildSetq [s : Symbol] -> [r : Symbol]
    r <- setq.build[s, self]
  end buildSetq

  operation myatid -> [r : Integer]
    const myatashasid <- view myat as hasID
    r <- myatashasid.getId
  end myatid

  export operation generate [ct : Printable]
    const sfnameashasStr <- view self$sfname as hasStr
    const nameashasId <- view self$name as hasIdent
    const BCType <- ByteCode
    if nameof ct = "actcode" then
      const ctasct <- view ct as CTCode
      const temp <- Template.create

      if self$instanceSize = 0 then 
	self$instanceSize <- self$st$instanceSize 
      end if
      ctasct$instanceSize <- self$instanceSize

      % These are the kinds of objects whose data is stored as literal
      % data rather than as a pointer.
      if self$codeOID = 0x1803 or self$codeOID = 0x1804 or self$codeOID = 0x1806 or self$codeOID = 0x180a then
	ctasct$instanceFlags <- 0
      else
	ctasct$instanceFlags <- 0x20000000
      end if
      if self$isImmutable then
	ctasct$instanceFlags <- ctasct$instanceFlags + 0x40000000
      end if
      ctasct$name <- nameashasId$id$name
      ctasct$filename <- sfnameashasStr.getStr

      Environment$env.tgenerate["Generating oblit name = %s codeOID = %#x\n",
	{ nameashasId$id$name, self$codeOID : Any} ]
      ctasct$id <- self$codeOID

      if self$isVector then
	temp.isVector[self$vectorBrand]
      elseif self$instanceSize = 0 and ! self$isImmutable then
	temp.addOne['d', "pad@O4"]
	self$instanceSize <- 4
	ctasct$instanceSize <- self$instanceSize
      elseif self$codeOID = 0x1805 then % Condition
	assert self$instanceSize = 8
	temp.addOne['x', "myObject@O4"]
	temp.addOne['q', "waitingQueue@O8"]
      else
	self$st.writeTemplate[temp, 'O']
      end if
      ctasct$templ <- temp
      if Environment$env$generateATs and myat !== nil then
	ctasct$mytype <- RefByID.create[self.myatid]
      end if

      % Generate recovery ops[1], process ops[2] and ops
      for i : Integer <- 1 while i <= ops.upperbound by i <- i + 1
	const theop <- ops[i]
	if theop !== nil then
	  theop.generate[ct]
	end if
      end for

      % do the initially
      if self.needInitially then
	begin
	  const ove <- opvectore.create["initially"]
	  const mybc <- bytecode.create[ctasct$literals]
	  const ov <- ctasct$opVec
	  const templ <- Template.create
	  var nparams : Integer <- 0
	  const returnlabel <- mybc.declareLabel
	  const sq <- self$xsetq
	  const init <- ops[0]

	  mybc.nest[returnlabel]
	  ove$templ <- templ
	  ov[0] <- ove
  

	  % Generate the template
	  if init !== nil then
	    const hasBody <- typeobject t function getBody -> [Tree] end t
	    const initst <- (view (view init as hasbody)$body as hasst)$st
	    initst.writeTemplate[templ, 'L']
	  end if

	  mybc.lineNumber[0]

	  % Generate the prolog (allocate space for locals)
	  mybc.setLocalSize[st$localSize]
  
	  % Generate the monitor creation, if necessary
	  if Environment$env$generateconcurrent and f.getBit[xisMonitored] and !f.getBit[xmonitorMayBeElided] then
	    mybc.addCode["MONINIT"]
	  end if

	  % Generate the setq (parameter passing) code
	  if sq !== nil then

	    % Count the actual parameters
	    for i : Integer <- 0 while i <= sq.upperbound by i <- i + 1
	      const s <- view sq[i] as Setq
	      const p <- view s$param as Sym
	      const inn  <- view s$inner as Sym
	      const psym <- p$mysym
	      const isym <- inn$mysym

	      if s$isNotManifest then % or if it is a typevariable
		nparams <- nparams + 1
% We should do initiallies just like we do invocations, then we don't need a
% recursive interpreter (we can use the stack directly)
%		if psym$base = 'A' then
%		  psym$base <- 'L'
%		  psym$offset <- ~8 - psym$offset
%		end if
		if isym$isUsedOutsideInitially then
		  mybc.pushSize[inn$mysym$size]
		  p.generate[mybc]
		  inn.generateLValue[mybc]
		  mybc.popSize
		else
		  isym$base   <- psym$base
		  isym$offset <- psym$offset
		end if
	      end if
	    end for
	  end if

	  ove$nargs <- nparams

	  if self$decls !== nil then self$decls.generate[mybc] end if
	  if ops[0] !== nil then
	    ops[0].generate[mybc]
	  end if
	  
	  % Generate the epilog (return and pop args)
	  mybc.lineNumber[self$ln]
	  mybc.defineLabel[returnlabel]
	  mybc.addCode["QUIT"]
	  mybc.addValue[nparams, 1]
  
	  ove$code <- mybc.getString
	  ove$others <- mybc$others
	  begin
	    const lninfo <- mybc.getLNInfo
	    if lninfo !== nil then
	      templ.addLineNumbers[lninfo]
	    end if
	  end
	end
      end if
    elseif self$generateOnlyCT then
      % we are generating a closure, so we just push the ConcreteType
      const bc <- view ct as BCType
      bc.fetchLiteral[self$codeOID]
      bc.finishExpr[4, 0x1818, 0x1618]
    elseif self$isExported then
      self.generateSelf[ct]
    else
      const bc <- view ct as BCType
      const sq <- self$xsetq
      % We need to treat this as an expression, and do a creation

      bc.addCode["PUSHNIL"]
      if sq !== nil then
	bc.pushSize[8]
	for i : Integer <- 0 while i <= sq.upperbound by i <- i + 1
	  const s <- view sq[i] as Setq
	  const o <- view s$outer as Sym
	  if s$isNotManifest then	% or if it is a type variable
	    o.generate[ct]
	  end if
	end for
	bc.popSize
      end if

      bc.fetchLiteral[self$codeOID]
      if self$isVector then
	bc.addCode["LDAB"]
	bc.addValue[0, 1]
	bc.addCode["CREATEVEC"]
      else
	bc.addCode["CREATE"]
      end if
      bc.finishExpr[4, self$codeOID, self.myatid]
    end if
  end generate

  export operation generateSelf [xct : Printable]
    const bc <- view xct as ByteCode
    self.makeMeManifest
    bc.fetchLiteral[self$id]
    bc.finishExpr[4, codeoid, self.myatid]
  end generateSelf

  export operation makeMeManifest 
    if self$id == nil then
      self$id <- nextOID.nextOID
    end if
  end makeMeManifest

  export operation findThingsToGenerate[q : Any]
    if ! self$queuedForGeneration then
      const qt <- view q as aot
      qt.addUpper[self]
      if self$codeOID == nil then
	self$codeOID <- nextOID.nextOID
      end if
      self$queuedForGeneration <- true
      if myat !== nil then
	myat.findThingsToGenerate[q]
      end if
      FTree.findThingsToGenerate[q, self]
    end if
  end findThingsToGenerate

  export operation areMyImportsManifestOrExported -> [badname : String]
    if self$xsetq !== nil then
      for i : Integer <- 0 while i <= self$xsetq.upperbound by i <- i + 1
	const t <- self$xsetq[i]
	const s <- view t as Setq
	if s$isNotManifest then
	  badname <- (view s$inner as Sym)$mysym$myident$name
	  if Environment$env$explainNonManifests then
	    Environment$env.printf["Oblit %s imports nonmanifest symbol %s\n",
	      { (view name as Sym)$mysym$myident$name, badname } ]
	  end if
	end if
      end for
    end if
  end areMyImportsManifestOrExported

  export operation findManifests -> [changed : Boolean]
    changed <- false
    if self$isNotManifest then
      % I'm already decided
    else
      if ! self$isImmutable then
	self$isNotManifest <- true
	self$name$isNotManifest <- true
	changed <- true
      elseif self$st$depth > 2 and (codeoid != nil and codeoid < 0x1a00 or self$isVector) then
	self$isNotManifest <- true
	self$name$isNotManifest <- true
	changed <- true
      else
	if self.areMyImportsManifestOrExported !== nil then
	  self$isNotManifest <- true
	  self$name$isNotManifest <- true
	  changed <- true
	end if
      end if
    end if
    if myat !== nil then changed <- myat.findManifests | changed end if
    changed <- FTree.findManifests[self] | changed
  end findManifests
  
  export operation execute -> [r : Tree]
    if !self$isNotManifest then
      r <- self
    end if
  end execute

  export function asType -> [r : Tree]
%   assert !self$isNotManifest
    if self$isImmutable then
      var s : Tree
      s <- self.findInvocResult[OpName.Literal["getsignature"], nil, 1]
      if s !== nil then
	r <- s.execute
	if r == nil then
	  Environment$env.printf["oblit.astype: execute on %s failed\n",
	    { s.asString}]
	  s.print[Environment$env$stdout, 0]
	else
	  r <- r.asType
	end if
      end if
    end if
    if r == nil and self$id !== nil then
      % We have explicitly exclude Array, Vector, and ImmutableVector from
      % consideration here, as they are not types.
      if 0x1000 <= id and id <= 0x1040 and id != 0x1002 and id != 0x100c and id != 0x1012 then
	r <- builtinlit.create[self$ln, id + 0x600 - 0x1000]
      end if
    end if
  end asType

  export operation evaluateManifests 
    % If I am a closure, then ensure that my setq's are all manifest
    if self$generateOnlyCT then
      if self$xsetq !== nil then
	const upb : Integer <- self$xsetq.upperbound
	var   lwb : Integer <- 0
	if self$xparam !== nil then lwb <- self$xparam.upperbound + 1 end if
	for i : Integer <- lwb while i <= upb by i <- i + 1
	  begin
	    const t <- self$xsetq[i]
	    const s <- view t as Setq
	    if s$isNotManifest then
	      Environment$env.SemanticError[self$ln, "Import of non manifest symbol \"%s\" into closure", { (view s$outer as Sym)$id$name }]
	    end if
	  end
	end for
      end if
    end if
    if ! self$isNotManifest then
      % I am in fact manifest, and need to be created now
      const t <- view self$name as Sym
      if t$mysym$value == nil then
	t$mysym$value <- self
      end if
      self.makeMeManifest
    end if
    if self$codeOID == nil then
      self$codeOID <- nextOID.nextOID
    end if
    if myat !== nil then myat.evaluateManifests end if
    FTree.evaluateManifests[self]
  end evaluateManifests

  export operation removeSugar [ob : Tree] -> [r : Oblit]
    var foo : Tree
    if !self$hasBeenDesugared then
      self$hasBeenDesugared <- true
      r <- self.iremoveSugar[]
      foo <- FTree.removeSugar[r, self]
      assert foo == r
    else
      r <- self
    end if
  end removeSugar

  export operation defineSymbols[pst : SymbolTable]
    const nst <- SymbolTable.create[pst, CObLit]
    const s <- nst.Define[ln, (view self$name as hasIdent)$id, SConst, false]
    nst$mytree <- self
    nst$kind <- SParam
    s$isSelf <- true
    s$value  <- self
    self$st <- nst
    for i : Integer <- 3 while i <= ops.upperbound by i <- i + 1
      const idef <- view ops[i] as OpDef
      const isig <- idef$sig
      const opisname : String <- isig$name$name
      const opisnargs : Integer <- isig$nargs
      const opisnress : Integer <- isig$nress
      for j : Integer <- i + 1 while j <= ops.upperbound by j <- j + 1
	const jdef <- view ops[j] as OpDef
	const jsig <- jdef$sig
	const opjsname : String <- jsig$name$name
	const opjsnargs : Integer <- jsig$nargs
	const opjsnress : Integer <- jsig$nress
	% TODO:  This should also check number of results when we properly 
	% overload on them
	%
	% i.e. and opisnress = opjsnress
	if opisname = opjsname and opisnargs = opjsnargs then
	  Environment$env.SemanticError[jsig$ln, "Operation %s[%d] is multiply defined", { opisname, opisnargs }]
	end if
      end for
    end for
    if self$isImmutable then
      if ops[1] !== nil then
	Environment$env.SemanticError[ln, 
	  "Immutable objects are not allowed recovery sections", nil]
      end if
      if ops[2] !== nil then
	Environment$env.SemanticError[ln, 
	  "Immutable objects are not allowed processes", nil]      
      end if
    end if
    FTree.defineSymbols[nst, self]

    % Go through and pretend that those symbol tables in the 
    % process and recovery are opdefs

    for i : Integer <- 1 while i < 3 by i <- i + 1
      const theop <- ops[i]
      if theop !== nil then
	const hasBody <- typeobject t function getBody -> [Tree] end t
	const thest <- (view (view theop as hasbody)$body as hasst)$st
	thest$context <- COpDef
      end if
    end for

  end defineSymbols

  export operation checkBuiltinInstAT
    if id !== nil or codeOID !== nil then
      const myinstct <- view self.getInstCT as Oblit
  
      Environment$env.pass["Check builtin inst AT\n", nil]
      if myinstct !== nil then
	const myinstid <- myinstct.getCodeOID
	if myinstid !== nil and myinstid <= 0x2000 and
	   myinstid != 0x180c and myinstid != 0x1812 then	% It is a builtin
	  const myinstat <- self.getInstAT
	  Environment$env.pass[" Looking at a builtin %x\n", {myinstid}]
	  if myinstat !== nil then
	    const myinstctsat <- myinstct$myat
	    if myinstctsat !== nil then
	      Environment$env.pass["  Found a %s as myinstct's at\n",
		{nameof myinstctsat}]
	    end if
	    myinstct$myat <- myinstat
	  end if
	end if
      end if
    end if
  end checkBuiltinInstAT
      
  export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
    if self$generateOnlyCT and self$xparam !== nil then
      const ps <- self$xparam
      var asetq : Any
      for i : Integer <- 0 while i <= ps.upperbound by i <- i + 1
	const p <- view ps[i] as Param
	const s <- view p$xsym as Sym
	const sb <- s$mysym
	asetq <- setq.build[sb, self]
      end for
    end if
    FTree.resolveSymbols[self$st, self, 0]
    self.checkBuiltinInstAT
  end resolveSymbols

  export operation typeValue -> [r : Any]
  end typeValue

  export operation getAT -> [r : Tree]
    if self$myat == nil then
      if self$generateOnlyCT then
	self$myat <- builtinlit.create[self$ln, 0x18].getInstAT
      else
	const namehasid <- view self$name as hasIdent
	const nameid <- namehasid$id
	const newid <- Environment.getEnv.getITable.Lookup[nameid$name||"type", 999]
	const sigs <- seq.create[self$ln]
	var theOps : Tree <- self$ops
    
	Environment$env.tassignTypes["oblit.getAT on %s\n", {self$name.asString}]
	if theops !== nil then
	  for i : Integer <- 3 while i <= theops.upperbound by i <- i + 1
	    const xop <- view theops[i] as OpDef
	    const xsig <- view xop$sig as OpSig
	    if xop$isExported then
%	      Environment$env.pass["  op %d %s is exported\n", 
%		{i, xsig$name.asString}]

% if use copy
	      if Environment$env$doingIdsEarly then
		sigs.rcons[xsig.copy[0]]
	      else
		sigs.rcons[xsig.copy[2]]
	      end if
% else
%	      sigs.rcons[xsig]
% end if
	    else
%	      Environment$env.pass["  op %d %s is not exported\n", 
%		{i, xsig$name.asString}]
	    end if
	  end for
	end if
	const newat <- atlit.create[ln, self$sfname.copy[0], Sym.create[ln, newid], sigs]
	if id !== nil then
	  if 0x1000 <= id and id <= 0x1040 then
	    newat$id <- id + 0x200
	  end if
	end if
	if codeoid !== nil then
	  if 0x1800 <= codeoid and codeoid <= 0x1840 then
	    newat$id <- codeoid - 0x200
	  end if
	end if
	if Environment$env$doingIdsEarly then
	  const junk <- newat.removeSugar[nil]
	  if st == nil then 
	    newat.defineSymbols[st]
	    newat.resolveSymbols[st, 0]
	  else
	    newat.defineSymbols[st$outer] 
	    newat.resolveSymbols[st$outer, 0]
	  end if
	end if
	newat.makeMeManifest
	newat$isimmutable <- self$isimmutable
	newat$isVector <- self$isVector
	self$myat <- newat
	const namesym <- (view self$name as Sym)$mysym
	if namesym !== nil then
	  namesym$ATInfo <- newat
	  namesym$CTInfo <- self
	end if
      end if
    end if
    r <- self$myat
  end getAT

  export operation getCT -> [r : Tree]
    if self$generateOnlyCT then
      r <- builtinlit.create[self$ln, 0x18].getInstCT
    else
      r <- self
    end if
  end getCT

  export function getInstCT -> [r : Tree]
    if !self$knowinstct then
      if self$generateOnlyCT then
	% I don't know!!!!  nil will do for now
      else
	instct <- view self.findInvocResult[opname.literal["create"], nil, 1] as ObLit
      end if
      self$knowinstct <- true
    end if
    r <- instct
  end getInstCT

  export function getInstAT -> [r : Tree]
    if !self$knowinstat then
      instat <- self.findInvocResult[opname.literal["getsignature"], nil, 1]
      if instat !== nil then
	instat <- instat.execute.asType
      end if
      self$knowinstat <- true
    end if
    r <- instat
  end getInstAT

  export function getinstCTOID -> [r : Integer]
    const x <- self$instCT
    if x !== nil and nameof x = "anoblit" then
      const y <- view x as hasIDs
      r <- y$codeOID
    end if
  end getinstCTOID

  export function getinstATOID -> [r : Integer]
    const x <- self$instAT
    if x !== nil then
      const xx <- view x as hasID
      r <- xx$ID
    end if
  end getinstATOID

  export operation getATOID -> [oid : Integer]
    const x <- view self.getAT as hasID
    oid <- x$id
  end getATOID

  export operation setATOID [oid : Integer]
    const x <- view self.getAT as typeobject t
      operation setID [Integer]
    end t
    if x == nil then
      Environment$env.pass["Can't set atOID of %S to %#x", {self$name, oid}]
    else
      x$id <- oid
    end if
  end setATOID

  export operation setinstCTOID [oid : Integer]
    const x <- view self$instCT as typeobject t
      operation setCodeOID [Integer]
    end t
    if x == nil then
      Environment$env.pass["Can't set instctoid of %s to %#x", {self$name.asString, oid}]
    else
      x$codeOID <- oid
    end if
  end setinstCTOID

  export operation setinstATOID [oid : Integer]
    const x <- view self$instAT as typeobject t
      operation setID [Integer]
    end t
    if x == nil then
      Environment$env.pass["Can't set instatoid of %s to %#x", {self$name.asString, oid}]
    else
      x$ID <- oid
    end if
  end setinstATOID

  operation pruneList[list : Tree]
    if list !== nil then
      for i : Integer <- 0 while i <= list.upperbound by i <- i + 1
	const p <- list[i] 
	const stype <- p.asType
	const ttype <- view stype as hasID
	const typeid <- ttype$id

	list[i] <- globalref.create[p$ln, typeid, 0x1609, nil, nil, nil]
      end for
    end if
  end pruneList

  export operation prune 
    if self$isPruned then return end if
    self$isPruned <- true

    const namesym <- view name as Sym
    namesym.prune
    (view myat as ATlit).prune
    xsetq <- nil
    decls <- nil

    if ops !== nil and ops.upperbound >= 0 then
      ops[0] <- nil
      ops[1] <- nil
      ops[2] <- nil

      for i : Integer <- 3 while i <= ops.upperbound by i <- i + 1
	const xdef <- view ops[i] as OpDef
	const xsig <- view xdef$sig as OpSig

	if xdef$isInlineable then
	  % can't prune anything, really
	else
	  % I can prune the signature only if the operation is not inlineable
	  self.prunelist[xsig$params]
	  self.prunelist[xsig$results]
	  xdef$body <- nil
	  xdef$st <- nil
	  xsig$st <- nil
	end if
      end for
    end if
  end prune

  export function asString -> [r : String]
    r <- "oblit"
  end asString
end Oblit
