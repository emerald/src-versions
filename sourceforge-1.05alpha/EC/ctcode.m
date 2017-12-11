const Template <- class Template
    var s : String <- ""
    var t : String <- ""
    var finalString : String
    var lastBrand : Character <- nil
    var lastCount : Integer  <- 0
    var cs : CString

    operation flush
      if lastBrand !== nil and lastCount != 0 then
	if lastCount < 0 then
	  s <- s || "%*" || lastBrand.asString
	elseif lastCount = 1 then
	  s <- s || "%" || lastBrand.asString
	else
	  s <- s || "%" || lastCount.asString || lastBrand.asString
	end if
      end if
      lastCount <- 0
    end flush

    export operation isVector [whatBrand : Character]
      self.flush
      lastBrand <- whatBrand
      lastCount <- ~1
      t <- t || "data\0"
    end isVector

    export operation addOne [whatBrand : Character, name : String]
      if whatBrand != 'Z' then
	if lastBrand !== nil and lastBrand != whatBrand then self.flush end if
	lastBrand <- whatBrand
	lastCount <- lastCount + 1
      end if
      t <- t || name || "\0"
    end addOne

    export operation addLineNumbers[lineNumbers : String]
      self.flush
      t <- t || lineNumbers
    end addLineNumbers

    export function fetchIndex -> [r : Integer]
      if cs == nil then
	r <- nil
      else
	r <- cs.fetchIndex
      end if
    end fetchIndex

    operation finalize
      if finalString == nil then
	const env : EnvironmentType <- Environment$env
	const needDebugInfo <- env$generateDebugInfo and t != ""
	self.flush
	
	if lastBrand !== nil then
	  if needDebugInfo then
	    finalString <- s || "\0" || t
	  else
	    finalString <- s || "\0"
	  end if
	elseif needDebugInfo then
	  finalString <- "\0" || t
	end if
      end if
    end finalize

    export operation getIndex [start : Integer, q : CPQueue]
      if cs == nil then
	self.finalize
	if finalString !== nil then
	  cs <- CString.create
	  cs$s <- finalString
	  cs.getIndex[start, q]
	end if
      end if
    end getIndex

    export operation cpoint [file : OutStream]
      if cs !== nil then 
	cs.cpoint[file]
      end if
    end cpoint
    export operation getString -> [r : String]
      self.finalize
      r <- finalString
    end getString
end Template

export Template

const aoove <- Array.of[OpVectorE]

const OPVectorCT <- immutable object OPVectorCT
  const obj <- "-OB-"
  const OPVectorCTOID <- 0x1819
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export operation fetchIndex -> [r : Integer]
    r <- myind$myind
  end fetchIndex
  
  export operation getIndex [start : Integer, q : CPQueue]
    if myind$myq !== q then
      myind$myq <- q
      q.AddUpper[self]
      myind$myind <- q.upperbound
    end if
  end getIndex
  
  export operation CPoint [file : OutStream]
    file.putString[obj]
    OIDWriter.Out[OPVectorCTOID, file]
  end CPoint
end OPVectorCT

const OpVector <- class OpVector
    const obj <- "+OB-"

    field d	     : aoove <- aoove.create[~10]
    var myind : Integer <- ~1

    export function asString -> [s : String]
      s <- "opvector"
    end asString

    export operation addUpper[e : OpVectorE]
      d.addUpper[e]
    end addUpper
    
    export operation setElement[i : Integer, e : OpVectorE]
      d[i] <- e
    end setElement

    export function getElement[i : Integer] -> [r : OpVectorE]
      r <- d[i]
    end getElement

    export function upperbound -> [r : Integer]
      r <- d.upperbound
    end upperbound

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	OPVectorCT.getIndex[start, q]
	for i : Integer <- 0 while i <= d.upperbound by i <- i + 1
	  begin
	    const dd <- d[i]
	    if dd !== nil then
	      dd.getIndex[start, q]
	    end if
	  end 
	end for
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex
    
    export operation CPoint [file : OutStream]
      var x : Integer
      file.putString[obj]
      file.writeint[4 + 4 + (d.upperbound - d.lowerbound + 1) * 4, 4]
      file.writeInt[0x00000000 + OPVectorCT.fetchIndex, 4]
      x <- d.upperbound + 1
      file.writeInt[x, 4]
      for i : Integer <- 0 while i <= d.upperbound by i <- i + 1
	begin
	  const dd <- d[i]
	  if dd == nil then
	    x <- 0x80000000
	  else
	    x <- dd.fetchIndex
	  end if
	end 
	file.writeInt[x, 4]
      end for
    end CPoint

    export operation generateBuiltin -> [r : COpVector]
      const voove <- Vector.of[COpVectorE]
      var i : Integer <- 0
      const limit : Integer <- d.upperbound
      const myv <- voove.create[limit + 1]
      var dd : OpVectorE

      loop
	exit when i > limit
	dd <- d[i]
	if dd !== nil then
	  myv[i] <- dd.generateBuiltin
	end if
	i <- i + 1
      end loop
      r <- COpVector.literal[myv]
    end generateBuiltin

    initially
      d.addUpper[nil]		% initially
      d.addUpper[nil]		% process
      d.addUpper[nil]		% recovery
    end initially
end OpVector

export OpVector

const OPVectorECT <- immutable object OPVectorECT
  const obj <- "-OB-"
  const OPVectorECTOID <- 0x181a
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export operation fetchIndex -> [r : Integer]
    r <- myind$myind
  end fetchIndex
  
  export operation getIndex [start : Integer, q : CPQueue]
    if myind$myq  !== q then
      myind$myq <- q
      q.AddUpper[self]
      myind$myind <- q.upperbound
    end if
  end getIndex
  
  export operation CPoint [file : OutStream]
    file.putString[obj]
    OIDWriter.Out[OPVectorECTOID, file]
  end CPoint
end OPVectorECT

const OpVectorE <- class OpVectorE [xxname : String]
    const obj <- "+OB-"
    field name  : String <- xxname
    field id : Integer
    field nargs : Integer <- 0
    field nress : Integer <- 0
    field templ : Template
    field code  : String <- ""

    const csname :    CString <- CString.create
    const cscode: CString <- CString.create
    var myind : Integer <- ~1

    export function asString -> [s : String]
      s <- "opvectore"
    end asString

    export operation setOthers [x : aoa]
      cscode$others <- x
    end setOthers

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	OPVectorECT.getIndex[start, q]
	csname$s <- name
	csname.getIndex[start, q]
	if templ !== nil then
	  templ.getIndex[start, q]
	end if
	if code !== nil then
	  cscode$s <- code
	  cscode.getIndex[start, q]
	end if
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex
    
    export operation CPoint [file : OutStream]
      var x : Integer
      file.putString[obj]
      file.writeInt[4 + 4 + 4 + 4 + 4 + 4 + 4, 4]
      file.writeInt[0x00000000 + OPVectorECT.fetchIndex, 4]

      file.writeInt[id, 4]
      file.writeInt[nargs, 4]
      file.writeInt[nress, 4]

      x <- csname.fetchIndex
      file.writeInt[x, 4]

      if templ == nil then
	x <- 0x80000000
      else
	x <- templ.fetchIndex
      end if
      file.writeInt[x, 4]

      if code == nil then
	x <- 0x80000000
      else
	x <- cscode.fetchIndex
      end if
      file.writeInt[x, 4]
    end CPoint
    export operation generateBuiltin -> [r : COpVectorE]
      r <- COpVectorE.create[id, nargs, nress, name, templ.getString, code]
    end generateBuiltin
end OpVectorE

export OpVectorE

const CTCodeCT <- immutable object CTCodeCT
  const obj <- "-OB-"
  const CTCodeCTOID <- 0x1818
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export operation fetchIndex -> [r : Integer]
    r <- myind$myind
  end fetchIndex

  export operation getIndex [start : Integer, q : CPQueue]
    if myind$myq !== q then
      myind$myq <- q
      q.AddUpper[self]
      myind$myind <- q.upperbound
    end if
  end getIndex

  export operation CPoint [file : OutStream]
    file.putString[obj]
    OIDWriter.Out[CTCodeCTOID, file]
  end CPoint
end CTCodeCT

const CreateOne <- class CreateOne [codeid : Integer, xxid : Integer]
  const obj <- "*OB*"
  const field id : Integer <- xxid
    var myind : Integer <- ~1

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex
  
    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.AddUpper[self]
	myind <- q.upperbound
      end if
    end getIndex
  
    export operation CPoint [file : OutStream]
      file.putString[obj]
      OIDWriter.Out[codeid, file]
      OIDWriter.Out[id, file]
    end CPoint
end CreateOne


const CTCode <- class CTCode
    const obj <- "+OB+"
    var csname :    CString <- CString.create
    var csfilename :    CString <- CString.create
    
    field instanceSize    : Integer
    field instanceFlags : Integer
    field opVec           : OpVector <- OpVector.create
    field name            : String
    field filename        : String
    field templ		  : Template
    field mytype	  : CPAble
    const field literals  : aoip <- aoip.create[~8]
    var cliterals         : CInts

    field id 		  : Integer
    var myind : Integer <- ~1
    var creationThing : CreateOne

    export function asString -> [s : String]
      s <- "ct"
    end asString

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	CTCodeCT.getIndex[start, q]
	opVec.getIndex[start, q]
	if name !== nil then
	  csname$s <- name
	  csname.getIndex[start, q]
	end if
	if filename !== nil then
	  csfilename$s <- filename
	  csfilename.getIndex[start, q]
	end if
	if templ !== nil then
	  templ.getIndex[start, q]
	end if
	if mytype !== nil then
	  mytype.getIndex[start, q]
	end if
	if literals !== nil then
	  cliterals <- CInts.create[literals]
	  cliterals.getIndex[start, q]
	end if
	if name !== nil and name = "Compilation" then
	  creationThing <- CreateOne.create[id, 0]
	  creationThing.getIndex[start, q]
	end if
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex

    export operation CPoint [file : OutStream]
      var x : Integer
      file.putString[obj]
      file.writeInt[16 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4, 4]
      OIDWriter.Out[id, file]
      file.writeInt[0x40000000 + CTCodeCT.fetchIndex, 4]
      file.writeInt[instanceSize, 4]
      file.writeInt[instanceFlags, 4]
      x <- opVec.fetchIndex
      file.writeInt[x, 4]
      if name == nil then
	x <- 0x80000000
      else
	x <- csname.fetchIndex
      end if
      file.writeInt[x, 4]
      if filename == nil then
	x <- 0x80000000
      else
	x <- csfilename.fetchIndex
      end if
      file.writeInt[x, 4]
      if templ == nil then
	x <- 0x80000000
      else
	x <- templ.fetchIndex
      end if
      file.writeInt[x, 4]
      if mytype == nil then
	x <- 0x80000000
      else
	x <- mytype.fetchIndex
      end if
      file.writeInt[x, 4]

      % Write the literals
      if cliterals == nil then
	x <- 0x80000000
      else
	x <- cliterals.fetchIndex
      end if
      file.writeInt[x, 4]
    end CPoint
    export operation generateBuiltin -> [r : ConcreteType]
      % Turn the literals into the real thing.
      const lits <- VectorOfInt.create[(literals.upperbound + 1) * 4]
      for i : Integer <- 0 while i <= literals.upperbound by i <- i + 1
	lits[4 * i]     <- 0	 % The first two lines are the Node of the OID.
	lits[4 * i + 1] <- (0).setBit[16, literals[i].second = 1]
	lits[4 * i + 2] <- literals[i].first
	% This is eventually overwritten with the pointer to the actual
	% object when it is relocated.
	lits[4 * i + 3] <- 0x80000000
      end for
      r <- ConcreteType.create[
	instanceSize,
	instanceFlags,
	opVec.generateBuiltin,
	name,
	filename,
	templ.getString,
	nil,
	LiteralList.literal[lits]]
      primitive "INSTALLINOID" [] <- [id, r]
      if mytype !== nil then
	var typeid : Integer
	typeid <- (view mytype as hasID)$id
	primitive "RELOCATETYPE" [] <- [r, typeid]
      end if
    end generateBuiltin
end CTCode

export CTCode
export CreateOne
