const die <- class die[delaytime : Integer]
  export operation die
    const junk <- object junk
      process
	(locate self).delay[Time.create[delaytime, 0]]
	(locate self)$stdout.putstring["Dying...\n"]
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end process
    end junk
  end die
end die

const hastry <- typeobject hastry
  operation try [Integer]
end hastry

const target <- object target
  export operation try [n : Integer, other : hastry]
    if n > 0 then
      other.try[n - 1]
    else
      (locate self)$stdout.putstring["Sleeping\n"]
      (locate self).delay[Time.create[10, 0]]
      (locate self)$stdout.putstring["Waking\n"]
    end if
  end try
end target

const main <- object main
  export operation try [n : Integer]
    target.try[n, self]
    unavailable
      stdout.putstring["main.try ["||n.asString||"] caught an unavailable\n"]
    end unavailable
  end try
  process
    const here <- locate self
    const there <- here$activeNodes[1]$theNode
    const dier <- die.create[2]
    move target to there
    move dier to there
    dier.die
    self.try[4]
    unavailable
      stdout.putstring["main.process caught an unavailable\n"]
    end unavailable
  end process
end main
