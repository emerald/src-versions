const timef <- object timef
  process
    const t1 <- (locate self).getTimeOfDay
    (locate self).delay[Time.create[1, 0]]
    const t2 <- (locate self).getTimeOfDay
    const diff <- t2 - t1
    const f <- diff$seconds.asReal + diff$microseconds.asReal / 1000000.0
    stdout.putstring["Diff = " || diff.asString || " or " || f.asString || "\n"]
  end process
end timef
