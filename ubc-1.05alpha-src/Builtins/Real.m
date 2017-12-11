% 
% @(#)Real.m	1.2  3/6/91
%
const Real <- immutable object Real builtin 0x100a
  const RealType <- immutable typeobject RealType builtin 0x160a
    function + [o : Real] -> [r : Real]
      % r <- self + o
    function - [o : Real] -> [r : Real]
      % r <- self - o
    function * [o : Real] -> [r : Real]
      % r <- self * o
    function / [o : Real] -> [r : Real]
      % r <- self / o
    function ^ [o : Real] -> [r : Real]
      % r <- self ^ o (self raised to the exponent o)
    function > [o : Real] -> [r : Boolean]
      % r <- self > o
    function >= [o : Real] -> [r : Boolean]
      % r <- self >= o
    function < [o : Real] -> [r : Boolean]
      % r <- self < o
    function <= [o : Real] -> [r : Boolean]
      % r <- self <= o
    function = [o : Real] -> [r : Boolean]
      % r <- self = o
    function != [o : Real] -> [r : Boolean]
      % r <- self != o
    function asString -> [r : String]
      % s is set to a string with no leading 0's, decimal rep.
    function asInteger -> [r : Integer]
      % s is set to an integer (rounded)
    function ~ -> [r : Real]
      % r <- negate self
    function - -> [r : Real]
      % r <- negate self
  end RealType
  export function getSignature -> [result : Signature]
    result <- RealType
  end getSignature
  export function create -> [result : RealType]
    result <- immutable object aReal builtin 0x140a
      export function + [o : Real] -> [r : Real]
	primitive self "FADD" [r] <- [o]
      end +
      export function - [o : Real] -> [r : Real]
	primitive self "FSUB" [r] <- [o]
      end -
      export function * [o : Real] -> [r : Real]
	primitive self "FMUL" [r] <- [o]
      end *
      export function / [o : Real] -> [r : Real]
	primitive self "FDIV" [r] <- [o]
      end /
      export function ^ [o : Real] -> [r : Real]
	primitive self "FPOW" [r] <- [o]
      end ^
      export function > [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "GT" [r] <- [o]
      end >
      export function >= [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "GE" [r] <- [o]
      end >=
      export function < [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "LT" [r] <- [o]
      end <
      export function <= [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "LE" [r] <- [o]
      end <=
      export function = [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "EQ" [r] <- [o]
      end =
      export function != [o : Real] -> [r : Boolean]
	primitive self  "FCMP" "NE" [r] <- [o]
      end !=
      export function asString -> [r : String]
	primitive self "FSTR" [r] <- []
      end asString
      export function asInteger -> [r : Integer]
	primitive self "FINT" [r] <- []
      end asInteger
      export function ~ -> [r : Real]
	primitive self "FNEG" [r] <- []
      end ~
      export function - -> [r : Real]
	primitive self "FNEG" [r] <- []
      end -
    end aReal
  end create
  export function literal [rep : String] -> [result : RealType]  
    primitive "STRF" [result] <- [rep]
  end literal
end Real

export Real to "Builtins"
