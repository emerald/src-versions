
export Wherewidgit, OP_WHERE, OP_SUCHTHAT, OP_FORALL

const OP_WHERE <- 1
const OP_SUCHTHAT <- 2
const OP_FORALL <- 3

const wherewidgit <- class Wherewidgit (Tree) [xxsym : Tree, xxop : Integer, xxtype : Tree]
    field xsym : Tree <- xxsym
    field xop : Integer <- xxop
    field xtype  : Tree <- xxtype
    var st : SymbolTable <- nil

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
      var nsym, nxtype : Tree
      if xsym !== nil then nsym <- xsym.copy[i] end if
      if xop != OP_FORALL then
	if xtype !== nil then nxtype <- xtype.copy[i] end if
      end if
      r <- wherewidgit.create[ln, nsym, xop, nxtype]
    end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    if xop == OP_FORALL and self$xtype == nil then
      const tcopy   <- 
	atlit.create[
	  self$ln, 
	  Literal.StringL[0, "junk"],
	  sym.create[self$ln,
	    Environment$Env$ITable.Lookup["whocares", 999]], 
	  seq.create[self$ln]
	]
      self$xtype <- tcopy
    end if
    r <- FTree.removeSugar[self, ob]
  end removeSugar

  export operation defineSymbols [thest : SymbolTable]
    const x <- view self$xsym as Sym
    var s : Symbol
    st <- thest
%
% This should be 
%   if xop == OP_FORALL or xop == OP_WHERE then
% but currently we have foralls where we shouldn't need them in unconstrained
% type parameters like in Vector, Array, and such.
    if xop == OP_WHERE then
      s <- thest.Define[ln, x$id, SConst, false]
    elseif xop == OP_FORALL then
      s <- thest.Lookup[ln, x$id, false]
      if s == nil then
	s <- thest.Define[ln, x$id, SConst, false]
      end if
    end if
    FTree.defineSymbols[thest, self]
  end defineSymbols

  export operation resolveSymbols [thest : SymbolTable, nexp : Integer]
    var sy : Symbol

    self$xsym.resolveSymbols[thest, 0]
    if self$xtype !== nil then
      self$xtype.resolveSymbols[thest, 1]
    end if

    sy <- (view self$xsym as Sym)$mysym
    if xop == OP_FORALL or xop == OP_SUCHTHAT then
      sy$isTypeVariable <- true
      if xop == OP_SUCHTHAT then
	sy$willHaveConstraint <- true
      end if
    end if
  end resolveSymbols

  export operation getNeedsToBeCompilerExecuted -> [r : Boolean]
    r <- false % xop = OP_FORALL or xop = OP_SUCHTHAT
  end getNeedsToBeCompilerExecuted

  export operation evaluateManifests
    const env <- Environment$env
    const thesym : Sym <- view self$xsym as Sym
    const thesymbol <- thesym$mysym
    if xop = OP_FORALL and theSymbol$value == nil and !thesymbol$willHaveConstraint then
      const u <- view self$xtype as OTree
      assert ! thesym$isNotManifest
      if env$traceevaluatemanifests then
	env.printf["  Setting the value of the forall on line %d\n", {ln}]
      end if
      u$isTypeVariable <- true
      theSymbol$value <- u
    elseif xop = OP_SUCHTHAT and theSymbol$value == nil then
      if thesymbol$hasConstraint then
	Environment$env.SemanticError[ln, "Symbol %S already has a constraint", { thesymbol$myident } ]
      end if
      const t <- self$xtype.execute
      const thecopy <- view t.copy[0] as OTree
      thecopy.defineSymbols[st]
      thecopy.resolveSymbols[st, 1]
      loop
	exit when !thecopy.findManifests
      end loop
      thecopy.evaluateManifests
      assert ! thesym$isNotManifest
      if env$traceevaluatemanifests then
	env.printf["  Setting the value of the such that on line %d\n", {ln}]
      end if
      thecopy$isTypeVariable <- true
      thesymbol$hasConstraint <- true
      theSymbol$value <- thecopy
    elseif xop = OP_WHERE then
      if thesym$isNotManifest then
	if env$traceevaluatemanifests then
	  env.printf["  The where on line %d is not manifest\n", {ln}]
	end if
      else
	assert ! self$xtype$IsNotManifest
	if env$traceevaluatemanifests then
	  env.printf["  Setting the value of the where on line %d\n", {ln}]
	end if
	if theSymbol$value == nil then
	  theSymbol$value <- self$xtype.execute
	  if theSymbol$value == nil then
	    if env$traceevaluatemanifests then
	      env.printf["  Setting the value of the where on line %d failed\n", {ln}]
	    end if
	  end if
	end if
      end if
    end if
    if xop = OP_SUCHTHAT then
      (view theSymbol$value as Tree).evaluateManifests
    end if
    % st <- nil
    FTree.evaluateManifests[self]
  end evaluateManifests

  export operation assignTypes
    const ssym <- view self$xsym as Sym
    const value <- view ssym$mysym$value as Tree
    if value !== nil then
      value.assignTypes
    end if
    FTree.assignTypes[self]
  end assignTypes
      
    
  export operation findManifests -> [changed : Boolean]
    changed <- false
    if xop = OP_WHERE then
      if ! self$xsym$isNotManifest and self$xtype$IsNotManifest then
	self$xsym$isNotManifest <- true
	changed <- true
      end if
    end if

    changed <- FTree.findManifests[self] | changed
  end findManifests

  export function asString -> [r : String]
    r <- "wherewidgit"
  end asString
end Wherewidgit
