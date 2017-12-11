export Sym

const sym <- class Sym (Tree) [xxid : Ident]
  class export operation literal [s : String] -> [r : SymType]
    r <- Sym.create[0, Environment.getEnv.getITable.lookup[s, 999]]
  end literal

    const field id : Ident <- xxid
    field mysym : Symbol

    export operation copy [i : Integer] -> [r : symType]
      var nid : Ident 
      const it : IdentTable <- Environment.getEnv.getITable
      if id !== nil then nid <- it.lookup[id.asString, 999] end if
      r <- sym.create[ln, nid]
      if mysym !== nil then r$mysym <- mysym.copy[i] end if
    end copy

    export function getAT -> [r : Tree]
      r <- view mysym$ATinfo as Tree
      if r == nil and ! mysym$isNotManifest then
	if mysym$value == nil then
	  Environment$env.printf["sym.getat: %s mysym.value is nil\n", {id.asString}]
	else
	  r <- (view mysym$value as Tree).getAT
	end if
      end if
    end getAT

    export function getCT -> [r : Tree]
      const env : EnvironmentType <- Environment$env
      const tinline <- env$traceInline
      if mysym$CTInfo !== nil then
	r <- view mysym$CTInfo as Tree
	if tinline then 
	  env.printf["sym.getCT on %s has a ct %s\n", 
	    { self.pasString, r.asString }]
	end if
% was
%      elseif mysym$isself and mysym$value !== nil and 
%	 mysym$value.asString == "oblit" then
% is now
      elseif mysym$value !== nil then
	if nameof mysym$value == "anoblit" then
	  r <- view mysym$value as Tree
	else
	  r <- (view mysym$value as Tree).getCT
	end if
	if tinline then
	  env.printf["sym.getCT on %s has a value %s with ct %s\n", 
	    { self.pasString, mysym$value.asString, FTree.getString[r] }]
	end if
% end
      elseif mysym$ATInfo !== nil then
	const a <- view mysym$ATInfo as hasInstCT
	r <- a$instCT
	if tinline then
	  env.printf["sym.getCT on %s has an at %s with ct %s\n", 
	    { self.pasString, a.asString, FTree.getString[r] }]
	end if
	if r == nil then
	  const atid : Integer <- (view mysym$ATInfo as hasID)$id
	  const ctid : Integer <- IDS.IDtoInstCTID[atid]
	  if ctid !== nil then
	    r <- globalref.create[ln, nil, nil, ctid, nil, nil]
	  end if
	end if
      end if
    end getCT
      
    export operation getIsNotManifest -> [r : Boolean]
      r <- mysym$isNotManifest
    end getIsNotManifest
    
    export operation setIsNotManifest [r : Boolean]
      mysym$isNotManifest <- r
    end setIsNotManifest
    
    function pasString -> [r : String]
      var rest : String <- ""
      r <- "sym (" || id$name || ")"
      if mysym !== nil then
	rest <- " " || Environment.getPtr[mysym].asString
	if mysym$base !== nil and mysym$offset !== nil then
	  rest <- rest || " " || mysym$base.asString || "@" || mysym$offset.asString
	end if
      end if
      r <- r || rest
      if mysym !== nil then
	if mysym$isUsedOutsideInitially then
	  r <- r || " uoi"
	else
	  r <- r || " !uoi"
	end if
	if mysym$isNotManifest then
	  r <- r || " isNotManifest"
	end if
	if mysym$isTypeVariable then
	  r <- r || " isTypeVariable"
	end if
	if mysym$value == nil then
	  r <- r || " manifest but no value"
	else
	  r <- r || " manifest value = " || mysym$value.asString
	end if
      end if
    end pasString

    function mAsString -> [r : String]
      r <- self.pAsString
    end mAsString

    export operation resolveSymbols [st : SymbolTable, nexp : Integer]
      if mysym == nil then
	const env : EnvironmentType <- Environment.getEnv
	mysym <- st.Lookup[ln, id, true]
	if mysym == nil then
	  env.SemanticError[ln, "Undefined identifier %s", { id$name} ]
	elseif mysym$mykind = SExternal and env$externalDirectory == nil then
	  env.SemanticError[ln, "Can't define external symbols without an external directory", nil]
	end if
      end if
    end resolveSymbols


  export function asString -> [r : String]
    r <- self.mAsString
  end asString

  export function getCodeOID -> [oid : Integer]
    const ct <- self$ct
    if ct !== nil then oid <- (view ct as hasIDs)$codeOID end if
  end getCodeOID

  export function getATOID -> [oid : Integer]
    const myAT <- self.getat
    if myAT !== nil then oid <- (view myAT as hasID).getID end if
  end getATOID

  export operation generate [xct : Printable]
    if mysym$isself then
      const bc <- view xct as ByteCode

      if bc$size = 4 then
	bc.addCode["LDSELF"]
      else
	bc.addCode["LDSELFV"]
      end if
    else
      const thev <- view mysym$value as Tree
      const hasexport <- typeobject t function getIsExported -> [Boolean] end t
      if !mysym$isNotManifest or 
	thev !== nil and 
	nameof thev = "anoblit" and 
	(view thev as hasexport)$isExported then
	% Do it by id
	const v <- view mysym$value as Tree
	if nameof v = "anoblit" then
	  const gs <- typeobject gs
	    operation generateSelf[Printable]
	  end gs
	  const vgs <- view v as gs
	  vgs.generateSelf[xct]
	else
	  v.generate[xct]
	end if
      else
	const bc <- view xct as ByteCode
	const bcsize : Integer <- bc$size
  
	if mysym$mykind = SExternal then
	  % we want to execute:
	  %   externalDirectory.lookup[id$name]
	  var dseq, dcseq: Integer
	  var externalDirectory : Directory
	  var externalDirectoryCode : ConcreteType
	  var r : Tree
    
	  externalDirectory <- Environment$env$externalDirectory
	  primitive "GETIDSEQ" [dseq] <- [externalDirectory]
    
	  externalDirectoryCode <- codeof externalDirectory
	  primitive "GETIDSEQ" [dcseq] <- [externalDirectoryCode]
    
	  r <- Environment$env$invoc.create[ln, 
	    GlobalRef.create[ln, dseq, nil, dcseq, nil, nil], 
	    OpName.Literal["lookup"],
	    Seq.singleton[view Literal.StringL[ln, id$name] as Tree]]
      
	  r.generate[xct]
	else
	  var opcode : String
	  const base : Character <- mysym$base
	  const offset : Integer <- mysym$offset
	  var size : Integer <- mysym$size
	  const opcodev <- VectorOfChar.create[5]
	  var index : Integer <- 2
	  var offsetsize : Integer 
	  opcodev[0] <- 'L'
	  opcodev[1] <- 'D'
	  if size == 8 and bcsize == 8 then 
	    opcodev[index] <- 'V'
	    index <- index + 1
	  else
	    size <- 4
	  end if
	  opcodev[index] <- base 
	  index <- index + 1
	  if ~128 <= offset and offset <= 127 then
	    opcodev[index] <- 'B'
	    index <- index + 1
	    offsetsize <- 1
	  elseif ~32768 <= offset and offset <= 32767 then
	    opcodev[index] <- 'S'
	    index <- index + 1
	    offsetsize <- 2
	  else
	    offsetsize <- 4
	  end if
	  bc.addCode[String.FLiteral[opcodev, 0, index]]
	  bc.addValue[offset, offsetsize]
	  bc.finishExpr[size, self$codeOID, self$atOID] 
	end if
      end if
    end if
  end generate
  export operation generateLValue [xct : Printable]
    if mysym$isNotManifest then
      const bc <- view xct as ByteCode

      if mysym$mykind = SExternal then
	% we want to execute:
	%   externalDirectory.insert[id$name, valueonthestack]
	%
	var dseq, dcseq: Integer
	var externalDirectory : Directory
	var externalDirectoryCode : ConcreteType
	var r : Tree

	bc.pushSize[8]
	Literal.StringL[0, id$name].generate[xct]
	bc.popSize
	bc.addCode["SWAPV"]
      
	externalDirectory <- Environment$env$externalDirectory
	primitive "GETIDSEQ" [dseq] <- [externalDirectory]

	externalDirectoryCode <- codeof externalDirectory
	primitive "GETIDSEQ" [dcseq] <- [externalDirectoryCode]

	r <- Environment$env$invoc.create[ln, 
	  GlobalRef.create[ln, dseq, nil, dcseq, nil, nil], 
	  OpName.Literal["insert@2"],
	  nil]
	begin
	  (view r as typeobject x operation setnress[Integer] end x)$nress <- 0
	end
	r.generate[xct]
      else
	var opcode : String
	const base : Character <- mysym$base
	const offset : Integer <- mysym$offset
	const size : Integer <- mysym$size
	const bcsize : Integer <- bc$size
	const opcodev <- VectorOfChar.create[5]
	var index : Integer <- 2
	var offsetsize : Integer 
	opcodev[0] <- 'S'
	opcodev[1] <- 'T'
	if size == 8 and bcsize == 8 then opcodev[index] <- 'V' index <- index + 1 end if
	opcodev[index] <- base 
	index <- index + 1
	if ~128 <= offset and offset <= 127 then
	  opcodev[index] <- 'B'
	  index <- index + 1
	  offsetsize <- 1
	elseif ~32768 <= offset and offset <= 32767 then
	  opcodev[index] <- 'S'
	  index <- index + 1
	  offsetsize <- 2
	else
	  offsetsize <- 4
	end if
	if bcsize == 8 and size < 8 then bc.addCode["POOP"] end if
	bc.addCode[String.FLiteral[opcodev, 0, index]]
	bc.addValue[offset, offsetsize]
      end if
    else
      Environment.getEnv.printf["Attempt to store to manifest symbol %s\n",
	{ mysym$myident.asString }]
    end if
  end generateLValue

  export function asType -> [r : Tree]
    r <- self.execute.asType
  end astype
  export operation execute -> [r : Tree]
    if ! self$isNotManifest then
      r <- view self$mysym$value as Tree
      if r !== nil then r <- r.execute end if
    end if
  end execute
  export function same [o : Tree] -> [r : Boolean]
    const s <- nameof o
    r <- false
    if s = "asym" then
      r <- self$id == (view o as Sym)$id
    end if
  end same
  export operation findThingsToGenerate [q : Any]
    var r : Tree
    if self$mysym !== nil and !self$isNotManifest then
      r <- view self$mysym$value as Tree
      if r !== nil then
	r.findThingsToGenerate[q]
      end if
    end if
  end findThingsToGenerate
  export operation prune 
    mysym <- nil
  end prune
end Sym
