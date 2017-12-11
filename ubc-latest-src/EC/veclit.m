export Vectorlit

const AConcreteType <- immutable object AConcreteType
  const ctat <- typeobject ctat
    function  fetchIndex -> [Integer]
    operation getIndex [Integer, CPQueue]
    operation CPoint [OutStream]
  end ctat
  export function getSignature -> [r : Signature]
    r <- ctat
  end getSignature
  export operation create [id : Integer] -> [r : ctat]
    r <- object aCTRef
	const obj <- "-OB-"
	var myind : Integer <- ~1
	var myq : CPQueue

	export function fetchIndex -> [r : Integer]
	  r <- myind
	end fetchIndex

	export operation getIndex [start : Integer, q : CPQueue]
	  if myq !== q then
	    myq <- q
	    q.addUpper[self]
	    myind <- q.upperbound
	  end if
	end getIndex

	export operation CPoint [file : OutStream]
	  file.putString[obj]
	  OIDWriter.Out[id, file]
	end CPoint
    end aCTRef
  end create
end AConcreteType

const vectorlit <- class Vectorlit (OTree) [xxtype : Tree, xxexp : Tree, xxvectorType : Tree]
    field id : Integer
    field kind : Integer
    field codeOID : Integer
    field xtype : Tree <- xxtype
    field exp : Tree <- xxexp
    field vectorType : Tree <- xxvectorType
    field instanceType : Tree
    field cpct : CPAble
    field myind : Integer
    field myq   : CPQueue
    field elementsize : Integer
    const obj <- "+OB+"

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex

    export operation getIndex [start : Integer, q : CPQueue]
      if myq !== q then
	q.addUpper[self]
	myind <- q.upperbound
	cpct.getIndex[start, q]
      end if
    end getIndex

    export operation cpoint [file : OutStream]
      var length : Integer <- exp.upperbound + 1
      var rest, value, i :   Integer
      var size :   Integer <- elementsize * length
      var s : String
      var e : Tree

      if elementsize = 1 then
	rest <- 4 - (length # 4)
	if rest = 4 then rest <- 0 end if
	size <- size + rest
      else
	rest <- 0
      end if
      file.putString[obj]
      file.writeInt[16 + 4 + size, 4]
      OIDWriter.Out[id, file]
      file.writeInt[0x40000000 + cpct.fetchIndex, 4]
      file.writeInt[length, 4]

      % write the elements
      i <- 0
      loop
	exit when i > exp.upperbound
	e <- exp[i]
	s <- nameof e
	if s = "asym" then
	  const val <- view (view e as Sym)$mysym$value as Tree
	  e <- val
	end if
	s <- (view e as hasStr)$str

	if kind = 6 then 			% Integer
	  value <- Integer.literal[s]
	elseif kind = 4 then			% Character
	  value <- s[0].ord
	else
	  assert false
	end if
	file.writeInt[value, elementsize]
	i <- i + 1
      end loop

      % pad it out
      loop
	exit when rest == 0
	file.putchar['*']
	rest <- rest - 1
      end loop
    end cpoint

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- xtype
      elseif i = 1 then
	r <- exp
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	xtype <- r
      elseif i = 1 then
	exp <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nxtype, nexp, nvectortype : Tree
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      if exp !== nil then nexp <- exp.copy[i] end if
%      if vectortype !== nil then nvectortype <- vectortype.copy[i] end if
      r <- vectorlit.create[ln, nxtype, nexp, nil]
    end copy

  export operation flatten [ininvoke : Boolean, indecls : Tree] -> [r : Tree, decls : Tree]
    exp, decls <- exp.flatten[true, indecls]
    if ininvoke then
      const sid <- newid.newid
      const asym : Sym <- sym.create[self$ln, sid]
      const c : constdecl <- constdecl.create[self$ln, asym, nil, self]
      if decls == nil then 
	decls <- seq.singleton[c]
      else
	decls.rcons[c]
      end if
      r <- sym.create[self$ln, sid]
    else
      r <- self
    end if
  end flatten

    export operation typeCheck 
      assert vectorType !== nil
      vectorType.typeCheck
      FTree.typecheck[self]
    end typeCheck

    operation figureMyType
      if vectortype == nil then
	const env : EnvironmentType <- Environment$env
	var thetype : Tree
	if xtype == nil then
	  for i : Integer <- 0 while i <= exp.upperbound by i <- i + 1
	    var e : Tree <- exp[i]
	    var s : String <- nameof e
	    if s = "asym" then
	      const val <- view (view e as Sym)$mysym$value as Tree
	      if val !== nil then
		s <- nameof val
		e <- val
	      end if
	    end if
	    if s = "aliteral" then
	      const asLiteral <- view e as Literal
	      const index : Integer <- asLiteral$index
	      if kind == nil then kind <- index elseif kind != index then kind <- 1 end if
	    else
	      kind <- 1
	    end if
	  end for
	  xtype <- builtinlit.create[ln, kind].asType
	  elementsize <- IDS.IDToSize[0x1600 + kind]
	  if ! env$executenow and (kind == 6 or kind == 4) then id <- nextOID.nextOID end if
	  thetype <- xtype
	else
	  thetype <- xtype.execute.asType
	  elementsize <- (view thetype as hasVariableSize).variableSize
	end if
	const xtypename <- nameof thetype
	var xtypeid : Integer <- 0
	if xtypename = "anatlit" or xtypename = "aglobalref" or xtypename = "abuiltinlit" then
	  xtypeid <- (view thetype as hasIDs)$id
	end if
	if xtypeid = 0x1606 then
	  const ivofintid <- env$ITable.Lookup["immutablevectorofint", 999]
	  const ivofint <- view env$rootst.Lookup[ln, ivofintid, false]$value as Tree
	  vectorType <- ivofint
	elseif xtypeid = 0x1601 then
	  const ivofanyid <- env$ITable.Lookup["immutablevectorofany", 999]
	  const ivofany <- view env$rootst.Lookup[ln, ivofanyid, false]$value as Tree
	  vectorType <- ivofany
	else
	  const ivid <- env$ITable.Lookup["immutablevector", 999]
	  const iv <- view env$rootst.Lookup[ln, ivid, false]$value as Tree
	  const opn <- opname.literal["of"]
	  const args <- seq.singleton[xtype]
	  const inv <- invoc.create[ln, iv, opn, args]
	  vectorType <- inv.execute
	  vectorType.evaluateManifests
	  vectorType.assignTypes
	end if
	instanceType <- (view vectorType as hasInstCT)$instCT
      end if
    end figureMyType

    export operation getAT -> [r : Tree]
      const xx <- view vectorType as hasInstAT
      if xx == nil then
	Environment$env.printf["Vectorlit.getAT: vectorType is nil\n", nil]
      else
	r <- xx.getInstAT
	if r == nil then
	  Environment$env.printf["Vectorlit.getAT: vectorType.getInstAT is nil\n", nil]
	end if
      end if
    end getAT
    initially
      f <- f.setBit[xisnotmanifest, true]
      if exp == nil then
	exp <- seq.create[ln]
      end if
    end initially

  export operation findThingsToGenerate[q : Any]
    self$vectorType.findThingsToGenerate[q]
    self$exp.findThingsToGenerate[q]
  end findThingsToGenerate

  export operation generate [xct : Printable]
    const instanceOB <- view self$instanceType as hasIDs
    const bc <- view xct as ByteCode

    if self$id !== nil then
      self$cpct <- AConcreteType.create[instanceOB$codeOID]
      bc.fetchLiteral[self$id]
      bc.finishExpr[4, instanceOB$codeOID, (view self.getAT as hasid)$id]
      bc.addOther[self]
    else
      var size : Integer <- self$elementsize
      if size == 1 then size <- 4 end if
      const totalsize <- size * (exp.upperbound + 1)
      if ~128 <= totalsize and totalsize <= 127 then
	bc.addCode["LDIB"]
	bc.addValue[totalsize, 1]
      elseif ~32768 <= totalsize and totalsize <= 32767 then
	bc.addCode["LDIS"]
	bc.addValue[totalsize, 2]
      else 
	bc.addCode["LDI"]
	bc.addValue[totalsize, 4]
      end if
      bc.addCode["ENSURESPACE"]
      bc.pushSize[size]
      for i : Integer <- 0 while i <= exp.upperbound by i <- i + 1
	const e <- exp[i]
	e.generate[xct]
      end for
      bc.popSize
      bc.fetchLiteral[instanceOB$codeOID]
      begin
	var val : Integer <- exp.upperbound + 1
	if ~128 <= val and val <= 127 then
	  bc.addCode["LDIB"]
	  bc.addValue[val, 1]
	elseif ~32768 <= val and val <= 32767 then
	  bc.addCode["LDIS"]
	  bc.addValue[val, 2]
	else 
	  bc.addCode["LDI"]
	  bc.addValue[val, 4]
	end if
      end
      bc.addCode["CREATEVECLIT"]
      bc.finishExpr[4, instanceOB$codeOID, (view self.getAT as hasid)$id]
    end if
  end generate

  export operation evaluateManifests
    self.figureMyType
    ftree.evaluateManifests[self]
  end evaluateManifests

  export operation print[s : OutStream, indent : Integer]
    ftree.print[s, indent, self]
    for i : Integer <- 0 while i < indent + 2 by i <- i + 1
      s.putchar[' ']
    end for
    s.putstring["vt: "]
    if vectorType == nil then
      s.putstring["nil\n"]
    else
      vectorType.print[s, indent+2]
    end if
  end print

  export function asString -> [r : String]
    r <- "vectorlit"
  end asString
end Vectorlit
