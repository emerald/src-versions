const MyInteger <- immutable object myInteger
  export function + [o : Integer] -> [r : Integer]
    primitive self  "ADD" [r] <- [o]
  end +
  export function - [o : Integer] -> [r : Integer]
    primitive self  "SUB" [r] <- [o]
  end -
  export function * [o : Integer] -> [r : Integer]
    primitive self  "MUL" [r] <- [o]
  end *
  export function / [o : Integer] -> [r : Integer]
    primitive self  "DIV" [r] <- [o]
  end /
  export function # [o : Integer] -> [r : Integer]
    primitive self  "MOD" [r] <- [o]
  end #
  export function > [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "GT" [r] <- [o]
  end >
  export function >= [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "GE" [r] <- [o]
  end >=
  export function < [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "LT" [r] <- [o]
  end <
  export function <= [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "LE" [r] <- [o]
  end <=
  export function = [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "EQ" [r] <- [o]
  end =
  export function != [o : Integer] -> [r : Boolean]
    primitive self  "SUB" "NE" [r] <- [o]
  end !=
  export function asString -> [r : String]
    primitive self  "ISTR" [r] <- []
  end asString
  export function ~ -> [r : Integer]
    primitive self  "NEG" [r] <- []
  end ~
  export function - -> [r : Integer]
    primitive self  "NEG" [r] <- []
  end -
  export function asReal -> [r : Real]
    primitive self  "IFLO" [r] <- []
  end asReal
  export function hash -> [r : Integer]
    primitive self "IABS" [r] <- []
  end hash
  export function abs -> [r : Integer]
    primitive self "IABS" [r] <- []
  end abs
  export function & [o : Integer] -> [r : Integer]
    primitive self "LAND" [r] <- [o]
  end &
  export function | [o : Integer] -> [r : Integer]
    primitive self "LOR" [r] <- [o]
  end |
  export function setBit [o : Integer, v : Boolean] -> [r : Integer]
    primitive self "LSETBIT" [r] <- [o, v]
  end setBit
  export function getBit [o : Integer] -> [r : Boolean]
    primitive self "LGETBIT" [r] <- [o]
  end getBit
  export function setBits [o : Integer, l : Integer, v : Integer] -> [r : Integer]
    primitive self "LSETBITS" [r] <- [o, l, v]
  end setBits
  export function getBits [o : Integer, l : Integer] -> [r : Integer]
    primitive self "LGETBITS" [r] <- [o, l]
  end getBits
end myInteger

const x : Integer <- myInteger
