const target <- class target
  export operation die
    const junk <- object junk
      process
	(locate self).delay[Time.create[3, 0]]
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end process
    end junk
  end die
end target

const first <- object first
  process
    const here <- locate self
    const nodes <- here$activeNodes
    stdout.putstring["Found "||(nodes.upperbound + 1).asString||" nodes\n"]
    for i : Integer <- 1 while i <= nodes.upperbound by i <- i + 1
      const atarget <- target.create
      move atarget to nodes[i]$theNode
      atarget.die
    end for
    target.create.die
    unavailable

    end unavailable
  end process
end first
