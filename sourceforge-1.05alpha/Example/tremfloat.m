const first <- object first
  const target <- object target
    export operation addfloat[a : Real] -> [b : Real]
      b <- a + 1.0
    end addfloat
  end target
  process
    const here <- locate self
    const nodes <- here$activeNodes
    move target to nodes[nodes.upperbound]$theNode
    for i : Integer <- 0 while i < 10 by i <- i + 1
      const arg <- i.asReal + i.asReal / 10.0
      const res <- target.addfloat[arg]
      stdout.putstring["Remote " || arg.asString || " + 1.0 = " || res.asString || "\n"]
    end for
    here.Delay[Time.create[1, 0]]
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end process
end first
