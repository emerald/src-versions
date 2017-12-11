const Movee <- object Movee
  export operation moveTo[loc : Node]
    (locate self)$stdout.PutString["Am on " || (locate self)$name || "\n"]
    move Movee to loc
    (locate self)$stdout.PutString["Moved to " || (locate self)$name || "\n"]
  end moveTo
end Movee

const Kilroy <- object Kilroy
  process
    const home <- locate self
    var there :     Node
    var startTime, diff : Time
    var all : NodeList
    var theElem :NodeListElement
    var stuff : Real

    home$stdout.PutString["Starting on " || home$name || "\n"]
    all <- home.getActiveNodes
    home$stdout.PutString[(all.upperbound + 1).asString || " nodes active.\n"]
    startTime <- home.getTimeOfDay
    var i : Integer <- 0
    move movee to all[1]$theNode
    Movee.moveTo[home]
  end process
end Kilroy
