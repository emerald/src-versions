const movetons <- object movetons
  const movee <- object movee end movee
  const here <- locate self
  const alive <- here.getActiveNodes

  export op doacycle
    for i: Integer <- alive.upperbound while i >= 0 by i <- i - 1
      const thenode <- alive[i]$theNode
      move movee to thenode
    end for
  end doacycle

  process
    loop
      stdout.putstring["> "] stdout.flush const junk <- stdin.getstring
      self.doacycle
    end loop
  end process
end movetons
