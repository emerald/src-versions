export Literal, IntegerIndex, BooleanIndex, CharacterIndex,
       NilIndex, RealIndex, StringIndex

const IntegerIndex <- 0x06
const BooleanIndex <- 0x03
const CharacterIndex <- 0x04
const NilIndex <- 0x07
const RealIndex <- 0x0a
const StringIndex <- 0x0b

const Literal <- class Literal (Tree) [xindex : Integer, xstr : String]
  class export operation IntegerL [ln : Integer, xstr : String] -> [r : Tree]
    r <- Literal.create[ln, IntegerIndex, xstr]
  end IntegerL
  class export operation BooleanL [ln : Integer, value : Boolean] -> [r : Tree]
    if value then
      r <- Literal.create[ln, BooleanIndex, "true"]
    else
      r <- Literal.create[ln, BooleanIndex, "false"]
    end if
  end BooleanL
  class export operation CharacterL [ln : Integer, xstr : String] -> [r : Tree]
    r <- Literal.create[ln, CharacterIndex, xstr]
  end CharacterL
  class export operation NilL[ln : Integer] -> [r : Tree]
    r <- Literal.create[ln, NilIndex, "nil"]
  end NilL
  class export operation RealL [ln : Integer, xstr : String] -> [r : Tree]
    r <- Literal.create[ln, RealIndex, xstr]
  end RealL
  class export operation StringL [ln : Integer, xstr : String] -> [r : Tree]
    r <- Literal.create[ln, StringIndex, xstr]
  end StringL

  const field index : Integer <- xindex
  field str : String <- xstr

  export function asString -> [r : String]
    r <- "literal (" || str || ")"
  end asString

  export operation copy [i : Integer] -> [r : Tree]
    r <- self
  end copy

  export operation getIsNotManifest -> [r : Boolean]
    r <- false
  end getIsNotManifest

  export operation generate[xct : Printable]
    const bc <- view xct as ByteCode
    if index = IntegerIndex then
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
    elseif index = BooleanIndex then
      bc.addCode["LDIB"]
      if str = "true" then
	bc.addValue[1, 1]
      else
	bc.addValue[0, 1]
      end if
    elseif index = CharacterIndex then
      bc.addCode["LDIB"]
      bc.addValue[str[0].ord, 1]
    elseif index = NilIndex then
      if bc$size == 4 then
	bc.addCode["PUSHNIL"]
      else
	bc.addCode["PUSHNILV"]
      end if
      % Nil doesn't want to push the abcon stuff, so we just return.
      return
    elseif index = RealIndex then
      const mycs : CString <- CString.create

      mycs$s <- str
      mycs.getAnID
      bc.fetchLiteral[mycs$myid]
      bc.addOther[mycs]
      bc.addCode["STRF"]
    elseif index = StringIndex then
      const mycs : CString <- CString.create

      mycs$s <- str
      mycs.getAnID
      bc.fetchLiteral[mycs$myid]
      bc.addOther[mycs]
    else
      assert false
    end if
    bc.finishExpr[4, 0x1800 + index, 0x1600 + index]
  end generate
  export operation execute -> [r : Tree]
    r <- self
  end execute
  export operation getAT -> [r : Tree]
    r <- builtinlit.create[self$ln, index].getInstAT
  end getAT
  export operation getCT -> [r : Tree]
    r <- builtinlit.create[self$ln, index].getInstCT
  end getCT
end Literal
