export acceptstat

const acceptstat <- class acceptstat (Tree) [xxtype : Tree]
  field xtype     : Tree <- xxtype

  export function upperbound -> [r : Integer]
    r <- 0
  end upperbound
  export function getElement [i : Integer] -> [r : Tree]
    if i == 0 then
      r <- xtype
    end if
  end getElement
  export operation setElement [i : Integer, r : Tree]
    if i = 0 then
      xtype <- r
    end if
  end setElement
  export operation copy [i : Integer] -> [r : Tree]
    var nxtype : Tree
    if xtype !== nil then nxtype <- xtype.copy[i] end if
    r <- acceptstat.create[ln, nxtype]
  end copy

  export operation removeSugar [ob : Tree] -> [r : Tree]
    const realob <- view ob as Monitorable
    if realob$isMonitored then
      Environment.getEnv.SemanticError[ln, "Accept statements are not allowed in monitored objects", nil]
    end if
    realob$isSynchronized <- true
    r <- FTree.removeSugar[self, ob]
  end removeSugar

  export operation assignTypes
    const env : EnvironmentType <- Environment$env
    var theType : Tree
    if xtype$isNotManifest then
      env.SemanticError[self$ln,
	"The type in accept statements must be manifest", nil]
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
	env.printf["Couldn't find a type in accept statement on line %d\n",
	  { self$ln}]
      end if
      env.SemanticError[ln, "Non type in accept statement", nil]
    end if
    FTree.assignTypes[self]
  end assignTypes

  export operation generate [ xct : Printable ]
    const bc <- view xct as ByteCode
    const nb <- bc.nestBase
 
    bc.pushSize[4]
    xtype.execute.asType.generate[bc]
    bc.popSize

    bc.addCode["ACPTBLCK"]
  end generate

  export function asString -> [r : String]
    r <- "acceptstat"
  end asString
end acceptstat
