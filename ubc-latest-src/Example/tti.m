const tti <- object tti
  process
    const t <- (locate self).getTimeOfDay
    const u <- (locate self).getTimeOfDay
    stdout.putstring[t.asString || "\n"]    
    stdout.putstring[u.asString || "\n"]    
    stdout.putstring[(t < u).asString || "\n"]
    stdout.putstring[(t <= u).asString || "\n"]
    stdout.putstring[(t > u).asString || "\n"]
    stdout.putstring[(t >= u).asString || "\n"]
    stdout.putstring[(t = u).asString || "\n"]
    stdout.putstring[(t != u).asString || "\n"]
  end process
end tti
