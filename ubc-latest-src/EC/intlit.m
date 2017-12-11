
export Intlit

const intlit <- class Intlit (Tree) [xstr : String]
  const myindex <- 0x06
    field str : String <- xstr

    export function asString -> [r : String]
      r <- "intlit (" || str || ")"
    end asString

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    const v <- Integer.Literal[self$str]
    if ~128 <= v and v <= 127 then
      bc.addCode["LDIB"]
      bc.addValue[v, 1]
    elseif ~32768 <= v and v <= 32767 then
      bc.addCode["LDIS"]
      bc.addValue[v, 2]
    else
      bc.addCode["LDI"]
      bc.addValue[v, 4]
    end if
    if bc$size != 4 then
      bc.fetchVariableSecondThing[0x1800 + myindex, 0x1600 + myindex]
    end if
  end generate
  export operation execute -> [r : Tree]
    r <- self
  end execute
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, myindex].getInstCT
  end getCT
end Intlit
