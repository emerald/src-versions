const target <- object target
  export operation showself
    (locate self)$stdout.putstring["Target is here\n"]
  end showself
  export operation sleep [n : Integer]
    (locate self)$stdout.putstring["sleeping\n"]
    (locate self).delay[Time.create[n, 0]]
    (locate self)$stdout.putstring["waking\n"]
  end sleep
end target

const inter <- object inter
  export operation showself
    (locate self)$stdout.putstring["Inter is here\n"]
  end showself
  export operation doit
    (locate self)$stdout.putstring["Inter invoking target.sleep\n"]
    target.sleep[10]
    (locate self)$stdout.putstring["Inter done with target.sleep\n"]
    failure
      (locate self)$stdout.putstring["target.sleep raised an exception\n"]
      assert false
    end failure
  end doit
end inter

const main <- object main
  process
    const all <- (locate self)$activeNodes
    const one <- all[1]$theNode
    const two <- all[2]$theNode
    move target to one
    target.showself
    const junk <- object junk
      process
	inter.doit
	(locate self)$stdout.putstring["inter.doit returned\n"]
	failure
	  (locate self)$stdout.putstring["inter.doit raised an exception\n"]
	end failure
      end process
    end junk
    (locate self).delay[Time.create[2, 0]]
    (locate self)$stdout.putstring["main moving inter to two\n"]
%   move inter to two
    inter.showself
  end process
end main
