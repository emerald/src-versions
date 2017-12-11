const hasGenerateBuiltin <- typeobject hasGenerateBuiltin
  operation generateBuiltin -> [Any]
end hasGenerateBuiltin

const ATCodeCT <- immutable object ATCodeCT
  const obj <- "-OB-"
  const ATCodeCTOID <- 0x1809
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export function fetchIndex -> [r : Integer]
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
    OIDWriter.Out[ATCodeCTOID, file]
  end CPoint
end ATCodeCT

const ATCode <- class ATCode
    % Real fields
    field flags		: Integer <- 0
    field ops		: ATOpVector <- ATOpVector.create
    field name		: String
    field filename	: String

    % Checkpoint stuff
    field id 		: Integer
    const obj <- "+OB+"
    var csname :    CString <- CString.create
    var csfilename :    CString <- CString.create
    var myind : Integer <- ~1

    export function getIsTypeVariable -> [r : Boolean]
      r <- flags.getBit[31]
    end getIsTypeVariable
    export operation setIsTypeVariable [r : Boolean]
      flags <- flags.setBit[31, r]
    end setIsTypeVariable

    export function getIsImmutable -> [r : Boolean]
      r <- flags.getBit[30]
    end getIsImmutable
    export operation setIsImmutable [r : Boolean]
      flags <- flags.setBit[30, r]
    end setIsImmutable

    export function getIsVector -> [r : Boolean]
      r <- flags.getBit[29]
    end getIsVector
    export operation setIsVector [r : Boolean]
      flags <- flags.setBit[29, r]
    end setIsVector

    export function asString -> [s : String]
      s <- "at"
    end asString

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	ATCodeCT.getIndex[start, q]
	if ops !== nil then
	  ops.getIndex[start, q]
	end if
	if name !== nil then
	  csname$s <- name
	  csname.getIndex[start, q]
	end if
	if filename !== nil then
	  csfilename$s <- filename
	  csfilename.getIndex[start, q]
	end if
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex

    export operation CPoint [file : OutStream]
      var x : Integer
      file.putString[obj]
      file.writeInt[16 + 4 + 4 + 4 + 4, 4]
      OIDWriter.Out[id, file]
      file.writeInt[0x40000000 + ATCodeCT.fetchIndex, 4]
      file.writeInt[flags, 4]
      if ops == nil then
	x <- 0x80000000
      else
	x <- ops.fetchIndex
      end if
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
    end CPoint

  function builtinOf[x : hasGenerateBuiltin] -> [r : Any]
    if x !== nil then
      r <- x.generateBuiltin
    end if
  end builtinOf

  export operation generateBuiltin -> [r : Signature]
    r <- Signature.create[
      flags,
      view self.builtinOf[ops] as AOpVector,
      name,
      filename]
    primitive "INSTALLINOID" [] <- [id, r]
  end generateBuiltin
end ATCode

const aoove <- Array.of[ATOpVectorE]

const ATOpVectorCT <- immutable object ATOpVectorCT
  const obj <- "-OB-"
  const ATOpVectorCTOID <- 0x181b
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export function fetchIndex -> [r : Integer]
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
    OIDWriter.Out[ATOpVectorCTOID, file]
  end CPoint
end ATOpVectorCT

const ATOpVector <- class ATOpVector
  const obj <- "+OB-"

  field d	     : aoove <- aoove.create[~10]
  var myind : Integer <- ~1

  export function asString -> [s : String]
    s <- "atopvector"
  end asString
  export operation addUpper[e : ATOpVectorE]
    d.addUpper[e]
  end addUpper
  
  export operation setElement[i : Integer, e : ATOpVectorE]
    d[i] <- e
  end setElement

  export function getElement[i : Integer] -> [r : ATOpVectorE]
    r <- d[i]
  end getElement

  export function upperbound -> [r : Integer]
    r <- d.upperbound
  end upperbound

  export operation getIndex [start : Integer, q : CPQueue]
    if myind < 0 then
      const limit <- d.upperbound
      q.addUpper[self]
      myind <- q.upperbound
      ATOpVectorCT.getIndex[start, q]
      for i : Integer <- 0 while i <= limit by i <- i + 1
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
    file.writeInt[0x00000000 + ATOpVectorCT.fetchIndex, 4]
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

  export operation generateBuiltin -> [r : AOpVector]
    const voove <- Vector.of[AOpVectorE]
    var i : Integer <- 0
    const limit : Integer <- d.upperbound
    const myv <- voove.create[limit + 1]
    var dd : ATOpVectorE

    loop
      exit when i > limit
      dd <- d[i]
      if dd !== nil then
	myv[i] <- dd.generateBuiltin
      end if
      i <- i + 1
    end loop
    r <- AOpVector.literal[myv]
  end generateBuiltin
end ATOpVector

const ATTypeVectorCT <- immutable object ATTypeVectorCT
  const obj <- "-OB-"
  const ATTypeVectorCTOID <- 0x181d
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export function fetchIndex -> [r : Integer]
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
    OIDWriter.Out[ATTypeVectorCTOID, file]
  end CPoint
end ATTypeVectorCT

const aoRefByID <- Array.of[RefByID]

const ATTypeVector <- class ATTypeVector
    const obj <- "+OB-"

    field d	     : aoRefByID <- aoRefByID.create[~10]
    var myind : Integer <- ~1

    export function asString -> [s : String]
      s <- "attypevector"
    end asString

    export operation addUpper[e : RefByID]
      d.addUpper[e]
    end addUpper
    
    export operation setElement[i : Integer, e : RefByID]
      d[i] <- e
    end setElement

    export function getElement[i : Integer] -> [r : RefByID]
      r <- d[i]
    end getElement

    export function upperbound -> [r : Integer]
      r <- d.upperbound
    end upperbound

    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	ATTypeVectorCT.getIndex[start, q]
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
      file.writeInt[0x00000000 + ATTypeVectorCT.fetchIndex, 4]
      x <- d.upperbound - d.lowerbound + 1
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

  export operation generateBuiltin -> [r : AParamList]
    const voove <- Vector.of[Signature]
    var i : Integer <- 0
    const limit : Integer <- d.upperbound
    const myv <- voove.create[limit + 1]
    var dd : RefByID

    % Create the ParamList, which will have nils at every point, because the
    % signature objects are not findable from here.

    r <- AParamList.literal[myv]
    loop
      exit when i > limit

      % I have to get a pointer to each Signature object,
      % but they may not exist yet.  
      %
      % In fact, we can guarantee by the way that we generate these things
      % that each d[i] is going to be a RefById.  We need to somehow create
      % the relocation information for the resulting Signatures.
      %
      % A primitive is used to relocate each element of the resulting vector.
      dd <- d[i]
      if dd !== nil then
	const id <- dd$id
	primitive "RELOCATEVECTOR" [] <- [r, i, id]
      end if
      i <- i + 1
    end loop
  end generateBuiltin
end ATTypeVector

const ATOpVectorECT <- immutable object ATOpVectorECT
  const obj <- "-OB-"
  const ATOpVectorECTOID <- 0x181c
  const myind <- object x
      field myind : Integer <- ~1
      field myq : CPQueue
  end x
  export function fetchIndex -> [r : Integer]
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
    OIDWriter.Out[ATOpVectorECTOID, file]
  end CPoint
end ATOpVectorECT

const ATOpVectorE <- class ATOpVectorE [xxname : String]
    % Real fields, compare ../Tree/atype.m
    field name  : String <- xxname
    field id : Integer
    field isFunction : Boolean <- false
    field Arguments : ATTypeVector
    field Results   : ATTypeVector

    % Stuff for checkpointing
    const obj <- "+OB-"
    const csname :    CString <- CString.create
    var myind : Integer <- ~1

    export function asString -> [s : String]
      s <- "atopvectore"
    end asString
    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
	ATOpVectorECT.getIndex[start, q]
	csname$s <- name
	csname.getIndex[start, q]
	if Arguments !== nil then
	  Arguments.getIndex[start, q]
	end if
	if Results !== nil then
	  Results.getIndex[start, q]
	end if
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex
    
    export operation CPoint [file : OutStream]
      var x : Integer
      file.putString[obj]
      file.writeInt[4 + 4 + 4 + 4 + 4 + 4, 4]
      file.writeInt[0x00000000 + ATOpVectorECT.fetchIndex, 4]

      file.writeInt[id, 4]
      if isFunction then
	x <- 1
      else
	x <- 0
      end if
      file.writeInt[x, 4]

      x <- csname.fetchIndex
      file.writeInt[x, 4]
      if Arguments == nil then
	x <- 0x80000000
      else
	x <- Arguments.fetchIndex
      end if
      file.writeInt[x, 4]
      if Results == nil then
	x <- 0x80000000
      else
	x <- Results.fetchIndex
      end if
      file.writeInt[x, 4]
    end CPoint

  function builtinOf[x : hasGenerateBuiltin] -> [r : Any]
    if x !== nil then
      r <- x.generateBuiltin
    end if
  end builtinOf

  export operation generateBuiltin -> [r : AOpVectorE]
    r <- AOpVectorE.create[id, isFunction, name, 
	     view self.builtinOf[Arguments] as AParamList,
	     view self.builtinOf[Results] as AParamList]
  end generateBuiltin
end ATOpVectorE

const RefByID <- class RefByID [xid : Integer]
    % Stuff for checkpointing
    const obj <- "-OB-"
    var myind : Integer <- ~1
    const field id : Integer <- xid

    export function asString -> [s : String]
      s <- "refByID"
    end asString
    export operation getIndex [start : Integer, q : CPQueue]
      if myind < 0 then
	q.addUpper[self]
	myind <- q.upperbound
      end if
    end getIndex

    export function fetchIndex -> [r : Integer]
      r <- myind
    end fetchIndex
    
    export operation CPoint [file : OutStream]
      file.putString[obj]
      OIDWriter.Out[id, file]
    end CPoint

end RefByID


export ATCode, ATOpVector, ATOpVectorE, ATTypeVector, RefByID
