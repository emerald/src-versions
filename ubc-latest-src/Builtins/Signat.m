% 
% @(#)Signature.m	1.2  3/6/91
%
const Signature <- immutable object signature builtin 0x1009
    const PAT <- immutable typeobject PAT builtin 0x1609
      function getSignature -> [Signature]
      function getFlags -> [Integer]
      function getOps -> [AOpVector]
      function getName -> [String]
      function getFileName -> [String]
      function getIsImmutable -> [Boolean]
      function getIsTypeVariable -> [Boolean]
    end PAT
    export function getSignature -> [result : Signature]
      result <- PAT
    end getSignature
    export operation create [
      pFlags : Integer,
      pops : AOpVector,
      pname : String,
      pfilename : String] -> [r : PAT]
      r <- immutable object aSignature builtin 0x1409
	const flags <- pFlags
	attached const ops <- pops
	attached const name <- pname
	attached const filename <- pfilename
	
	export function getSignature -> [ r : Signature ]
	  primitive self [r] <- []
	end getSignature

	export function getFlags -> [r : Integer]
	  r <- flags
	end getFlags
	export function getOps -> [r : AOpVector]
	  r <- ops
	end getOps
	export function getName -> [r : String]
	  r <- name
	end getName
	export function getFileName -> [r : String]
	  r <- fileName
	end getFileName
	export function getIsTypeVariable -> [r : Boolean]
	  r <- flags.getBit[31]
	end getIsTypeVariable
	export function getIsImmutable -> [r : Boolean]
	  r <- flags.getBit[30]
	end getIsImmutable
      end aSignature
    end create
  end signature

export Signature to "Builtins"
