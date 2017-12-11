% 
% @(#)String.m	1.2  3/6/91
%
export String to "Builtins"

const String <- immutable object String builtin 0x100b

  const StringType <- immutable typeobject StringType builtin 0x160b
    function getElement [index : Integer] -> [e : Character]
    function getSlice [lb : Integer, length : Integer] -> [a : String]
    function getElement [lb : Integer, length : Integer] -> [a : String]
    function || [o : String] -> [r : String]
      % r <- self || o
    function asString -> [r : String]
      % r <- self
    function > [o : String] -> [r : Boolean]
      % r <- self > o
    function >= [o : String] -> [r : Boolean]
      % r <- self >= o
    function < [o : String] -> [r : Boolean]
      % r <- self < o
    function <= [o : String] -> [r : Boolean]
      % r <- self <= o
    function = [o : String] -> [r : Boolean]
      % r <- self = o
    function != [o : String] -> [r : Boolean]
      % r <- self != o
    function lowerbound -> [Integer]
    function upperbound -> [Integer]
    function length -> [ r : Integer ]
    operation lowlevelobsolete [Integer, Character]
    function hash -> [Integer]
    function index[ch : Character] -> [r : Integer]
    function rindex[ch : Character] -> [r : Integer]
    function span[s : String] -> [r : Integer]
    function cspan[s : String] -> [r : Integer]
    function str[s : String] -> [r : Integer]
    operation token[String] -> [String, String]
  end StringType
  export function getSignature -> [result : Signature]
    result <- StringType
  end getSignature
  
  export function literal [rep : RISC, offset : Integer, length : Integer] 
    -> [result : StringType]
    var strindex, repindex, limit : Integer
    var repvalue : Character
    if rep.lowerbound + offset + length > rep.upperbound + 1 then
      returnandfail
    end if
    result <- String.create[length]
    strindex <- 0
    repindex <- rep.lowerbound + offset
    
    limit <- length
    loop
      exit when strindex >= limit
      repvalue <- rep[repindex]
      primitive "SET" [] <- [result, strindex, repvalue]
      strindex <- strindex + 1
      repindex <- repindex + 1
    end loop
  end literal
  export operation FLiteral[rep : VectorOfChar, offset : Integer, length : Integer] -> [r : StringType]
    primitive "STRLIT" [r] <- [rep, offset, length]
  end FLiteral
  export operation create[length : Integer] -> [result : StringType]
    result <- immutable object aString builtin 0x140b

      export function getElement [index : Integer] -> [e : Character]
	primitive self "GET" [e] <- [index]
      end getElement
      export function getSlice [lb : Integer, length : Integer] -> [a : String]
	primitive self "GSLICE" [a] <- [lb, length]
      end getSlice
      export function getElement[lb : Integer,length : Integer] -> [a : String]
	primitive self "GSLICE" [a] <- [lb, length]
      end getElement
      export function || [o : String] -> [r : String]
	primitive self "CAT" [r] <- [o]
      end ||
      export function asString -> [r : String]
	primitive self [r] <- []
      end asString
      export function > [o : String] -> [r : Boolean]
	primitive self  "SCMP" "GT" [r] <- [o]
      end >
      export function >= [o : String] -> [r : Boolean]
	primitive self  "SCMP" "GE" [r] <- [o]
      end >=
      export function < [o : String] -> [r : Boolean]
	primitive self  "SCMP" "LT" [r] <- [o]
      end <
      export function <= [o : String] -> [r : Boolean]
	primitive self  "SCMP" "LE" [r] <- [o]
      end <=
      export function = [o : String] -> [r : Boolean]
	primitive self  "SCMP" "EQ" [r] <- [o]
      end =
      export function != [o : String] -> [r : Boolean]
	primitive self  "SCMP" "NE" [r] <- [o]
      end !=
      export function lowerbound -> [ r : Integer ]
	primitive "LDIB" 0 [r] <- []
      end lowerbound
      export function upperbound -> [ r : Integer ]
	primitive self "UPB" [r] <- []
      end upperbound
      export function length -> [ r : Integer ]
	primitive self "LEN" [r] <- []
      end length
      export operation lowlevelobsolete [i : Integer, c : Character]
	assert false
      end lowlevelobsolete
      export function hash -> [r : Integer]
	primitive self "STRHASH" [r] <- []
      end hash
      export function index[ch : Character] -> [r : Integer]
	primitive self "NCCALL" "STRING" "EMST_INDEX" [r] <- [ch]
      end index
      export function rindex[ch : Character] -> [r : Integer]
	primitive self "NCCALL" "STRING" "EMST_RINDEX" [r] <- [ch]
      end rindex
      export function span[s : String] -> [r : Integer]
	primitive self "NCCALL" "STRING" "EMST_SPAN" [r] <- [s]
      end span
      export function cspan[s : String] -> [r : Integer]
	primitive self "NCCALL" "STRING" "EMST_CSPAN" [r] <- [s]
      end cspan
      export function str[s : String] -> [r : Integer]
	primitive self "NCCALL" "STRING" "EMST_STR" [r] <- [s]
      end str
      export operation token[s : String] -> [token : String, rest : String]
	primitive self "STRTOK" [token, rest] <- [s]
      end token
    end aString
  end create
end String
