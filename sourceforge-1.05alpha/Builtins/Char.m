% 
% @(#)Character.m	1.2  3/6/91
%
const Character <- immutable object Character builtin 0x1004

  const CharacterType <- immutable typeobject CharacterType builtin 0x1604
    function ord -> [r : Integer]
    function > [o : Character] -> [r : Boolean]
      % r <- self > o
    function >= [o : Character] -> [r : Boolean]
      % r <- self >= o
    function < [o : Character] -> [r : Boolean]
      % r <- self < o
    function <= [o : Character] -> [r : Boolean]
      % r <- self <= o
    function = [o : Character] -> [r : Boolean]
      % r <- self = o
    function != [o : Character] -> [r : Boolean]
      % r <- self != o
    function asString -> [s : String]
      % s <- "c" where c is the character
    function hash -> [r : Integer]
    function isalpha -> [r : Boolean]
    function isupper -> [r : Boolean]
    function islower -> [r : Boolean]
    function isdigit -> [r : Boolean]
    function isxdigit -> [r : Boolean]
    function isalnum -> [r : Boolean]
    function isspace -> [r : Boolean]
    function ispunct -> [r : Boolean]
    function isprint -> [r : Boolean]
    function isgraph -> [r : Boolean]
    function iscntrl -> [r : Boolean]
    function toupper -> [r : Character]
    function tolower -> [r : Character]
  end CharacterType
  export function getSignature -> [result : Signature]
    result <- CharacterType
  end getSignature
  export function literal [x : Integer] -> [r : CharacterType]
    primitive [r] <- [x]
  end literal
  export function create -> [result : CharacterType]
    result <- immutable object aCharacter builtin 0x1404
      export function > [o : Character] -> [r : Boolean]
	primitive self  "SUB" "GT" [r] <- [o]
      end >
      export function >= [o : Character] -> [r : Boolean]
	primitive self  "SUB" "GE" [r] <- [o]
      end >=
      export function < [o : Character] -> [r : Boolean]
	primitive self  "SUB" "LT" [r] <- [o]
      end <
      export function <= [o : Character] -> [r : Boolean]
	primitive self  "SUB" "LE" [r] <- [o]
      end <=
      export function = [o : Character] -> [r : Boolean]
	primitive self  "SUB" "EQ" [r] <- [o]
      end =
      export function != [o : Character] -> [r : Boolean]
	primitive self  "SUB" "NE" [r] <- [o]
      end !=
      export function asString -> [s : String]
	primitive self "CSTR" [s] <- []
      end asString
      export function ord -> [r : Integer]
	primitive self [r] <- []
      end ord
      export function hash -> [r : Integer]
	primitive self [r] <- []
      end hash
      export function isalpha -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISALPHA" [r] <- []
      end isalpha
      export function isupper -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISUPPER" [r] <- []
      end isupper
      export function islower -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISLOWER" [r] <- []
      end islower
      export function isdigit -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISDIGIT" [r] <- []
      end isdigit
      export function isxdigit -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISXDIGIT" [r] <- []
      end isxdigit
      export function isalnum -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISALNUM" [r] <- []
      end isalnum
      export function isspace -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISSPACE" [r] <- []
      end isspace
      export function ispunct -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISPUNCT" [r] <- []
      end ispunct
      export function isprint -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISPRINT" [r] <- []
      end isprint
      export function isgraph -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISGRAPH" [r] <- []
      end isgraph
      export function iscntrl -> [r : Boolean]
	primitive self "NCCALL" "STRING" "EMCH_ISCNTRL" [r] <- []
      end iscntrl
      export function toupper -> [r : Character]
	primitive self "NCCALL" "STRING" "EMCH_TOUPPER" [r] <- []
      end toupper
      export function tolower -> [r : Character]
	primitive self "NCCALL" "STRING" "EMCH_TOLOWER" [r] <- []
      end tolower
    end aCharacter
      
  end create
end Character

export Character to "Builtins"
