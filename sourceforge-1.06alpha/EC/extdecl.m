export Extdecl

const Extdecl <- class Extdecl (Tree) [xxsymb : Tree, xxtype : Tree]
    const ln : Integer <- xxsymb$ln
    
    field xsym : Tree <- xxsymb
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
      var nsymb, nxtype : Tree
      if xsym !== nil then nsymb <- xsym.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      r <- extdecl.create[ln, nsymb, nxtype]
    end copy
    operation iDefineSymbols [st : SymbolTable] -> [xxx : Symbol]
      const id <- (view xsym as hasIdent)$id

      if Environment$env$externaldirectory == nil then
	Environment$env.SemanticError[ln, "Can't define external symbols without an external directory", nil]
      else
	xxx <- st.Define[ln, id, SExternal, false]
	if xxx !== nil then
	  xxx$isNotManifest <- true
	  xxx$size <- 8
	end if
      end if
    end iDefineSymbols
    export operation resolveSymbols [pst : SymbolTable, nexp : Integer]
      xsym.resolveSymbols[pst, nexp]
      if xtype !== nil then xtype.resolveSymbols[pst, 1] end if
    end resolveSymbols

  export operation getIsNotManifest -> [r : Boolean]
    r <- true
  end getIsNotManifest

  export operation assignTypes 
    var thetype : Tree
    if self$xtype$isNotManifest then
      Environment$env.SemanticError[self$ln,
	"Type of the external symbol \"%s\" must be manifest",
	{(view self$xsym as hasIdent)$id.asString}]
    else
      thetype <- self$xtype.execute.asType
    end if
    if thetype == nil then
      Environment$env.tassignTypes["Couldn't find a type for external symbol %s on line %d\n",
        { self$xsym.asString, self$ln}]
      Environment$env.SemanticError[ln, "Non type in external declaration", nil]
    end if
    (view self$xsym as Sym)$mysym$ATinfo <- thetype
    FTree.assignTypes[self]
  end assignTypes

  export operation defineSymbols [st : SymbolTable]
    const foo <- self.iDefineSymbols[st]
    FTree.defineSymbols[st, self]
  end defineSymbols

  export operation generate [ct : Printable]
  end generate

  export function same [o : Tree] -> [r : Boolean]
    r <- false
    if nameof o = "anextdecl" then
      r <- self$xsym.same[(view o as Extdecl)$xsym]
    end if
  end same

  export function asString -> [r : String]
    r <- "extdecl"
  end asString
end Extdecl
