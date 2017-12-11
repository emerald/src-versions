export sugar

const Sugar <- immutable object Sugar
  const x <- 1
  export operation doAnOp [oname : Ident, pt:Tree, rt:Tree, al:Tree, ar:Tree, isFunction : Boolean] -> [r:OpDef]
    var ln : Integer
    var rsym, psym, rsymr, psymr, pl, rl, ral, rar, asstat, ablock : Tree
    var lid : Ident
%    newid.reset
    if pt !== nil then
      ln <- pt$ln
      lid <- newid.newid
      psym <- sym.create[ln, lid]
      psymr <- sym.create[ln, lid]
      pl <- seq.singleton[param.create[ln, psym, pt.copy[0]]]
    end if
    if rt !== nil then
      ln <- rt$ln
      lid <- newid.newid
      rsym <- sym.create[ln, lid]
      rsymr<- sym.create[ln, lid]
      rl <- seq.singleton[param.create[ln, rsym, rt.copy[0]]]
    end if
    const asig <- opsig.create[ln, oname, pl, rl, nil]
    asig$isFunction <- isFunction
    if al == nil then ral <- rsymr else ral <- al end if
    if ar == nil then rar <- psymr else rar <- ar end if
    asstat <- assignstat.create[ln, 
      seq.singleton[ral],
      seq.singleton[rar]]
    ablock <- block.create[ln, sseq.singleton[asstat], nil, nil]
    r <- opdef.create[ln, asig, ablock]
    r$isexported <- true
  end doAnOp

  export operation doAField [ops:Tree, f:FieldDecl] -> [nops:Tree, nf:Tree]
    const s <- view f$sym as sym
    const sr <- s.copy[0]
    const id <- s$id
    var anOp : OpDef

    if ops == nil then nops <- seq.create[f$ln] else nops <- ops end if

    if f$isConst then
      nf <- constdecl.create[f$ln, s, f$xtype, f$value]
    else
      nf <- vardecl.create[f$ln, s, f$xtype, f$value]
      nops.rcons[self.doAnOp[opname.literal["set"||id.asString], f$xtype, nil, sr, nil, false]]
    end if
% If doing move/visit
    (view nf as attachable)$isattached <- f$isattached
    nops.rcons[self.doAnOp[opname.literal["get"||id.asString], nil, f$xtype, nil, sr, true]]
  end doAField

  export operation doFields [decls:Tree, ops:Tree] -> [nops:Tree]
    nops <- ops
    if decls == nil then return end if
    for i:Integer <- 0 while i <= decls.upperbound by i <- i + 1
      begin
	const d <- decls[i]
	var f : Tree
	if nameof d = "afielddecl" then
	  nops, f <- self.doAField[nops, view d as fielddecl]
	  decls[i] <- f
	end if
      end
    end for
  end doFields
  
end Sugar
