export Nillit

const nillit <- class Nillit (Tree)
  const myindex <- 0x07
  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    if bc$size == 4 then
      bc.addCode["PUSHNIL"]
    else
      bc.addCode["PUSHNILV"]
    end if
  end generate

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export function asString -> [r : String]
    r <- "nillit"
  end asString
  export operation execute -> [r : Tree]
    r <- self
  end execute
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstCT
  end getCT
end Nillit
