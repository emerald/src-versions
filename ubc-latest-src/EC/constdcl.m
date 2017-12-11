export Constdecl

const constdecl <- class Constdecl (Tree) [xxsymb : Tree, xxtype : Tree, xxvalue : Tree]
    const ln : Integer <- xxsymb$ln
% If doing move/visit
    field isAttached : Boolean <- false
    field xsym : Tree <- xxsymb
    field xtype : Tree <- xxtype
    field value  : Tree <- xxvalue
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- xsym
      elseif i = 1 then
	r <- xtype
      elseif i = 2 then
	r <- value
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	xsym <- r
      elseif i = 1 then
	xtype <- r
      elseif i = 2 then
	value <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsymb, nxtype, nvalue : Tree
      if xsym !== nil then nsymb <- xsym.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      if value !== nil then nvalue <- value.copy[i] end if
      r <- constdecl.create[ln, nsymb, nxtype, nvalue]
      (view r as Attachable)$isAttached <- isAttached
    end copy
    operation iDefineSymbols [st : SymbolTable] -> [xxx : Symbol]
      const id <- (view xsym as hasIdent)$id
% If doing move/visit
      xxx <- st.Define[ln, id, SConst, isAttached]
% else
%     xxx <- st.Define[ln, id, SConst, false]

      if xxx !== nil then
	const n <- nameof value
	if n = "anoblit" or n = "anatlit" then
	  xxx$value <- value
	end if
      end if
    end iDefineSymbols
    export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
      xsym.resolveSymbols[pst, 0]
      if xtype !== nil then xtype.resolveSymbols[pst, 1] end if
      value.resolveSymbols[pst, 1]
    end resolveSymbols

  export operation getIsNotManifest -> [r : Boolean]
    r <- self$xsym$isNotManifest
  end getIsNotManifest

  export operation assignTypes 
    var thetype : Tree
    if self$xtype !== nil then
      if self$xtype$isNotManifest then
	Environment$env.SemanticError[self$ln,
	  "Type of the constant \"%s\" must be manifest",
	  {(view self$xsym as hasIdent)$id.asString}]
	thetype <- self$value.getAT
      else
	thetype <- self$xtype.execute.asType
      end if
    else
      thetype <- self$value.getAT
    end if
    if thetype == nil then
      const env <- Environment$env
      if env$traceassigntypes then
	env.printf["Couldn't find a type for const %S on line %d\n",
	  { (view xsym as Sym)$mysym$myident, self$ln}]
      end if
      if self$xtype == nil then
	if env$dotypecheck then
	  env.Warning[ln, "Can't figure out the type of the constant %S",
	    { (view xsym as Sym)$mysym$myident }]
	end if
      else
	env.SemanticError[ln, "Non type in constant declaration", nil]
      end if
    end if
    (view self$xsym as Sym)$mysym$ATinfo <- thetype
    FTree.assignTypes[self]
  end assignTypes

  export operation typeCheck
    if self$xtype !== nil then
      const rexp <- self$value
      const rtype <- view rexp.getAT as hasConforms
      const lsym <- (view self$xsym as Sym)$mysym
      const ltype  <- view lsym$ATInfo as Tree
      if ltype == nil then
	const env <- Environment$env
	if env$tracetypeCheck then 
	  env.printf["const.typeCheck on %d: type of id (%s) is nil\n", 
	    { self$ln, lsym.asString }]
	end if
      elseif rtype == nil then
	const env <- Environment$env
	if env$tracetypecheck then
	  env.printf["const.typeCheck on %d: type of value (%s) is nil\n", 
	    { self$ln, rexp.asString }]
	end if
      elseif ! rtype.conformsTo[self$ln, ltype] then
	Environment$env.SemanticError[self$ln, "The initializer type doesn't conform to that declared for the constant", nil]
      end if
    end if
    FTree.typeCheck[self]
  end typeCheck

  export operation findThingsToGenerate [q : Any]
    const s <- view self$xsym as Sym
    if s$mysym$value !== nil then
      const t <- view s$mysym$value as Tree
      t.findThingsToGenerate[q]
    else
      FTree.findThingsToGenerate[q, self]
    end if
  end findThingsToGenerate

  export operation generate [ct : Printable]
    if xsym$isNotManifest then
      const bc <- view ct as ByteCode
      const xsymassym <- view xsym as sym
      const s <- xsymassym$mysym
%      Environment$env.pass["const.generate: sym %s size %d\n", 
%	{s.asString, s$size}]
      bc.lineNumber[self$ln]
      bc.pushSize[s$size]
      self$value.generate[ct]
      xsymassym.generateLValue[ct]
      bc.popSize
    end if
  end generate

  export operation findManifests -> [changed : Boolean]
    changed <- false
    if ! self$xsym$isNotManifest then
      if self$value$IsNotManifest then
	self$xsym$isNotManifest <- true
	changed <- true
      end if
    end if
    changed <- FTree.findManifests[self] | changed
  end findManifests

  export operation evaluateManifests
    if ! self$xsym$isNotManifest then
      const t <- view self$xsym as Sym
      assert ! self$value$IsNotManifest
      if t$mysym$value == nil then
	const v <- self$value.execute
	if v == nil then
	  const env <- Environment.getEnv
	  env.pass["Need another pass for \"%s\"\n", {self$value.asString}]
	  env$needMoreEvaluateManifest <- true
	else
	  t$mysym$value <- v
	end if
      end if
    end if
    FTree.evaluateManifests[self]
  end evaluateManifests

  export operation defineSymbols [st : SymbolTable]
    const foo <- self.iDefineSymbols[st]
    FTree.defineSymbols[st, self]
  end defineSymbols

  export function same [o : Tree] -> [r : Boolean]
    r <- false
    if nameof o = "aconstdecl" then
      r <- self$xsym.same[(view o as ConstDecl)$xsym]
    end if
  end same

  export function asString -> [r : String]
    r <- "constdecl"
  end asString
end Constdecl
