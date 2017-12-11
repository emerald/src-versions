const die <- class die
  export operation die
    const junk <- object junk
      process
	(locate self).delay[Time.create[1,0]]
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end process
    end junk
  end die
end die

const target <- object target
  export operation sleep [n : Node, t : Time]
    move self to n
    (locate self)$stdout.putstring["Target sleeping\n"]
    (locate self).Delay[t]
  end sleep
end target

const Chain <- object Chain
  process
    const home <- locate self
    var second, third :     Node
    var all : NodeList

    stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    assert all.upperbound + 1 >= 3
    second <- all[1]$theNode
    second$stdout.putstring["Second\n"]
    third <- all[2]$theNode
    third$stdout.putstring["Third\n"]
    stdout.PutString["Moving target to "||second$name||"\n"]
    move target to second
    stdout.PutString["Putting target to sleep for 20\n"]
    const junk <- object junk
      process
	target.sleep[third, Time.create[20, 0]]
	stdout.putstring["Junk's invocation of target returned\n"]
	unavailable
	  stdout.putstring["Junk caught target's death\n"]
	end unavailable
      end process
    end junk
    stdout.PutString["Waiting 2\n"]
    home.Delay[Time.create[2, 0]]
    stdout.PutString["Killing second\n"]
    const dier <- die.create
    move dier to second
    dier.die
    stdout.PutString["Waiting 10\n"]
    home.Delay[Time.create[10, 0]]
%    stdout.PutString["Locating target\n"]
%    const nowat <- locate target
    stdout.PutString["Invoking target\n"]
    target.sleep[nil, Time.create[1, 0]]
    stdout.PutString["All done\n"]
    unavailable
      stdout.putstring["Caught an unavailable\n"]
    end unavailable
  end process
end Chain
