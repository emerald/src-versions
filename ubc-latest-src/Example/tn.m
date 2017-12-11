const tn <- object tn
  initially
    const here <- locate 1
    for i : Integer <- 0 while i < 1 by i <- i + 1
      const now <- here.gettimeofday
      stdout.putstring[now.asDate]
      stdout.putchar['\n']
    end for
  end initially
end tn
