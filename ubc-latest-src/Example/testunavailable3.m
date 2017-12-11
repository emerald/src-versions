const failmove <- object failmove
  export operation doit
    var here : Node <- locate self
    var alive : NodeList <- here.getActiveNodes
    const one <- Time.create[1, 0]

    const place <- alive[1]$theNode
    move self to place
    here <- locate self
    here$stdout.putstring["Kill this node now\n"]
    here.Delay[Time.create[100, 0]]
    unavailable
      (locate self)$stdout.putstring["Node unavailable\n"]
    end unavailable
  end doit
end failmove

const driver <- object driver
  process
    failmove.doit
    unavailable
      stdout.putstring["Driver caught an unavailable\n"]
    end unavailable
  end process
end driver
