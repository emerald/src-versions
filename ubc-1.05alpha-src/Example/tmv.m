const Kilroy <- object Kilroy
  const target <- Vector.of[Character].create[1024]

  operation killEmerald 
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end killEmerald

  process
    const home <- locate self
    var there :     Node
    var all : NodeList

    all <- home.getActiveNodes
    for hi : Integer <- 1 while hi <= all.upperbound by hi <- hi + 1
      there <- all[hi]$theNode
      stdout.putstring["Moving target to " || there$name || "\n"]
      move target to there
      stdout.putstring["Moving target from " || there$name || " back home\n"]
      move target to home
    end for
    self.killEmerald
  end process
end Kilroy
