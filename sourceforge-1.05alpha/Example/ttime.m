const ttime <- object ttime
  initially
    var t : Time <- (locate 1).getTimeOfDay
    stdout.putstring[t.asString]
    stdout.putstring[" "]
    stdout.putstring[t.asDate]
    stdout.putstring["\n"]
    t <- t + Time.create[60 * 60 * 3, 0]
    stdout.putstring[t.asString]
    stdout.putstring[" "]
    stdout.putstring[t.asDate]
    stdout.putstring["\n"]
    t <- Time.fromLocal[1996, 1, 6, 9, 0, 0]
    stdout.putstring[t.asString]
    stdout.putstring[" "]
    stdout.putstring[t.asDate]
    stdout.putstring["\n"]
  end initially
end ttime
