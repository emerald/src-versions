% 
% @(#)COpVectorE.m	1.2  3/6/91
%
const COpVectorE <- immutable object COpVectorE builtin 0x101a
  const COpVectorEType <- typeobject COpVectorEType builtin 0x161a
    function  getID -> [Integer]
    function  getNArgs -> [Integer]
    function  getNRess -> [Integer]
    function  getName -> [String]
    function  getTemplate -> [String]
    function  getCode -> [String]
  end COpVectorEType

  export function getSignature -> [ result : Signature ]
    result <- COpVectorEType
  end getSignature

  export operation create [
    pid : Integer,
    pNArgs : Integer,
    pNRess : Integer,
    pname : String,
    ptemplate : String,
    pcode : String] ->  [ n : COpVectorEType ]

    n <- immutable object aCOpVectorE builtin 0x141a
      const id <- pid
      const NArgs <- pNArgs
      const NRess <- pNRess
      attached const name <- pname
      attached const template <- ptemplate
      attached const code <- pcode
      
      export function  getid -> [r : Integer]
	r <- id
      end getid
      export function  getNArgs -> [r : Integer]
	r <- NArgs
      end getNArgs
      export function  getNRess -> [r : Integer]
	r <- NRess
      end getNRess
      export function  getName -> [r : String]
	r <- name
      end getName
      export function  getTemplate -> [r : String]
	r <- template
      end getTemplate
      export function  getCode -> [r : String]
	r <- code
      end getCode
    end aCOpVectorE
  end create
end COpVectorE
  
export COpVectorE to "Builtins"
