const trandom <- object trandom
  export operation random -> [n : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [n] <- []
  end random
  export operation srandom
    const here <- locate self
    const now <- here$timeofday
    const usec <- now$microseconds
    primitive "NCCALL" "RAND" "SRANDOM" [] <- [usec]
  end srandom
  initially
    self.srandom
    for i : Integer <- 0 while i < 10 by i <- i + 1
      stdout.putint[self.random.abs # 100, 0]
      stdout.putchar['\n']
    end for
  end initially
end trandom
