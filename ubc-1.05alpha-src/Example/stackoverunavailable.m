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

const tstack <- object tstack
  const fact <- object fact
    export function orial [n : Integer] -> [r : Integer]
      stdout.putint[n, 0]
      stdout.putchar['\n']
      if n <= 0 then
	r <- 1
	failmove.doit
      else
	r <- n * self.orial[n - 1]
      end if
      stdout.putint[n, 0]
      stdout.putchar['\n']
    end orial
  end fact
  
  initially
    var f1 : Integer
    f1 <- fact.orial[3000]
  end initially
end tstack
