export Vardecl

const vardecl <- class Vardecl (Tree) [xxsym : Tree, xxtype : Tree, xxvalue : Tree]
    const ln : Integer <- xxsym$ln
% If doing move/visit
    field isAttached : Boolean <- false
    field xsym : Tree <- xxsym
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
      var nxsym, nxtype, nvalue : Tree
      if xsym !== nil then nxsym <- xsym.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      if value !== nil then nvalue <- value.copy[i] end if
      r <- vardecl.create[ln, nxsym, nxtype, nvalue]
      (view r as Attachable)$isAttached <- isAttached
    end copy
    operation iDefineSymbols [st : SymbolTable]
      const id <- (view xsym as hasIdent)$id
% If doing move/visit
      const xxx <- st.Define[ln, id, SVar, isAttached]
% else
%     const xxx <- st.Define[ln, id, SVar, false]
    end iDefineSymbols
    export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
      xsym.resolveSymbols[pst, 0]
      xtype.resolveSymbols[pst, 1]
      if value !== nil then value.resolveSymbols[pst, 1] end if
    end resolveSymbols

  export operation assignTypes 
    var thetype : Tree
    const env <- Environment$env
    if self$xtype$isNotManifest then
      env.SemanticError[self$ln,
	"Type of the variable \"%s\" must be manifest",
	{(view self$xsym as hasIdent)$id.asString}]
    else
      theType <- self$xtype
      if env$traceassignTypes then env.printf["Type is %S on line %d\n", { theType, self$ln }] end if
      theType <- theType.execute
      if env$traceassignTypes then env.printf["  type.execute is %S\n", { theType }] end if
      theType <- theType.asType
      if env$traceassignTypes then env.printf["  type.execute.asType is %S\n", { theType }] end if
    end if
    if thetype == nil then
      if env$traceassignTypes then
	env.printf["Couldn't find a type for var %s on line %d\n",
	  { self$xsym.asString, self$ln}]
      end if
      env.SemanticError[ln, "Non type in variable declaration", nil]
    end if
    (view self$xsym as Sym)$mysym$ATinfo <- thetype
    FTree.assignTypes[self]
  end assignTypes

  export operation typeCheck
    if self$value !== nil then
      const rexp <- self$value
      const rtype <- view rexp.getAT as hasConforms
      const lsym <- (view self$xsym as Sym)$mysym
      const ltype  <- view lsym$ATInfo as Tree
      if ltype == nil then
	Environment$env.ttypeCheck["var.typeCheck on %d: type of id (%s) is nil\n", 
	  { self$ln, lsym.asString }]
      elseif rtype == nil then
	Environment$env.ttypeCheck["var.typeCheck on %d: type of value (%s) is nil\n", 
	  { self$ln, rexp.asString }]
      elseif ! rtype.conformsTo[self$ln, ltype] then
	Environment$env.SemanticError[self$ln, "The initializer type doesn't conform to that declared for the variable", nil]
      end if
    end if
    FTree.typeCheck[self]
  end typeCheck

  export operation generate [ct : Printable]
    const s <- view self$xsym as Sym
    const bc <- view ct as ByteCode

    if self$value !== nil or bc.fetchNest !== nil then
      const size : Integer <- s$mysym$size
      bc.pushSize[size]
      if self$value == nil then
	bc.lineNumber[self$ln]
	if size == 4 then
	  bc.addCode["PUSHNIL"]
	else
	  bc.addCode["PUSHNILV"]
	end if
      else
	bc.lineNumber[self$value$ln]
	self$value.generate[ct]
      end if
      s.generateLValue[ct]
      bc.popSize
    end if
  end generate

  export operation findManifests -> [changed : Boolean]
    changed <- false
    if ! self$xsym$isNotManifest then
      self$xsym$isNotManifest <- true
      changed <- true
    end if
    changed <- FTree.findManifests[self] | changed
  end findManifests

  export operation defineSymbols [st : SymbolTable]
    self.iDefineSymbols[st]
    FTree.defineSymbols[st, self]
  end defineSymbols

  export function same [o : Tree] -> [r : Boolean]
    r <- false
    if nameof o = "avardecl" then
      r <- self$xsym.same[(view o as VarDecl)$xsym]
    end if
  end same

  export function asString -> [r : String]
    r <- "vardecl"
  end asString
end Vardecl
