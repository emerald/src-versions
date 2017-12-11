export Xview

const xview <- class Xview (Tree) [xxexp : Tree, xxtype : Tree]
    field isRedundant : Boolean <- false
    field exp : Tree <- xxexp
    field xtype : Tree <- xxtype

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- exp
      elseif i = 1 then
	r <- xtype
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	exp <- r
      elseif i = 1 then
	xtype <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nexp, nxtype : Tree
      if exp !== nil then nexp <- exp.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      r <- xview.create[ln, nexp, nxtype]
    end copy

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, outdecls : Tree]
    exp, outdecls <- exp.flatten[true, indecls]
    xtype, outdecls <- xtype.flatten[true, outdecls]
    if ininvoke then
      const id <- newid.newid
      const asym : Sym <- sym.create[self$ln, id]
      const c : constdecl <- constdecl.create[self$ln, asym, nil, self]
      if outdecls == nil then 
	outdecls <- seq.singleton[c]
      else
	outdecls.rcons[c]
      end if
      r <- sym.create[self$ln, id]
    else
      r <- self
    end if
  end flatten

  export operation assignTypes
    const env : EnvironmentType <- Environment$env
    var theType : Tree
    if self$xtype$isNotManifest then
      env.SemanticError[self$ln,
	"Type of view expressions must be manifest", nil]
    else
      theType <- self$xtype
      if env$traceassignTypes then env.printf["Type is %S on line %d\n", { theType, self$ln }] end if
      theType <- theType.execute
      if env$traceassignTypes then env.printf["  type.execute is %S\n", { theType }] end if
      if theType !== nil then
	theType <- theType.asType
	if env$traceassignTypes then env.printf["  type.execute.asType is %S\n", { theType }] end if
      end if
    end if
    if thetype == nil then
      if env$traceassignTypes then
	env.printf["Couldn't find a type in view expression on line %d\n",
	  { self$ln}]
      end if
      env.SemanticError[ln, "Non type in view expression", nil]
    end if
    FTree.assignTypes[self]
  end assignTypes

  export operation getAT -> [r : Tree]
    r <- self$xtype.execute
    if r !== nil then r <- r.asType end if
  end getAT

  export operation generate [xct : Printable]
    const env : EnvironmentType <- Environment$env
    if env$generateViewChecking then
      const bc <- view xct as ByteCode
      bc.pushSize[8]
      exp.generate[bc]
      bc.popSize
      bc.pushSize[4]
      xtype.execute.asType.generate[bc]
      bc.popSize
      bc.addCode["VIEW"]
      if bc$size != 8 then
	bc.addCode["POOP"]
      end if
    else
      self$exp.generate[xct]
    end if
  end generate

  export function asString -> [r : String]
    r <- "xview"
  end asString
end Xview
