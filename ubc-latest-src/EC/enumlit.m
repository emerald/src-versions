
export Enumlit

const enumlit <- class Enumlit (OTree) [xxname : Tree, xxsyms : Tree]
    field codeOID : Integer
    field id : Integer
    field name : Tree <- xxname
    field syms : Tree <- xxsyms

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- name
      elseif i = 1 then
	r <- syms
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	name <- r
      elseif i = 1 then
	syms <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nname, nsyms : Tree
      if name !== nil then nname <- name.copy[i] end if
      if syms !== nil then nsyms <- syms.copy[i] end if
      r <- enumlit.create[ln, nname, nsyms]
    end copy

    operation iremoveSugar -> [r : Tree]
      const it <- Environment$env$ITable
      var t, u : Tree
      const cmpnames <- {
	opname.literal["<"],
	opname.literal["<="],
	opname.literal["="],
	opname.literal["!="],
	opname.literal[">"],
	opname.literal[">="] : Ident }
      var theclass : XClass
      var ops, creators, theparams : Tree
      const createname <- opname.literal["create"]
      const namesym <- view name as Sym
      const nameid  <- namesym$id
      const meid    <- it.Lookup["me", 999]
      
      creators <- seq.create[ln]
      
      ops <- seq.create[ln]
      ops.rcons[nil]
      ops.rcons[nil]
      ops.rcons[nil]
      % build first 
      begin
	const zero <- Literal.IntegerL[ln, "0"]
	t <- seq.singleton[zero]
	u  <- invoc.create[ln, selflit.create[ln], createname, t]
	creators.rcons[sugar.doAnOp[
	  opname.literal["first"], nil, Sym.create[ln, nameid], nil, u, true]]
      end
      % build last
      begin
	const limit <- Literal.IntegerL[ln, syms.upperbound.asString]
	t <- seq.singleton[limit]
	u <- invoc.create[ln, selflit.create[ln], createname, t]
	creators.rcons[sugar.doAnOp[
	  opname.literal["last"], nil, Sym.create[ln, nameid], nil, u, true]]
      end

      theparams <- Seq.create[ln]
      theparams.rcons[param.create[ln, 
	Sym.create[ln, meid],
	Sym.create[ln, it.Lookup["integer", 999]]]]

      % do the creation operations
      for i : Integer <- 0 while i <= syms.upperbound by i <- i + 1
	const s <- view syms[i] as Sym
	const sid <- s$id
	const sname : String <- sid.asString
	var cre : Tree
	t <- seq.singleton[Literal.IntegerL[ln, i.asString]]
	cre <- invoc.create[ln, selflit.create[ln], opname.literal["create"],t]
	creators.rcons[sugar.doAnOp[
	  OpName.Literal[sname], nil, Sym.create[ln, nameid], nil, cre, true]]
      end for

      % that takes care of the creator, now do the instances
      % build ord
      ops.rcons[sugar.doAnOp[
	opname.Literal["ord"], 
	nil, 
	Sym.create[ln, it.Lookup["integer", 999]],
	nil,
	Sym.create[ln, meid], true]]

      for i : Integer <- 0 while i < 6 by i <- i + 1
	const argid <- it.Lookup["a", 999]
	const resid <- it.Lookup["r", 999]
	var arg, res, sig, ord, eq, ass, body : Tree
	var def : OpDef
	arg <- Sym.create[ln, argid]
	arg <- param.create[ln, arg, Sym.create[ln, nameid]]
	res <- Sym.create[ln, resid]
	res <- param.create[ln, res, Sym.create[ln, it.Lookup["boolean", 999]]]
	t <- seq.singleton[arg]
	arg <- t
	t <- seq.singleton[res]
	res <- t
	sig <- opsig.create[ln, cmpnames[i], arg, res, nil]
	ord <- invoc.create[ln, 
	  Sym.create[ln, argid],
	  OpName.Literal["ord"],
	  nil]
	t <- seq.singleton[ord]
	ord <- t
	eq  <- invoc.create[ln,
	  Sym.create[ln, meid],
	  cmpnames[i],
	  ord]
	t <- seq.singleton[Sym.create[ln, resid]]
	u <- seq.singleton[eq]
	ass <- assignstat.create[ln, t, u]
	t <- sseq.singleton[ass]
	body<- block.create[ln, t, nil, nil]
	def <- OpDef.create[ln, sig, body]
	def$isExported <- true
	ops.rcons[def]
      end for

      % build succ
      begin
	const resid <- it.Lookup["r", 999]
	var res, sig, lss, ast, sub, cre, ass, body : Tree
	var def : OpDef
	res <- Sym.create[ln, resid]
	res <- param.create[ln, res, Sym.create[ln, nameid]]
	t <- seq.create[ln]
	t.rcons[res]
	res <- t
	sig <- opsig.create[ln, OpName.Literal["succ"], nil, res, nil]
	t <- seq.create[ln]
	t.rcons[Literal.IntegerL[ln, syms.upperbound.asString]]
	lss <- invoc.create[ln, 
	  Sym.create[ln, meid],
	  OpName.Literal["<"], t]
	ast <- assertstat.create[ln, lss]
	t <- seq.create[ln] t.rcons[Literal.IntegerL[ln, "1"]]
	sub <- invoc.create[ln,
	  Sym.create[ln, meid],
	  OpName.Literal["+"],
	  t]
	t <- seq.create[ln] t.rcons[sub]
	cre <- invoc.create[ln,
	  Sym.create[ln, nameid],
	  Opname.Literal["create"],
	  t]
	ass <- assignstat.create[ln,
	  seq.singleton[Sym.create[ln, resid]],
	  seq.singleton[cre]]
	body<- block.create[ln, sseq.literal[ln, { ast, ass : Tree }], nil, nil]
	def <- OpDef.create[ln, sig, body]
	def$isExported <- true
	ops.rcons[def]
      end


      % build pred
      begin
	const resid <- it.Lookup["r", 999]
	var res, gtr, ast, add, cre, sig, ass, body : Tree
	var def : OpDef
	res <- Sym.create[ln, resid]
	res <- param.create[ln, res, Sym.create[ln, nameid]]
	res <- Seq.literal[ln, {res: Tree }]
	sig <- opsig.create[ln, OpName.Literal["pred"], nil, res, nil]
	gtr <- invoc.create[ln, 
	  Sym.create[ln, meid],
	  OpName.Literal[">"],
	  Seq.Literal[ln, { Literal.IntegerL[ln, "0"] : Tree } ]]
	ast <- assertstat.create[ln,
	  gtr]
	add <- invoc.create[ln,
	  Sym.create[ln, meid],
	  OpName.Literal["-"],
	  Seq.Literal[ln, { Literal.IntegerL[ln, "1"]: Tree }]]
	cre <- invoc.create[ln,
	  Sym.create[ln, nameid],
	  Opname.Literal["create"],
	  Seq.Literal[ln, { add : Tree }]]
	ass <- assignstat.create[ln,
	  seq.singleton[Sym.create[ln, resid]],
	  seq.singleton[cre]]
	body<- block.create[ln, sseq.literal[ln, { ast, ass : Tree }], nil, nil]
	def <- OpDef.create[ln, sig, body]
	def$isExported <- true
	ops.rcons[def]
      end

      % build asString
      begin
	const resid <- it.Lookup["r", 999]
	var res, sig, ass, els, ifc, ifs, body : Tree
	var def : OpDef
	res <- Sym.create[ln, resid]
	res <- param.create[ln, res, Sym.create[ln, it.Lookup["string", 999]]]
	res <- Seq.literal[ln, { res: Tree }]
	sig <- opsig.create[ln, OpName.Literal["asstring"], nil, res, nil]
	ass <- assignstat.create[ln,
	  Seq.Literal[ln, { Sym.create[ln, resid] : Tree}],
	  Seq.Literal[ln, { Literal.StringL[ln, "an impossible "||nameid.asString] : Tree}]]
	els <- Seq.create[ln]
	els.rcons[ass]
	els <- elseclause.create[ln, els]
	ifc <- seq.create[ln]
	for i : Integer <- 0 while i <= syms.upperbound by i <- i + 1
	  const s <- view syms[i] as Sym
	  const sid <- s$id
	  const sname : String <- sid.asString
	  var eq : Tree
	  eq <- invoc.create[ln,
	    Sym.create[ln, meid],
	    opname.literal["="],
	    Seq.Literal[ln, {Literal.IntegerL[ln, i.asString] : Tree}]]
	  t <- seq.create[ln]
	  t.rcons[Sym.create[ln, resid]]
	  u <- seq.create[ln]
	  u.rcons[Literal.StringL[ln, sname]]
	  ass <- assignstat.create[ln, t, u]
	  t <- seq.create[ln]
	  t.rcons[ass]
	  ifc.rcons[ifclause.create[ln, eq, t]]
	end for
	
	ifs <- ifstat.create[ln, ifc, els]
	t <- sseq.singleton[ifs]
	body<- block.create[ln, t, nil, nil]
	def <- OpDef.create[ln, sig, body]
	def$isExported <- true
	ops.rcons[def]
      end

      r <- xclass.create[ln, 
	Environment$env$filename,
	name,
	nil,		% base
	theparams,
	seq.pair[seq.create[creators$ln], creators],	% creators
	nil,		% decls
	ops]		% ops
%     r.print[Environment$env$stdout, 6]
    end iremoveSugar

  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- r.removeSugar[ob]
  end removeSugar

  export function asString -> [r : String]
    r <- "enumlit"
  end asString
end Enumlit
