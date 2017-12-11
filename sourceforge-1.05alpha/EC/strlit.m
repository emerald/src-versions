export Stringlit

const stringlit <- class Stringlit (Tree) [xxstr : String]
  const myindex <- 0x0b
  const field str : String <- xxstr

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy

  export function asString -> [r : String]
    var s : String
    if str.length < 20 then
      s <- str
    else
      s <- str[0, 20] || "..."
    end if
    r <- "stringlit (" || s || ")"
  end asString

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
  export operation generate [ct : Printable]
    const mycs <- CString.create
    const bc <- view ct as ByteCode

    mycs$s <- str
    mycs.getAnID
    bc.fetchLiteral[mycs$myid]
    if bc$size != 4 then
      bc.fetchVariableSecondThing[0x1800 + myindex, 0x1600 + myindex] 
    end if
    bc.addOther[mycs]
  end generate
end Stringlit
