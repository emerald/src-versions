% 
% @(#)IState.m	1.2  3/6/91
%
const InterpreterState <- immutable object InterpreterState builtin 0x101f
  const InterpreterStateType <- typeobject InterpreterStateType builtin 0x161f
    function  getPC -> [ Integer ]
    operation setPC [ Integer ]
    function  getSP -> [ Integer ]
    operation setSP [ Integer ]
    function  getFP -> [ Integer ]
    operation setFP [ Integer ]
    function  getSB -> [ Integer ]
    operation setSB [ Integer ]
    function  getO -> [ Any ]
    operation setO [ Any ]
    function  getE -> [ Any ]
    operation setE [ Any ]
  end InterpreterStateType

  export function getSignature -> [ result : Signature ]
    result <- InterpreterStateType
  end getSignature
  export operation create [
    xpc : Integer,
    xsp : Integer,
    xfp : Integer,
    xsb : Integer,
    xo  : Any,
    xe  : Any]
  -> [ n : InterpreterStateType ]
    n <- object anInterpreterState builtin 0x141f
	var pc : Integer <- xpc
	var sp : Integer <- xsp
	var fp : Integer <- xfp
	var sb : Integer <- xsb
	var o  : Any <- xo
	var e  : Any <- xe
	export function  getPC -> [r : Integer]
	  r <- pc
	end getPC
	export operation setPC [r : Integer]
	  pc <- r
	end setPC
	export function  getSP -> [r : Integer]
	  r <- sp
	end getSP
	export operation setSP [r : Integer]
	  sp <- r
	end setSP
	export function  getFP -> [r : Integer]
	  r <- fp
	end getFP
	export operation setFP [r : Integer]
	  fp <- r
	end setFP
	export function  getSB -> [r : Integer]
	  r <- sb
	end getSB
	export operation setSB [r : Integer]
	  sb <- r
	end setSB
	export function  getO -> [r : Any]
	  r <- o
	end getO
	export operation setO [r : Any]
	  o <- r
	end setO
	export function  getE -> [r : Any]
	  r <- e
	end getE
	export operation setE [r : Any]
	  e <- r
	end setE
    end anInterpreterState
  end create
end InterpreterState

export InterpreterState to "Builtins"
