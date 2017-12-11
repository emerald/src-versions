export SymbolTable, Symbol, hasST
export SUnknown, SConst, SVar, SParam, SResult, SOpName, SImport, SExternal
export CATLit, CObLit, COpSig, COpDef, CUnavailableHandler, CComp, CBlock, COutside

const Templ <- typeobject Templ
  operation addOne[Character, String]
end Templ

const STKind <- Integer
const SUnknown <- 0
const SConst <- 1
const SVar <- 2
const SParam <- 3
const SResult <- 4
const SOpName <- 5
const SImport <- 6
const SExternal <- 7

const STContext <- Integer

const CATLit <- 0
const CObLit <- 1
const COpSig <- 2
const COpDef <- 3
const CUnavailableHandler <- 4
const CComp <- 5
const CBlock <- 6
const COutside <- 7

const Tree <- typeobject Tree
  operation copy [i : Integer] -> [r : Tree]
  function asString -> [String]
end Tree

const XTree <- typeobject XTree
  operation copy [i : Integer] -> [r : Tree]
  function asString -> [String]
  function variableSize -> [Integer]
  function getBrand -> [Character]
end XTree

const ObLit <- typeobject ObLit
  function  getIsMonitored -> [Boolean]
  function  getIsSynchronized -> [Boolean]
  function  getMonitorMayBeElided -> [Boolean]
  operation setST [SymbolTable]
end ObLit

const envtype <- typeobject envtype
  operation pass [String, RISA]
  operation tallocation[String, RISA]
  operation printf [String, RISA]
  operation Warning [Integer, String, RISA]
  operation SemanticError [Integer, String, RISA]
  function  getCompilingBuiltins -> [Boolean]
  function  getWarnShadows -> [Boolean]
  function getGenerateConcurrent -> [Boolean]
  function getAny -> [Tree]
  function getTraceSymbols -> [Boolean]
  function getTraceAllocation -> [Boolean]
  function getImplicitlyDefineExternals -> [Boolean]
  function getITable -> [LookupIdent]
end envtype

const Environment <- immutable object Environment
  export operation getenv -> [env : envtype]
    primitive var "GETENV" [env] <- []
  end getenv
end Environment

const Symbol <- class Symbol [xk : STKind, xi : Ident, xst : SymbolTable]
    field mykind : STKind <- xk
% If doing moves/visits
%    field ismove : Boolean <- false
%    field isvisit : Boolean <- false

    field flags : Integer <- 0
    const isattached_f <- 0
    const isSelf_f <- 1
    const isNotManifest_f <- 2
    const isUsedOutsideInitially_f <- 3
    const isTypeVariable_f <- 4
    const isCTKnown_f <- 5
    const hasPointer_f <- 6
    const isInstVariable_f <- 7
    const hasConstraint_f <- 8
    const willHaveConstraint_f <- 9
    field offset : Integer
    field size : Integer <- 8
    field base : Character

    field myident : Ident <- xi
    field ATinfo : Tree
    field CTinfo : Tree
    field Value  : Tree

    export function getIsAttached -> [r : Boolean]
      r <- flags.getBit[isAttached_f]
    end getIsAttached
    export operation setIsAttached [v : Boolean]
      flags <- flags.setBit[isAttached_f, v]
    end setIsAttached

    export function getisSelf -> [r : Boolean]
      r <- flags.getBit[isSelf_f]
    end getisSelf
    export operation setisSelf [v : Boolean]
      flags <- flags.setBit[isSelf_f, v]
    end setisSelf

    export function getisNotManifest -> [r : Boolean]
      r <- flags.getBit[isNotManifest_f]
    end getisNotManifest
    export operation setisNotManifest [v : Boolean]
      flags <- flags.setBit[isNotManifest_f, v]
    end setisNotManifest

    export function getisUsedOutsideInitially -> [r : Boolean]
      r <- flags.getBit[isUsedOutsideInitially_f]
    end getisUsedOutsideInitially
    export operation setisUsedOutsideInitially [v : Boolean]
      flags <- flags.setBit[isUsedOutsideInitially_f, v]
    end setisUsedOutsideInitially

    export function getisTypeVariable -> [r : Boolean]
      r <- flags.getBit[isTypeVariable_f]
    end getisTypeVariable
    export operation setisTypeVariable [v : Boolean]
      flags <- flags.setBit[isTypeVariable_f, v]
    end setisTypeVariable

    export function getisCTKnown -> [r : Boolean]
      r <- flags.getBit[isCTKnown_f]
    end getisCTKnown
    export operation setisCTKnown [v : Boolean]
      flags <- flags.setBit[isCTKnown_f, v]
    end setisCTKnown

    export function gethasPointer -> [r : Boolean]
      r <- flags.getBit[hasPointer_f]
    end gethasPointer
    export operation sethasPointer [v : Boolean]
      flags <- flags.setBit[hasPointer_f, v]
    end sethasPointer

    export function getisInstVariable -> [r : Boolean]
      r <- flags.getBit[isInstVariable_f]
    end getisInstVariable
    export operation setIsInstVariable [v : Boolean]
      flags <- flags.setBit[isInstVariable_f, v]
    end setIsInstVariable

    export function gethasConstraint -> [r : Boolean]
      r <- flags.getBit[hasConstraint_f]
    end gethasConstraint
    export operation sethasConstraint [v : Boolean]
      flags <- flags.setBit[hasConstraint_f, v]
    end sethasConstraint

    export function getwillHaveConstraint -> [r : Boolean]
      r <- flags.getBit[willHaveConstraint_f]
    end getwillHaveConstraint
    export operation setwillHaveConstraint [v : Boolean]
      flags <- flags.setBit[willHaveConstraint_f, v]
    end setwillHaveConstraint

    export operation copy [i : Integer] -> [r : Symbol]
      if i == 0 then		% delete symbols
	r <- nil
      elseif i == 1 or i == 2 then
	var nid : Ident
	var it : LookupIdent
	const env <- Environment$env
	it <- env.getITable
	if myident !== nil then nid <- it.Lookup[myident.asString, 999] end if
	r <- symbol.create[mykind, nid, nil]
% If doing move/visit
	r$isattached <- self$isattached
%	r$ismove <- self$ismove
%	r$isvisit <- self$isvisit
	r$isUsedOutsideInitially <- self$isUsedOutsideInitially
	r$isSelf <- self$isself
	r$isNotManifest <- self$isNotManifest
	r$isInstVariable <- self$isInstVariable
	r$hasConstraint <- self$hasConstraint

	if i == 1 then		% reset symbols
	  r$ATinfo <- nil
	  r$CTinfo <- nil
	  r$Value  <- nil
	else
	  r$ATinfo <- ATinfo
	  r$CTinfo <- CTinfo
	  r$Value  <- value
	end if
      else
	assert false
      end if
    end copy
    export function asString -> [r : String]
      var me : Integer
      var a : Any <- self

      r <- "asymbol"
      if myident !== nil then
	r <- r || " \""|| myident.asString || "\""
      end if
%      primitive  [me] <- [a]
%      r <- r || " " || me.asString
      if self$isUsedOutsideInitially then
	r <- r || " uoi"
      else
	r <- r || " !uoi"
      end if
      if base !== nil and offset !== nil then
	r <- r || " " || base.asString || "@" || offset.asString
      end if
    end asString
  export operation Print [s : OutStream]
    s.putstring[self.asString[]]
  end Print
  initially
    if xst !== nil then self.setIsInstVariable[xst.isLiteral] end if
  end initially
end Symbol

const vosymbol <- Vector.of[Symbol]
const aosymboltable <- Array.of[SymbolTable]

const SymbolTable <- class SymbolTable [xouter : SymbolTable, cx : STContext]
    var tablesize : Integer <- 4
    var upb : Integer <- ~1
    field context : STContext <- cx
    field kind : STKind
    field localSize : Integer <- 0
    field instanceSize : Integer <- 0
    field depth : Integer <- 0
    var inInitially : Boolean <- true
    var table : vosymbol <- vosymbol.create[4]
    const field inner : aosymboltable <- aosymboltable.create[~4]
    field mytree : Tree
    var outer : SymbolTable <- xouter

    operation getInInitially -> [r : Boolean]
      r <- inInitially
    end getInInitially

    export operation setInInitially[b : Boolean]
      inInitially <- b
      if context != CATLit and context != CObLit then
	outer$inInitially <- b
      end if
    end setInInitially

    operation iLookup [id : Ident] -> [r : Symbol]
      var s : Symbol
      for i : Integer <- upb while i >= 0 by i <- i - 1
	s <- table[i]
	if s$myident == id then
	  r <- s
	  if !inInitially then r$isUsedOutsideInitially <- true end if
	  return
	end if
      end for
    end iLookup

    export function getOuter -> [r : SymbolTable]
      r <- outer
    end getOuter

    export function isLiteral -> [r : Boolean]
      r <- context = CObLit or context = CATLit
    end isLiteral

    operation grow
      const newsize <- tablesize * 2
      const newtable <- vosymbol.create[newsize]
      var i : Integer <- 0
      loop
	exit when i >= tablesize
	newtable[i] <- table[i]
	i <- i + 1
      end loop
      table <- newtable
      tablesize  <- newsize
    end grow

    operation iDefine [id : Ident, thekind : STKind, isAttached : Boolean] -> [r : Symbol]
      r <- Symbol.create[thekind, id, self]
% If doing move/visit
      r$isattached <- isattached
      upb <- upb + 1
      if upb = tablesize then self.grow end if
      table[upb] <- r
    end iDefine
    export operation Insert [s : Symbol]
      upb <- upb + 1
      if upb = tablesize then self.grow end if
      table[upb] <- s
    end Insert
    export operation Print [s : OutStream, indent : Integer]
      s.putString["a symbol table, depth = "]
      s.putInt[depth, 0]
      s.putString[" localSize = "]
      s.putInt[localSize, 0]
      s.putString[" instanceSize = "]
      s.putInt[instanceSize, 0]
      s.putString["\n"]
      for i : Integer <- 0 while i < indent + 2 by i <- i + 1
	s.putchar[' ']
      end for
      for i : Integer <- 0 while i <= upb by i <- i + 1
	const asym : Symbol <- table[i]
	asym.print[s]
	s.putChar[' ']
      end for
      for i : Integer <- 0 while i <= inner.upperbound by i <- i + 1
	s.putchar['\n']
	for j : Integer <- 0 while j < indent + 4 by j <- j + 1
	  s.putchar[' ']
	end for
	inner[i].print[s, indent+2]
      end for
    end Print

    export operation Allocate [ao:Integer, io:Integer, lo:Integer, cx : STContext]
      -> [nao:Integer, nio:Integer, nlo:Integer]
      var s : Symbol
      var st  : SymbolTable
      var size : Integer
      var info : XTree
      const env <- Environment$env
      const tallocation <- env$traceallocation

      nao, nio, nlo <- ao, io, lo
      if cx !== nil and (context = CATLit or context = CObLit) then
	return 
      end if
      if context = COpDef or context = COpSig then
	nao <- 0
	nlo <- 0
      end if

      % Look for monitors
      if env$generateConcurrent and context = CObLit then
	const myobj <- view mytree as ObLit
	if myobj$isMonitored and ! myobj$monitorMayBeElided or myobj$isSynchronized then
	  size <- 8
	  nio <- nio + size
	end if
      end if

      % Go through the first time forwards, catching Ls and Os

      for i : Integer <- 0 while i <= upb by i <- i + 1
	s <- table[i]
	if s$isSelf then 
	  % no allocation needed
	  if tallocation then env.printf["  %s is self\n", {s.asString}] end if
	elseif ! s$isNotManifest and 
	      (s$mykind != SParam or context != COpDef) then
	  % a manifest symbol, no allocation
	  if tallocation then env.printf["  %s is manifest\n", {s.asString}] end if
	elseif s$mykind = SExternal then
	  % an external symbol, no allocation
	  if tallocation then env.printf["  %s is external\n", {s.asString}] end if
	else
	  if s$mykind = SParam or s$mykind = SResult then
	  elseif s$mykind = SImport and ! s$isUsedOutsideInitially then
	    % We don't need to allocate real space for this one, but how do
	    % I find the param?
	  else
	    if tallocation then env.printf["  %s is not manifest\n", {s.asString}] end if
	    if s$CTInfo !== nil then
	      info <- view s$CTInfo as XTree
	      if tallocation then env.printf["  has CT %s %d\n", {info.asString, info.variableSize}] end if
	      size <- info.variableSize
% TODO generate 4 byte thingies
%	      if size < 8 then s$isCTKnown <- true end if
	    elseif s$ATInfo !== nil then
	      info <- view s$ATInfo as XTree
	      if tallocation then env.printf["  has AT %s %d\n", {info.asString, info.variableSize}] end if
	      size <- info.variableSize
% TODO generate 4 byte thingies
%	      if size < 8 then s$hasPointer <- true end if
	    else
	      if tallocation then env.printf["  has no info 8\n", nil] end if
	      size <- 8
	    end if
	    if size = 1 then size <- 4 end if
	    s$size <- size

	    if context = CObLit or context = CATLit then
	      s$base <- 'O'
	      s$offset <- nio + 4
	      nio <- nio + size
	    else
	      s$base <- 'L'
	      s$offset <- nlo
	      nlo <- nlo + size
	    end if
	  end if
	end if
      end for

      % This time, catch arguments

      for i : Integer <- upb while i >= 0 by i <- i - 1
	s <- table[i]
	if s$isSelf then 
	  % no allocation needed
	  if tallocation then env.printf["  %s is self\n", {s.asString}] end if
	elseif ! s$isNotManifest and context != COpDef then
	  % a manifest symbol, no allocation
	  if tallocation then env.printf["  %s is manifest\n", {s.asString}] end if
	elseif s$mykind = SExternal then
	  % an external symbol, no allocation
	  if tallocation then env.printf["  %s is external\n", {s.asString}] end if
	elseif s$mykind = SParam then
	  if tallocation then env.printf["  %s is a param\n", {s.asString}] end if
	  if s$CTInfo !== nil then
	    info <- view s$CTInfo as XTree
	    if tallocation then env.printf["  has CT %s %d\n", {info.asString, info.variableSize}] end if
	    size <- info.variableSize
	  elseif s$ATInfo !== nil then
	    info <- view s$ATInfo as XTree
	    if tallocation then env.printf["  has AT %s %d\n", {info.asString, info.variableSize}] end if
	    size <- info.variableSize
	  else
	    if tallocation then env.printf["  has no info 8\n", nil] end if
	    size <- 8
	  end if
	  if size = 1 then size <- 4 end if
	  s$size <- size
	  s$base <- 'A'
	  s$offset <- nao
	  nao <- nao + 8
	end if
      end for

      % Finally, catch results

      size <- 8
      for i : Integer <- upb while i >= 0 by i<-i-1
	s <- table[i]
	if s$mykind = SResult then
	  s$base <- 'A'
	  s$offset <- nao
	  nao <- nao + size
	  s$size <- size
	end if
      end for

      for i : Integer <- 0 while i <= inner.upperbound by i<-i+1
	st <- inner[i]
	nao, nio, nlo <- st.Allocate[nao, nio, nlo, context]
      end for
      if context = COpDef or context = COpSig then
	localSize <- nlo
	nao <- ao
	nlo <- lo
      else
	localSize <- nlo
	instanceSize <- nio
      end if
    end Allocate

    export operation writeTemplate[thetemplate : Templ, thekind : Character]
      var st  : SymbolTable
      var brand : Character
      const env <- Environment$env

      % Look for monitors
      if env$generateConcurrent and context = CObLit then
	const myobj <- view mytree as ObLit
	if myobj$isMonitored and ! myobj$monitorMayBeElided or myobj$isSynchronized then
	  thetemplate.addOne['m', "monitor@O4"]
	end if
      end if

      for i : Integer <- 0 while i <= upb by i <- i + 1
	const s : Symbol <- table[i]
	const base <- s$base
	if base == thekind then
	  if s$CTInfo !== nil then
	    brand <- (view s$CTInfo as XTree).getBrand
	  elseif s$ATInfo !== nil then
	    brand <- (view s$ATInfo as XTree).getBrand
	  else
	    brand <- 'v'
	  end if
	  if s$isAttached then
	    brand <- Character.Literal[brand.ord - 'a'.ord + 'A'.ord]
	  end if
	  thetemplate.addOne[brand,
	    s$myident.asString || "@" || base.asString || s$offset.asString]
	end if
      end for

      if thekind = 'L' then
	for i : Integer <- 0 while i <= inner.upperbound by i<-i+1
	  st <- inner[i]
	  if !st.isLiteral then
	    st.writeTemplate[thetemplate, thekind]
	  end if
	end for

	for i : Integer <- 0 while i <= upb by i <- i + 1
	  const s : Symbol <- table[i]
	  const base <- s$base
	  if base == 'A' then
	    thetemplate.addOne['Z', 
	      s$myident.asString || "@" || base.asString || s$offset.asString]
	  end if
	end for
      end if
    end writeTemplate

    export operation discard 
      var st, stx : SymbolTable
      var upbx : Integer <- inner.upperbound
% Also avoid doing this to every tree, keep sts for oblits
%      const myobj <- view mytree as hasST
%      if myobj !== nil and nameof myobj != "anoblit" then
%	myobj$st <- nil
%      end if

      loop
	exit when upbx < 0
	st <- inner[upbx]
	inner[upbx] <- nil
	stx <- inner.removeUpper
	upbx <- upbx - 1
	st.discard
      end loop
% Don't trash this one, cause invocs need it
% Evaluating a manifest invocation on an old object needs to be able to find
% the symbol table.
%      outer <- nil
    end discard

    initially
      if outer !== nil then
	outer$inner.addUpper[self]
	depth <- outer$depth +  1
      end if
    end initially

  export function asString -> [r : String]
    r <- "a symbol table"
  end asString

  export operation Lookup [ln : Integer, id : Ident, deep : Boolean] -> [r : Symbol]
    var s : Symbol

    r <- self.iLookup[id]
    if deep == false then
      return
    elseif deep == nil then
      if self.isLiteral or outer == nil or outer$outer == nil then return end if
      const outersymbol <- outer.Lookup[ln, id, deep]
      if outerSymbol !== nil then
	const env <- Environment$env
	if env$warnShadows then
	  env.Warning[ln, "Definition of symbol \"%S\" shadows previous definition", { id }]
	end if
      end if
      return
    elseif r !== nil then
      return
    end if
    if outer !== nil then
      r <- outer.Lookup[ln, id, deep]
      if r !== nil and self.isLiteral[] and r$mykind != SExternal then
	const t <- view self.getmytree[] as typeobject T
	  operation buildSetq [Symbol] -> [Symbol]
	end T
	% do the setq stuff
	s <- t.buildSetq[r]
	s$value <- r$value
	r <- s
	if !inInitially then r$isUsedOutsideInitially <- true end if
      end if
    else 
      % outer is nil, so if implicitlyDefineExternals is set 
      % then define as an external
      const env <- Environment$env

      if env$implicitlyDefineExternals then
	if env$traceSymbols then 
	  env.printf["  Defining external symbol %s\n", { id$name }]
	end if
	r <- Symbol.create[SExternal, id, nil]
	r$isattached <- false
	r$isNotManifest <- true
	r$size <- 8
	r$ATInfo <- env.getAny
      end if
    end if
  end Lookup

  export operation Define [ln : Integer, id : Ident, thekind : STKind, isAttached : Boolean] -> [r : Symbol]
    if self.Lookup[ln, id, nil] == nil then
      r <- self.iDefine[id, thekind, isAttached]
    else
      Environment.getEnv.SemanticError[ln, "Redefinition of symbol \"%S\"",
	{ id } ]
    end if
  end Define

  export operation reInitialize 
    const i <- self$inner
    var junk : Any
    loop
      exit when i.upperbound < i.lowerbound
      junk <- i.removeUpper
    end loop
  end reInitialize
end SymbolTable

const hasST <- typeobject hasST
  function getST -> [SymbolTable]
  operation setST [SymbolTable]
end hasST

