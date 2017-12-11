
export Builtinlit

const builtinnames <- immutable object builtinnames
  const names <- {
      "type",
      "any",
      "array",
      "boolean",
      "character",
      "condition",
      "integer",
      "none",
      "node",
      "signature",
      "real",
      "string",
      "vector",
      "time",
      "nodelistelement",
      "nodelist",
      "instream",
      "outstream",
      "immutablevector",
      "bitchunk",
      "sequenceofcharacter",
      "handler",
      "vectorofchar",
      "rdirectory",
      "concretetype",
      "copvector",
      "copvectore",
      "aopvector",
      "aopvectore",
      "aparamlist",
      "vectorofint",
      "interpreterstate",
      "directory",
      "immutablevectorofany",
      "sequenceofany",
      "immutablevectorofint",
      "sequence",
      "stub",
      "directorygaggle",
      "literallist",
      "vectorofany",
      "immutablevectorofstring",
      "vectorofstring"
      }
  
  export operation getName [index : Integer] -> [name : String]
    if 0 <= index and index <= names.upperbound then
      name <- names[index]
    end if
  end getName
end builtinnames

const builtinlit <- class Builtinlit (Tree) [ xxwhich : Integer ]

  class export operation init -> [r : SymbolTable]
    var ss : Symbol
    const it : IdentTable <- Environment.getEnv.getITable
    var i : Integer <- 0

    r <- SymbolTable.create[nil, COutside]
    loop
      const name <- builtinnames.getName[i]
      exit when name == nil
      ss <- r.Define[0, it.lookup[name, 999], SConst, false]
      ss$value <- builtinlit.create[0, i]
      i <- i + 1
    end loop
  end init

  class export operation findTree [id : Integer, t : Tree] -> [r : Tree]
    var name : String 
    var index : Integer
    r <- t

    if id == nil then return end if
    if 0x1000 <= id and id <= 0x1040 then
      index <- id - 0x1000
    elseif 0x1200 <= id and id <= 0x1240 then
      index <- id - 0x1200
    elseif 0x1400 <= id and id <= 0x1440 then
      index <- id - 0x1400
    elseif 0x1600 <= id and id <= 0x1640 then
      index <- id - 0x1600
    elseif 0x1800 <= id and id <= 0x1840 then
      index <- id - 0x1800
    end if
    name <- builtinnames.getName[index]
    if name == nil then return end if
    r <- view Environment$env$rootst.Lookup[0,
      Environment$env$ITable.Lookup[name, 999], false]$value as Tree
  end findTree

    field which : Integer <- xxwhich

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
    export function getID -> [r : Integer]
      r <- 0x1000 + which
    end getID
    export function getCodeOID -> [r : Integer]
      r <- 0x1400 + which
    end getCodeOID
    export operation setID [newid : Integer]
      which <- newid - 0x1000
    end setID

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export operation setIsNotManifest [r : Boolean]
    assert false
  end setIsNotManifest

  export operation generate [xct : Printable]
    const bc <- view xct as ByteCode
    bc.fetchLiteral[0x1000 + self$which]
    bc.finishExpr[4, 0x1400 + which, 0x1200 + which] 
  end generate

  export function asString -> [r : String]
    r <- "builtinlit"
  end asString

  export operation execute -> [r : Tree]
    r <- self
  end execute
  
  export function asType -> [r : Tree]
    var x : BuiltinLit
    if which >= 0x600 then
      x <- self
    elseif which = 0x2 or which = 0xc or which = 0x12 then
      r <- nil
      return
    else
      x <- builtinlit.create[self$ln, 0x600 + which]
    end if
    r <- x.getInstAT
    if r == nil then r <- x end if
  end asType

  export operation getAT -> [r : Tree]
    r <- BuiltinLit.findTree[self$id, self]
    if nameof r = "anoblit" then
      r <- r.getAT
    else
      r <- globalref.create[ln, nil, nil, IDS.IDToATID[self$id], nil, nil]
    end if
  end getAT

  export operation getCT -> [r : Tree]
    r <- BuiltinLit.findTree[self$id, self]
    if nameof r != "anoblit" then
      const ctid : Integer <- IDS.IDToCTID[self$id]
      if ctid !== nil then
	r <- globalref.create[ln, nil, nil, ctid, nil, nil]
      end if
    end if
  end getCT

  export operation getInstCT -> [r : Tree]
    r <- BuiltinLit.findTree[self$id, self]
    if r == nil then return end if
    if nameof r = "anoblit" then
      const foo <- view r as hasInstCT
      const env : EnvironmentType <- Environment$env
      if env$traceinline then env.printf["builtinlit.getinstct: target is %s\n", 
	{ foo.asString} ]
      end if
      r <- foo.getInstCT
      if env$traceinline then env.printf["builtinlit.getinstct: answer is %s\n",
	{ FTree.getString[r]} ]
      end if
    else
      const ctid : Integer <- IDS.IDToInstCTID[self$id]
      if ctid !== nil then
	r <- globalref.create[ln, nil, nil, ctid, nil, nil]
      end if
    end if
  end getInstCT

  export operation getInstAT -> [r : Tree]
    r <- BuiltinLit.findTree[self$id, self]
    if r == nil then return end if
    if nameof r = "anoblit" then
      const foo <- view r as hasInstAT
      r <- foo.getInstAT
    elseif which = 0x2 or which = 0xc or which = 0x12 then
      % Array, Vector, and ImmutableVector don't have instATs
      r <- nil
    else
      if which >= 0x600 then
	r <- self
      else
	r <- builtinlit.create[self$ln, 0x600 + which]
      end if
    end if
  end getInstAT

  export function variableSize -> [size : Integer]
    size <- IDS.IDToSize[self$id]
  end variableSize

  export function getBrand -> [brand : Character]
    brand <- IDS.IDToBrand[self$id]
  end getBrand

  export operation conformsTo [theln : Integer, other : Tree] -> [r : Boolean]
    const otherashasid <- view other as hasid
    const otherid : Integer <- otherashasid$id
    r <- IDs.ConformsById[theln, self$id, otherid]
  end conformsTo
end Builtinlit
