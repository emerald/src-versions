export Boollit

const boollit <- class Boollit (Tree) [xvalue : Boolean]
  const field value : Boolean <- xvalue
  const myindex <- 0x03

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    bc.addCode["LDIB"]
    if self$value then
      bc.addValue[1, 1]
    else
      bc.addValue[0, 1]
    end if
    if bc$size != 4 then
      bc.fetchVariableSecondThing[0x1800 + myindex, 0x1600 + myindex]
    end if
  end generate
  export function asString -> [r : String]
    r <- "boollit"
  end asString
  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export operation execute -> [r : Tree]
    r <- self
  end execute
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstCT
  end getCT
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstAT
  end getAT
end Boollit
