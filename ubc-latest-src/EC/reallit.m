export Reallit

const reallit <- class Reallit (Tree) [xstr : String]
  const myindex <- 0x0a
  const field str : String <- xstr

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy
  export function asString -> [r : String]
    r <- "reallit (" || str || ")"
  end asString

  export operation generate[xct : Printable]
    const mycs <- CString.create
    const bc <- view xct as ByteCode
    mycs$s <- str
    mycs.getAnID
    bc.fetchLiteral[mycs$myid]
    bc.addOther[mycs]
    bc.addCode["STRF"]
    if bc$size != 4 then 
      bc.fetchVariableSecondThing[0x1800 + myindex, 0x1600 + myindex] 
    end if
  end generate

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export operation execute -> [r : Tree]
    r <- self
  end execute
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstCT
  end getCT
end Reallit
