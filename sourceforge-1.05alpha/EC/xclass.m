
export Xclass

const T <- Tree

const xclass <- class Xclass (OTree) [xxsfname : Tree, xxname : Tree, xxbase : Tree, xxparams : Tree, xxcreators : Tree, xxdecls : Tree, xxops : Tree]
    field sfname : Tree <- xxsfname
    field name : Tree <- xxname
    field base : Tree <- xxbase
    field params : Tree <- xxparams
    field creators : Tree <- xxcreators
    field decls : Tree <- xxdecls
    field ops : Tree <- xxops
    field value : Tree <- nil
    field bid : Integer

    export operation setBuiltinID [t : Tree]
      const ts <- view t as hasStr
      const thestr : String <- ts.getStr
      bid <- Integer.Literal[thestr]
    end setBuiltinID

    export function upperbound -> [r : Integer]
      r <- 6
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- sfname
      elseif i = 1 then
	r <- name
      elseif i = 2 then
	r <- base
      elseif i = 3 then
	r <- params
      elseif i = 4 then
	r <- creators
      elseif i = 5 then
	r <- decls
      elseif i = 6 then
	r <- ops
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	sfname <- r
      elseif i = 1 then
	name <- r
      elseif i = 2 then
	base <- r
      elseif i = 3 then
	params <- r
      elseif i = 4 then
	creators <- r
      elseif i = 5 then
	decls <- r
      elseif i = 6 then
	ops <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsfname, nname, nbase, nparams, ncreators, ndecls, nops, nvalue : Tree
      if sfname !== nil then nsfname <- sfname.copy[i] end if
      if name !== nil then nname <- name.copy[i] end if
      if base !== nil then nbase <- base.copy[i] end if
      if params !== nil then nparams <- params.copy[i] end if
      if creators !== nil then ncreators <- creators.copy[i] end if
      if decls !== nil then ndecls <- decls.copy[i] end if
      if ops !== nil then nops <- ops.copy[i] end if
      const newclass <- xclass.create[ln, nsfname, nname, nbase, nparams, 
	ncreators, ndecls, nops]
      newclass$value <- value
      r <- newclass
    end copy

    function isVowel [c : Character] -> [r : Boolean]
      r <- c = 'a' | c = 'e' | c = 'i' | c = 'o' | c = 'u'
    end isVowel
    
    function addA [id : Ident] -> [r : Ident]
      const oname : String <- id$name
      var nname : String
      const it <- Environment.getEnv.getITable
      if self.isVowel[oname[0]] then
	nname <- "an"
      else
	nname <- "a"
      end if
      nname <- nname || oname
      r <- it.Lookup[nname, 999]
    end addA
    
    operation mergebody [kind:Integer, old : Tree, newt : Tree] -> [res : Tree]
      const hasbody <- typeobject t op getBody -> [Tree] end t
      const newstats <- sseq.create[old$ln]
      newstats.rcons[(view old as hasbody)$body.copy[0]]
      newstats.rcons[(view newt as hasbody)$body.copy[0]]
      const newblock <- block.create[newt$ln, newstats, nil, nil]
      if kind == 0 then
	res <- InitDef.create[newt$ln, newblock]
      elseif kind == 1 then
	res <- RecoveryDef.create[newt$ln, newblock]
      else
	assert false
      end if
    end mergebody

    operation inherit[old : Tree, newt : Tree, kind : Integer] -> [r : Tree]
      var found : Boolean
      var lwb : Integer <- kind
      
      if old == nil then
	r <- newt
	return
      end if

      if newt == nil then
	r <- seq.create[old$ln]
      else
	r <- newt
      end if
      
      if kind == 2 then 
	lwb <- 3
	for i : Integer <- 0 while i < lwb by i <- i + 1
	  if newt[i] == nil and old[i] !== nil then
	    newt[i] <- old[i].copy[0]
	  elseif (i == 0 or i == 1) and newt[i] !== nil and old[i] !== nil then
	    newt[i] <- self.mergebody[i, old[i], newt[i]]
	  end if
	end for
      end if

      for i : Integer <- lwb while i <= old.upperbound by i <- i + 1
	const o <- old[i]
	found <- false
	if newt !== nil then
	  for j : Integer <- lwb while j <= newt.upperbound by j <- j + 1
	    const n <- newt[j]
	    found <- o.same[n]
	    exit when found
	  end for
	end if
	if !found then
	  r.rcons[o.copy[0]]
	end if
      end for
    end inherit
    
    operation iRemoveSugar -> [r : Tree]
      var typeO, instanceO : Oblit
      var instanceType, tdecls, tops, createparams : Tree
      var resultdef, resultref, createopsig, p : Tree
      var createopdef : OpDef
      var resultId : Ident
      const env <- Environment.getEnv
      const classIdent <- (view name as hasIdent)$id
      const typename <- env.getITable.Lookup[classIdent$name||"type", 999]
      const typenamedef <- sym.create[ln, typename]
      const typenameref <- sym.create[ln, typename]
      const instancename <- self.addA[classIdent]
      var basesym : Sym
      var basecreate : Tree
      var baseobject : Oblit
      var basev : Tree
      var baseob : Oblit

      if base !== nil then
	var sy : Symbol
	basesym <- view base as Sym
	env.pass["class.removeSugar base is %s\n", {base.asString}]
	const theconsts <- env$root[2]
	if theconsts !== nil then
	  for i : Integer <- 0 while i <= theconsts.upperbound by i <- i + 1
	    const theconst <- theconsts[i]
	    if nameof theconst = "aconstdecl" then
	      const thesym <- view theconst[0] as Sym
	      if thesym$id == basesym$id then
		basev <- theconst[2]
		exit
	      end if
	    end if
	  end for
	end if
	if basev == nil then
	  sy <- env$rootst.Lookup[ln, basesym$id, false]
	  if sy == nil or sy$value == nil then
	    env.SemanticError[base$ln,
	      "Base %s is undefined.", {basesym$id.asString}]
	  else
	    basev <- view sy$value as Tree
	  end if
	end if
	if basev !== nil then
	  const createname <- OpName.Literal["create"]
	  env.pass["basev is %s\n", {basev.asString}]
	  if nameof basev = "anoblit" then
	    baseob <- view basev as Oblit
	    var index : Integer
	    basecreate, index <- baseob.findOp[createname, true, nil, 1]
	    baseobject <- view baseob.findInvocResult[createname, nil, 1] as Oblit
	  end if
	end if
      end if

      if baseobject == nil then
      	env.pass[" baseobject is nil\n", nil]
	instanceO <- oblit.create[ln,
	  sfname.copy[0],
	  sym.create[ln, instancename],	% name
	  decls,				% decls
	  ops]					% ops
      else
      	env.pass[" baseobject is %s\n", {baseobject.asString}]
	instanceO <- oblit.create[ln,
	  sfname.copy[0],
	  sym.create[ln, instancename],	% name
	  nil,					% decls
	  nil]					% ops
	instanceO$decls <- 
	  self.inherit[baseobject$decls, decls, 0]
	instanceO$ops <- 
	  self.inherit[baseobject$ops, ops, 2]
      end if
      instanceO$f <- f

%     env$stdout.putstring["Before removing sugar of the instanceO\n"]
%     instanceO.print[env$stdout, 0]
      instanceO <- instanceO.removeSugar[nil]
%     env$stdout.putstring["After removing sugar of the instanceO\n"]
%     instanceO.print[env$stdout, 0]

      tdecls <- sseq.create[ln]
%      if baseobject !== nil then
%	tdecls.rcons[constdecl.create[ln, 
%	  sym.create[ln, basesym$id],	% id
%	  nil,				% type
%	  sym.create[ln, classident]	% value
%	]]
%      end if
      instanceType <- instanceO.getAT
      tdecls.rcons[constdecl.create[ln, typenamedef, nil, instanceType]]
      if creators !== nil then
	tdecls.rappend[creators[0]]
      end if
      if baseob !== nil then
	tdecls <- self.inherit[baseob$decls, tdecls, 1]
      end if
      tops <- seq.create[ln]
      tops.rcons[nil]
      tops.rcons[nil]
      tops.rcons[nil]
      tops.rcons[sugar.doAnOp[Opname.literal["getsignature"], nil, builtinLit.create[ln, 9], nil, typenameref, true]]
      % we need to add in the parent class's params
      if basecreate == nil then
	createparams <- params
      else
	const bcod <- view basecreate as opDef
	const bcos <- view bcod$sig as OpSig
	const bcp  <- bcos$params
	if bcp == nil then
	  createparams <- params
	else
	  createparams <- bcp.copy[0]
	  if params !== nil then createparams.rappend[params] end if
	end if
      end if
      resultid <- newid.newid
      resultdef <- sym.create[ln, resultid]
      resultref <- sym.create[ln, resultid]
      p <- param.create[ln, resultdef, typenameref.copy[0]]
      p <- seq.singleton[p]
      createopsig  <- opsig.create[ln, opname.literal["create"], createparams, p, nil]
      
      p <- assignstat.create[ln, seq.singleton[resultref], seq.singleton[instanceO] ]
      p <- sseq.singleton[p]
      p <- block.create[ln, p, nil, nil]
      createopdef  <- opdef.create[ln, createopsig, p]
      createopdef$isExported <- true
      tops.rcons[createopdef]
      if creators !== nil then
	tops.rappend[creators[1]]
      end if
      if baseob !== nil then
	tops <- self.inherit[baseob$ops, tops, 2]
      end if
      const theType <-
	oblit.create[ln, sfname.copy[0], name, tdecls, tops]
      theType$isImmutable <- true
      r <- theType
      if bid !== nil then
	theType.setBuiltinID[Literal.StringL[0, bid.asString]]
	instanceO.setBuiltinID[Literal.StringL[0, (bid + 0x400).asString]]
	(view instanceType as ATLit).setBuiltinID[Literal.StringL[0, (bid + 0x600).asString]]
      end if
    end iRemoveSugar

  export operation removeSugar [ob : Tree] -> [r : Tree]
    if ob == nil or base == nil then 
      r <- self.iRemoveSugar
      r <- r.removeSugar[ob]
    else
      const oldbase <- base
      base <- nil
      value <- self.iRemoveSugar
      base <- oldbase
      r <- self
    end if
  end removeSugar

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest
  export operation execute -> [r : Tree]
    r <- value
  end execute
  export operation defineSymbols[thest : SymbolTable]
    assert value !== nil
    value.defineSymbols[thest]
  end defineSymbols
  export operation resolveSymbols[thest : SymbolTable, nexp : Integer]
    assert value !== nil
    value.resolveSymbols[thest, nexp]
  end resolveSymbols
  export operation findManifests -> [changed : Boolean]
    assert value !== nil
    changed <- value.findManifests
  end findManifests
  export operation evaluateManifests
    assert value !== nil
    value.evaluateManifests
  end evaluateManifests
  export operation assignTypes
    assert value !== nil
    value.assignTypes
  end assignTypes
  export operation typeCheck
    assert value !== nil
    value.typeCheck
  end typeCheck
  export operation getAT -> [r : Tree]
    assert value !== nil
    r <- value.getAT
  end getAT
  export operation getCT -> [r : Tree]
    assert value !== nil
    r <- value.getCT
  end getCT
  export operation findThingsToGenerate[q : Any]
    assert value !== nil
    value.findThingsToGenerate[q]
  end findThingsToGenerate
  export operation generate[ct : Printable]
    assert value !== nil
    value.generate[ct]
  end generate

  export function asString -> [r : String]
    r <- "xclass"
  end asString
end Xclass
