% 
% @(#)OutStream.m	1.2  3/6/91
%
export OutStream to "Builtins"

const OutStream <- immutable object OutStream builtin 0x1011

  const OutStreamType <- typeobject OutStreamType builtin 0x1611
    operation putChar [Character]
    operation putInt [Integer, Integer]
    operation putReal [ Real ]
    operation putString [ String ]
    operation flush
    operation close
  end OutStreamType

  export function getSignature -> [ r : Signature ]
    r <- OutStreamType
  end getSignature

  export operation toUnix [ fn: String, mode: String ] -> [ r: OutStreamType ]
    var fd: Integer <- -1
    var url: String <- fn
    const m0 : Character <- mode[0]

    if m0 = 'w' then url <- ">" || url
    elseif m0 = 'a' then url <- ">>" || url
    else return end if
    primitive "NCCALL" "EMSTREAM" "EMS_OPEN" [ fd ] <- [ url ]
    if fd >= 0 then r <- self.create[ fd ] end if
  end toUnix

  export operation create [ fd: Integer ] -> [ r: OutStreamType ]
    r <- object aUnixOutStream builtin 0x1411
      export operation putChar[ r: Character ]
	primitive "NCCALL" "EMSTREAM" "EMS_PUTC" [] <- [fd,r]
      end putChar

      export operation putInt [ number: Integer, width: Integer ]
	primitive "NCCALL" "EMSTREAM" "EMS_PUTI" [] <- [fd,number,width]
      end putInt

      export operation writeInt[ r: Integer, size: Integer ]
	primitive "NCCALL" "EMSTREAM" "EMS_WRITEI" [] <- [fd,r,size]
      end writeInt

      export operation putReal[ r: Real ]
	primitive "NCCALL" "EMSTREAM" "EMS_PUTF" 2 [] <- [fd,r]
      end putReal

      export operation putString[ r: String ]
	primitive "NCCALL" "EMSTREAM" "EMS_PUTS" [] <- [fd,r]
      end putString

      export operation flush
	primitive "NCCALL" "EMSTREAM" "EMS_FLUSH" [] <- [fd]
      end flush

      export operation close
	primitive "NCCALL" "EMSTREAM" "EMS_CLOSE" [] <- [fd]
      end close
    end aUnixOutStream
  end create
end OutStream
