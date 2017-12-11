const tnodeevent <- object tnodeevent
  export operation nodeUp [n : Node, t : Time]
    stdout.putstring["Node up at "||t.asDate||"\n"]
  end nodeUp
  export operation nodeDown [n : Node, t : Time]
    stdout.putstring["Node down at "||t.asDate||"\n"]
  end nodeDown
  process
    (locate self).setNodeEventHandler[self]
    (locate self).delay[Time.create[1000, 0]]
  end process
end tnodeevent
