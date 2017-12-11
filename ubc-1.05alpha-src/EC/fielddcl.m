export Fielddecl

const fielddecl <- class Fielddecl (Tree) [xxsym : Tree, xxtype : Tree, xxvalue : Tree]
% If doing move/visit
    field isAttached : Boolean <- false
    field isConst : Boolean <- false
    field sym : Tree <- xxsym
    field xtype : Tree <- xxtype
    field value  : Tree <- xxvalue
    export function upperbound -> [r : Integer]
      r <- 2
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- sym
      elseif i = 1 then
	r <- xtype
      elseif i = 2 then
	r <- value
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	sym <- r
      elseif i = 1 then
	xtype <- r
      elseif i = 2 then
	value <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nsym, nxtype, nvalue : Tree
      if sym !== nil then nsym <- sym.copy[i] end if
      if xtype !== nil then nxtype <- xtype.copy[i] end if
      if value !== nil then nvalue <- value.copy[i] end if
      r <- fielddecl.create[ln, nsym, nxtype, nvalue]
      (view r as Attachable)$isAttached <- isAttached
    end copy

  export function asString -> [r : String]
    r <- "fielddecl"
  end asString
end Fielddecl
