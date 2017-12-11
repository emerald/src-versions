const Decoder <- immutable object Decoder builtin 0x1024
  const DecoderType <- typeobject DecoderType builtin 0x1624
  end DecoderType
  export function getSignature -> [result : Signature]
    result <- DecoderType
  end getSignature

  export function Create [] -> [result : DecoderType]
    result <- object aDecoder builtin 0x1424
      var pad : Integer
      initially
      end initially

      process
	const stdout : OutStream <- (locate 1).getStdout

	var ctl : String <- "STARTSERVER"
	begin
	  primitive "SYS" "DISTCTL" 1 [ ] <- [ ctl ]
	  failure
	    stdout.putString[ "rinvoke server start failed\n" ]
	  end failure
	end
	ctl <- "PING"
	begin
	  primitive "SYS" "DISTCTL" 1 [] <- [ ctl ]
	  failure
	    stdout.putString[ "Can't ping the rootdir node\n" ]
	  end failure
	end
      end process
    end aDecoder
  end Create
end Decoder

export Decoder to "Builtins"


