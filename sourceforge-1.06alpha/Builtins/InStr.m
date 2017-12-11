% InStr.m - modified from stock version to use CCALLS
%		by Brian Edmonds <edmonds@cs.ubc.ca> 94Nov05

export InStream to "Builtins"

const InStream <- immutable object InStream builtin 0x1010

  const InStreamType <- typeobject InStreamType builtin 0x1610
    operation getChar -> [Character]
    operation unGetChar [ Character ]
    operation getString -> [ String ]
    function eos -> [Boolean]
    operation close
    function isATty -> [Boolean]
    operation fillVector [VectorOfChar] -> [Integer]
    operation rawRead [VectorOfChar] -> [Integer]
  end InStreamType

  export function getSignature -> [ r : Signature ]
    r <- InStreamType
  end getSignature

  export operation fromUnix[ fn: String, mode: String ] -> [ r: InStreamType ]
    var fd: Integer <- -1
    var url: String <- fn

    if mode[0] != 'r' then return
    elseif mode = "r+" or mode = "rb+" then url <- "+<" || url
    else url <- "<" || url
    end if
    primitive "NCCALL" "EMSTREAM" "EMS_OPEN" [fd] <- [url]
    if fd >= 0 then r <- self.create[fd] end if
  end fromUnix

  export operation create [ fd: Integer ] -> [ r: InStreamType ]
    r <- object aUnixInStream builtin 0x1410
      export operation unGetChar[ c: Character ]
	primitive "NCCALL" "EMSTREAM" "EMS_UNGETC" [] <- [fd,c]
      end unGetChar

      export operation getChar -> [ c: Character ]
	primitive "NCCALL" "EMSTREAM" "EMS_GETC" [c] <- [fd]
      end getChar

      export operation getString -> [ s: String ]
	primitive "NCCALL" "EMSTREAM" "EMS_GETS" [s] <- [fd]
      end getString

      export function eos -> [ r: Boolean ]
	primitive "NCCALL" "EMSTREAM" "EMS_EOS" [r] <- [fd]
      end eos

      export operation close 
	primitive "NCCALL" "EMSTREAM" "EMS_CLOSE" [] <- [fd]
      end close

      export function isATty -> [ r: Boolean ]
	primitive "NCCALL" "EMSTREAM" "EMS_ISATTY" [r] <- [fd]
      end isATty

      export operation fillVector[ v: VectorOfChar ] -> [ len: Integer ]
	primitive "NCCALL" "EMSTREAM" "EMS_FILLV" [len] <- [fd,v]
      end fillVector

      export operation rawRead[ v: VectorOfChar ] -> [ len: Integer ]
	primitive "NCCALL" "EMSTREAM" "EMS_RAWREAD" [len] <- [fd,v]
      end rawRead

    end aUnixInStream
  end create
end InStream

% EOF
