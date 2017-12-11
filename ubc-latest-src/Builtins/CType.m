% 
% @(#)ConcreteType.m	1.2  3/6/91
%
const ConcreteType <- immutable object ConcreteType builtin 0x1018
  const ConcreteTypeType <- typeobject ConcreteTypeType builtin 0x1618
    function  getInstanceSize -> [Integer]
    function  getInstanceFlags -> [Integer]
    function  getOps -> [COpVector]
    function  getName -> [String]
    function  getFileName -> [String]
    function  getTemplate -> [String]
    function  getType -> [Signature]
    function  getLiterals -> [ImmutableVectorOfInt]
  end ConcreteTypeType

  export function getSignature -> [ result : Signature ]
    result <- ConcreteTypeType
  end getSignature
  export operation create [
    pinstanceSize : Integer,
    pinstanceFlags : Integer,
    pops : COpVector,
    pname : String,
    pfilename : String,
    ptemplate : String,
    pmytype : Signature,
    pLiterals : ImmutableVectorOfInt] ->  [ n : ConcreteTypeType ]

    n <- immutable object aConcreteType builtin 0x1418
      const instanceSize <- pinstanceSize
      const instanceFlags <- pinstanceFlags
      attached const ops <- pops
      attached const name <- pname
      attached const filename <- pfilename
      attached const template <- ptemplate
      attached const mytype <- pmytype
      attached const literals <- pLiterals
      
      export function  getInstanceSize -> [r : Integer]
	r <- instanceSize
      end getInstanceSize
      export function  getInstanceFlags -> [r : Integer]
	r <- instanceFlags
      end getInstanceFlags
      export function  getOps -> [r : COpVector]
	r <- ops
      end getOps
      export function  getName -> [r : String]
	r <- name
      end getName
      export function  getFileName -> [r : String]
	r <- fileName
      end getFileName
      export function  getTemplate -> [r : String]
	r <- template
      end getTemplate
      export function  getType -> [r : Signature]
	r <- mytype
      end getType
      export function  getLiterals -> [r : ImmutableVectorOfInt]
	r <- literals
      end getLiterals
    end aConcreteType
  end create
end ConcreteType
  
export ConcreteType to "Builtins"
