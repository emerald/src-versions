const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var all : NodeList
    var stuff : Real <- 1.5
    var other : Integer <- 34

    all <- home.getActiveNodes
    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i]$theNode
      move Kilroy to there
      there$stdout.PutString["Kilroy found 1.5 == " || stuff.asString||"\n"]
      there$stdout.PutString["Kilroy found 34 == " || other.asString||"\n"]
    end for
  end process
end Kilroy
