% 
% @(#)Integer.m	1.2  3/6/91
%
const Integer <- immutable object Integer builtin 0x1006
  const IntegerType <- immutable typeobject IntegerType builtin 0x1606
    function + [o : Integer] -> [r : Integer]
      % r <- self + o
    function - [o : Integer] -> [r : Integer]
      % r <- self - o
    function * [o : Integer] -> [r : Integer]
      % r <- self * o
    function / [o : Integer] -> [r : Integer]
      % r <- self / o
    function # [o : Integer] -> [r : Integer]
      % r <- self % o
    function > [o : Integer] -> [r : Boolean]
      % r <- self > o
    function >= [o : Integer] -> [r : Boolean]
      % r <- self >= o
    function < [o : Integer] -> [r : Boolean]
      % r <- self < o
    function <= [o : Integer] -> [r : Boolean]
      % r <- self <= o
    function = [o : Integer] -> [r : Boolean]
      % r <- self = o
    function != [o : Integer] -> [r : Boolean]
      % r <- self != o
    function asString -> [r : String]
      % s is set to a string with no leading 0's, decimal rep.
    function asHexString -> [r : String]
      % s is set to an 8 character string, hexidecimal rep.
    function ~ -> [r : Integer]
      % r <- negate self
    function - -> [r : Integer]
      % r <- negate self
    function asReal -> [ r : Real ]
      % r <- self as a real
    function hash -> [Integer]
    function & [o : Integer] -> [r : Integer]
    function | [o : Integer] -> [r : Integer]
    function setBit [o : Integer, v : Boolean] -> [r : Integer]
    function getBit [o : Integer] -> [r : Boolean]
    function setBits [o : Integer, l : Integer, v : Integer] -> [r : Integer]
    function getBits [o : Integer, l : Integer] -> [r : Integer]
    function abs -> [r : Integer]
  end IntegerType

  export function getSignature -> [result : Signature]
    result <- IntegerType
  end getSignature
  export function create [rep : String] -> [result : IntegerType]
    result <- immutable object anInteger builtin 0x1406
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
      export function asHexString -> [r : String]
	primitive self  "ISTRX" [r] <- []
      end asHexString
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
    end anInteger
  end create
  export operation literal [s : String] -> [r : IntegerType]
    primitive "STRI" [r] <- [s]
  end literal
end Integer

export Integer to "Builtins"
