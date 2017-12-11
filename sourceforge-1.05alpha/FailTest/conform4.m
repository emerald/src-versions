const set <- immutable object set
  export function of [t : Type] -> [r : X]
    suchthat t *> typeobject t function = [t] -> [Boolean] end t
    where X <- typeobject X
      operation empty -> [Y]
    end X
    where Y <- typeobject Y
      function = [Y] -> [Boolean]
    end Y
    r <- immutable object aSetCreator
      export operation empty -> [r : Y]
	r <- object aSet
	  export function = [other : Y] -> [r : Boolean]
	    r <- true
	  end =
	end aSet
      end empty
    end aSetCreator
  end of
end set

const test <- object test
  process
    const t <- set.of[Integer] % this should be ok
    const u <- set.of[34]      % this should fail
  end process
end test
