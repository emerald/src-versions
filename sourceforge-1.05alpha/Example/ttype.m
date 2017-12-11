const ttype <- object ttype
  export op funny[a : Type, b : a]
    forall a
    suchthat
      a *> typeobject hasequals
	function = [hasequals] -> [Boolean]
      end hasequals
      stdout.putstring[(b = b).asString||"\n"]
  end funny
end ttype

const driver <- object driver
  initially
    ttype.funny[Integer, 45]
  end initially
end driver
