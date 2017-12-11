export RecordLit

const T <- Tree

const recordlit <- class Recordlit (OTree) [xxsfname : Tree, xxname : Tree, xxfields : Tree]
    field codeOID : Integer
    field id : Integer
    field sfname : Tree <- xxsfname
    field name : Tree <- xxname
    field fields : Tree <- xxfields

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- name
      elseif i = 1 then
	r <- fields
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	name <- r
      elseif i = 1 then
	fields <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsfname, nname, nfields : Tree
      if sfname !== nil then nsfname <- sfname.copy[i] end if
      if name !== nil then nname <- name.copy[i] end if
      if fields !== nil then nfields <- fields.copy[i] end if
      r <- recordlit.create[ln, nsfname, nname, nfields]
    end copy
    operation iremoveSugar -> [r : OTree]
      var theparams, thedecls, ops : Tree
      theparams <- seq.create[ln]
      thedecls <- seq.create[ln]
      ops <- seq.create[ln]
      ops.rcons[nil]
      ops.rcons[nil]
      ops.rcons[nil]
      
      for i : Integer <- 0 while i <= fields.upperbound by i <- i + 1
	begin
	  const v <- fields[i]
	  const onefield <- view v as vardecl
	  const sdecl <- onefield$xsym.copy[0]
	  const shasid <- view sdecl as hasIdent
	  const sid <- shasid$id
	  const pid <- Environment.getEnv.getITable.Lookup["@__" || sid.asString, 999]
	  const sparam <- sym.create[ln, pid]
	  const sref  <-  sym.create[ln, pid]
	  const afield <- FieldDecl.create[ln, sdecl, onefield$xtype.copy[0], sref]
% If doing move/visit
	  afield$isAttached <- onefield$isAttached
	  thedecls.rcons[afield]
	  theparams.rcons[param.create[ln, sparam, onefield$xtype.copy[0]]]
	end 
      end for
      r <- xclass.create[ln, 
	sfname,
	name,
	nil,		% base
	theparams,
	nil,		% creators
	thedecls,	% decls
	ops]		% ops
      r$f <- f
    end iremoveSugar
    

  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- r.removeSugar[ob]
  end removeSugar
  export function asString -> [r : String]
    r <- "recordlit"
  end asString
end Recordlit
