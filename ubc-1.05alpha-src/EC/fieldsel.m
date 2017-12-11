export Fieldsel

const fieldsel <- class Fieldsel (Tree) [xxtarget : Tree, xxfieldref : Tree]
    field target : Tree <- xxtarget
    field fieldref : Tree <- xxfieldref

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- target
      elseif i = 1 then
	r <- fieldref
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	target <- r
      elseif i = 1 then
	fieldref <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var ntarget, nfieldref : Tree
      if target !== nil then ntarget <- target.copy[i] end if
      if fieldref !== nil then nfieldref <- fieldref.copy[i] end if
      r <- fieldsel.create[ln, ntarget, nfieldref]
    end copy
    export operation removeSugarOnLeft [a : Tree] -> [r : Tree]
      const s <- view fieldref as sym
      const oid <- s$id
      const nid <- OpName.Literal["set" || oid.asString]
      r <- invoc.create[s$ln, target, nid, a]
    end removeSugarOnLeft
    operation iremoveSugar -> [r : Tree]
      const s <- view fieldref as sym
      const oid <- s$id
      const nid <- OpName.literal["get" || oid.asString]
      r <- invoc.create[s$ln, target, nid, nil]
    end iremoveSugar

  export operation removeSugar [ob : Tree] -> [r : Tree]
    r <- self.iremoveSugar[]
    r <- FTree.removeSugar[r, ob]
  end removeSugar
  export function asString -> [r : String]
    r <- "fieldsel"
  end asString
end Fieldsel
