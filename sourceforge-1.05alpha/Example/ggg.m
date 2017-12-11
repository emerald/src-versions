const Gaggle <- immutable object Gaggle
  export function of [etype : Type] -> [r : rt]
    forall etype
    suchthat etype *> typeobject t end t
    where rt <- typeobject rt
      function getSignature -> [Signature]
      operation create -> [rtt]
    end rt
    where rtt <- typeobject rtt
      operation addmember[etype]
    end rtt
    r <- immutable object stuff
      const stuffsig <- typeobject stuffsig
	operation addmember[etype]
      end stuffsig
      export function getSignature -> [r : Signature]
	r <- stuffsig
      end getSIgnature
      export operation create -> [r : stuffsig]
	r <- object astuff
	  export operation addmember[v : etype]
	  end addmember
	end astuff
      end create
    end stuff
  end of
end Gaggle

const gd <- Gaggle.of[Directory]
export gd
