% 
% @(#)AOpVectorE.m	1.2  3/6/91
%
const AOpVectorE <- immutable object AOpVectorE builtin 0x101c
  const AOpVectorEType <- typeobject AOpVectorEType builtin 0x161c
    function  getID -> [Integer]
    function  getNArgs -> [Integer]
    function  getNRess -> [Integer]
    function  getIsFunction -> [Boolean]
    function  getName -> [String]
    function  getArguments -> [AParamList]
    function  getResults   -> [AParamList]
  end AOpVectorEType

  export function getSignature -> [ result : Signature ]
    result <- AOpVectorEType
  end getSignature

  export operation create [
    pid : Integer,
    pisFunction : Boolean,
    pname : String,
    parguments : AParamList,
    presults : AParamList] ->  [ n : AOpVectorEType ]

    n <- immutable object aAOpVectorE builtin 0x141c
      const id <- pid
      const isFunction <- pisFunction
      attached const name <- pname
      attached const arguments <- parguments
      attached const results <- presults
      
      export function  getid -> [r : Integer]
	r <- id
      end getid
      export function  getNArgs -> [r : Integer]
	if arguments == nil then
	  r <- 0
	else
	  r <- arguments.upperbound + 1
	end if
      end getNArgs
      export function  getNRess -> [r : Integer]
	if results == nil then
	  r <- 0
	else
	  r <- results.upperbound + 1
	end if
      end getNRess
      export function  getIsFunction -> [r : Boolean]
	r <- IsFunction
      end getIsFunction
      export function  getName -> [r : String]
	r <- name
      end getName
      export function  getArguments -> [r : AParamList]
	r <- arguments
      end getArguments
      export function  getResults -> [r : AParamList]
	r <- results
      end getResults
    end aAOpVectorE
  end create
end AOpVectorE
  
export AOpVectorE to "Builtins"
