export Charlit

const charlit <- class Charlit (Tree) [xxstr : String]
  const field str : String <- xxstr
  const myindex <- 0x04

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy
  export function asString -> [r : String]
    r <- "charlit (" || str || ")"
  end asString

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    bc.addCode["LDIB"]
    bc.addValue[str[0].ord, 1]
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
end Charlit
