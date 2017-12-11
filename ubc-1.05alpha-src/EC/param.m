
export Param

const param <- class Param (Tree) [xxsym : Tree, xxtype : Tree]
% IF doing move/visit
%    field isMove : Boolean <- false
%    field isVisit : Boolean <- false
    field isAttached : Boolean <- false
    field xsym : Tree <- xxsym
    field xtype : Tree <- xxtype

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- xsym
      elseif i = 1 then
	r <- xtype
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	xsym <- r
      elseif i = 1 then
	xtype <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nxsym, nxtype : Tree
      if xsym !== nil then nxsym <- xsym.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      r <- param.create[ln, nxsym, nxtype]
      (view r as Attachable)$isAttached <- isAttached
    end copy
    operation iDefineSymbols [st : SymbolTable]
      const s <- view xsym as Sym
      const id : Ident <- (view xsym as hasIdent)$id
% If doing move/visit
      const xxx <- st.Define[ln, id, st$kind, isAttached]
%     xxx$isMove <- isMove
% else
%     const xxx <- st.Define[ln, id, st$kind, false]
      s$mysym <- xxx
    end iDefineSymbols


  export function asType -> [r : Tree]
    r <- view (view self$xsym as Sym)$mysym$ATinfo as Tree
    if r == nil then
      r <- self$xtype.execute
      if r !== nil then
	r <- r.asType
      end if
    end if
    if r == nil then
      const env : EnvironmentType <- Environment$env
      if env$traceassigntypes then
	env.printf["param %s on line %d asType -> nil\n", 
	  {self$xsym.asString, self$ln}]
      end if
    end if
  end asType

  export operation assignTypes 
    var thetype : Tree
    const env : EnvironmentType <- Environment$env
    if env$traceassigntypes then
      env.printf["param.assigntypes: %s on line %d\n",
	{ self$xsym.asString, self$ln}]
    end if
    if self$xtype$isNotManifest then
      env.SemanticError[self$ln,
	"Type of the parameter \"%s\" must be manifest",
	{(view self$xsym as hasIdent)$id.asString}]
    else
      thetype <- self$xtype.execute
      if thetype == nil then
	env.SemanticError[self$ln, 
	  "The type of the parameter \"%s\" is manifest, but execute fails",
	  {(view self$xsym as hasIdent)$id.asString}]
      else
	thetype <- thetype.asType
      end if
      if thetype == nil then
	env.pass["Couldn't find a type for param %s on line %d\n",
	  { self$xsym.asString, self$ln}]
	env.SemanticError[ln, "Non type in parameter declaration", nil]
      end if
    end if
    (view self$xsym as Sym)$mysym$ATinfo <- thetype
    FTree.assignTypes[self]
  end assignTypes

  export operation generate[xct : Printable]
    if xct.asString = "bytecode" then
      const bc <- view xct as ByteCode
      const s : Symbol <- (view self$xsym as Sym)$mysym
      assert s$ATinfo !== nil
      const r <- view s$ATinfo as hasID
      const id : Integer <- r$id
      const ctid : Integer <- IDS.IDToInstCTID[id]
      if s$mykind = SResult and ctid !== nil then
	bc.fetchVariableSecondThing[id + 0x200, id]
	assert s$base = 'A'
	const off : Integer <- s$offset - 4
	if ~128 <= off and off <= 127 then
	  bc.addCode["STAB"]
	  bc.addValue[off, 1]
	elseif ~32768 <= off and off <= 32767 then
	  bc.addCode["STAS"]
	  bc.addValue[off, 2]
	else
	  bc.addCode["STA"]
	  bc.addValue[off, 4]
	end if
      elseif s$mykind = SParam and ctid == nil and Environment$env$useAbCons then
	% Make sure the abcon is right.
	assert s$base = 'A'
	const off : Integer <- s$offset / 8
	assert ~128 <= off and off <= 127
	bc.fetchLiteral[id]
	bc.addCode["CHECKARGABCONB"]
	bc.addValue[off, 1]
      end if
    end if
  end generate

  export operation findManifests -> [changed : Boolean]
    const s : Symbol <- (view self$xsym as Sym)$mysym
    changed <- false
    if ! s$isNotManifest and !s$isTypeVariable then
      s$isNotManifest <- true
      changed <- true
    end if
    changed <- FTree.findManifests[self] | changed
  end findManifests

  export operation defineSymbols [st : SymbolTable]
    self.iDefineSymbols[st]
    FTree.defineSymbols[st, self]
  end defineSymbols
  export function asString -> [r : String]
    r <- "param"
  end asString
end Param
