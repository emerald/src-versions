% 
% @(#)Boolean.m	1.2  3/6/91
%
const Boolean <- immutable object Boolean builtin 0x1003
  const BooleanType <- immutable typeobject BooleanType builtin 0x1603
    function > [o : Boolean] -> [r : Boolean]
    function >=[o : Boolean] -> [r : Boolean]
    function < [o : Boolean] -> [r : Boolean]
    function <=[o : Boolean] -> [r : Boolean]
    function = [o : Boolean] -> [r : Boolean]
    function !=[o : Boolean] -> [r : Boolean]
    function & [o : Boolean] -> [r : Boolean]
    function | [o : Boolean] -> [r : Boolean]
    function ! -> [r : Boolean]
    function ord -> [r : Integer]
    function asString -> [s : String]
      % s <- either "true" or "false"
    function hash -> [Integer]
  end BooleanType
  export function getSignature -> [result : Signature]
    result <- BooleanType
  end getSignature
  export function create [data : Integer] -> [result : BooleanType]
    result <- immutable object aBoolean builtin 0x1403
      export function > [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "GT" [r] <- [o]
      end >
      export function >= [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "GE" [r] <- [o]
      end >=
      export function < [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "LT" [r] <- [o]
      end <
      export function <= [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "LE" [r] <- [o]
      end <=
      export function = [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "EQ" [r] <- [o]
      end =
      export function != [o : Boolean] -> [r : Boolean]
	primitive self  "SUB" "NE" [r] <- [o]
      end !=
      export function & [o : Boolean] -> [r : Boolean]
	primitive self "AND" [r] <- [o]
      end &
      export function | [o : Boolean] -> [r : Boolean]
	primitive self "OR" [r] <- [o]
      end |
      export function ! -> [r : Boolean]
	primitive self "NOT" [r] <- []
      end !
      export function asString -> [r : String]
	primitive self "EBSTR" [r] <- []
      end asString
      export function ord -> [r : Integer]
	primitive self [r] <- []
      end ord
      export function hash -> [r : Integer]
	primitive self [r] <- []
      end hash
    end aBoolean
  end create
  export function makeTrue -> [result : BooleanType]
    result <- true
  end makeTrue
  export function makeFalse -> [result : BooleanType]
    result <- false
  end makeFalse
end Boolean

export Boolean to "Builtins"

