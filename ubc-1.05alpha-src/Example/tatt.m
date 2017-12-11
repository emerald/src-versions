const junkone <- object junkone
end junkone
const junktwo <- object junktwo
end junktwo

const tatt <- object tatt
    var x : String <- "Hi there"
    attached var y : String <- "Ho there"
    var a : Integer <- 34
    attached var b : Integer <- 45
    var c : Character <- 'z'
    attached var d : Character <- 'y'
    var e : Any <- junkone
    attached var f : Any <- junktwo
  initially
    const fn <- "EMCP"
    primitive var "CHECKPOINT" [] <- [tatt, fn]
  end initially
  recovery
    stdout.putstring["Recovered\n"]
    stdout.putstring["e is "]
    stdout.putstring[nameof e]
    stdout.putchar['\n']
    stdout.putstring["f is "]
    stdout.putstring[nameof f]
    stdout.putchar['\n']
  end recovery
end tatt
