export Globalref

const globalref <- class Globalref (Tree) [xxid : Integer, xxatOID : Integer, xxcodeOID : Integer, xxinstctOID : Integer, xxinstatOID : Integer]
    const field id    : Integer <- xxid
    const field atOID : Integer <- xxatOID
    const field codeOID:Integer <- xxcodeOID
    const field instCTOID : Integer <- xxinstCTOID
    const field instATOID : Integer <- xxinstATOID

    export function upperbound -> [r : Integer]
      r <- ~1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
    end getElement
    export operation setElement [i : Integer, r : Tree]
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      r <- self
    end copy

  export function variableSize -> [size : Integer]
    size <- IDS.IDToSize[self$id]
  end variableSize

  export function getBrand -> [brand : Character]
    brand <- IDS.IDToBrand[self$id]
  end getBrand

  export operation generateSelf [xct : Printable]
    self.generate[xct]
  end generateSelf

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    bc.fetchLiteral[self$id]
    bc.finishExpr[4, self$codeOID, 0x1601]
  end generate

  export function asString -> [r : String]
    r <- "globalref"
  end asString
  export operation execute -> [r : Tree]
    r <- self
  end execute
  
  export function asType -> [r : Tree]
    if instATOID == nil then
      r <- ObjectTable.Lookup[id]
    else
      r <- ObjectTable.Lookup[instATOID]
    end if
    if r == nil then r <- self end if
  end asType

  export function getInstCT -> [r : Tree]
    if instCTOID !== nil then
      r <- ObjectTable.Lookup[instCTOID]
      if r == nil then
	r <- globalref.create[self$ln, nil, nil, instCTOID, nil, nil]
      end if
    end if
  end getInstCT

  export function getInstAT -> [r : Tree]
    if instATOID !== nil then
      r <- ObjectTable.Lookup[instATOID]
      if r == nil then
	r <- globalref.create[self$ln, instATOID, nil, nil, nil, nil]
      end if
    end if
  end getInstAT

  export function getAT -> [r : Tree]
    if ATOID !== nil then
      r <- ObjectTable.Lookup[ATOID]
      if r == nil then
      r <- globalref.create[self$ln, ATOID, nil, nil, nil, nil]
      end if
    end if
  end getAT

  export operation conformsTo [theln : Integer, other : Tree] -> [r : Boolean]
    const otherashasid <- view other as hasid
    const otherid : Integer <- otherashasid$id
    const env : EnvironmentType <- Environment$env
    if env$tracetypecheck then 
      env.printf["  globalref.conformsTo[%s] on %d", { other.asString, theln }]
    end if
    r <- IDs.conformsByID[theln, self$id, otherid]
  end conformsTo
end Globalref
