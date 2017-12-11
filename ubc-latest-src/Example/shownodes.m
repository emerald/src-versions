const shownodes <- object shownodes
  process
    const here <- locate self
    const all <- here$activeNodes
    for i : Integer <- 0 while i <= all.upperbound by i <- i + 1
      const anode <- all[i]
      if anode$theNode == here then
	stdout.putstring["-> "]
      else
	stdout.putstring["   "]
      end if
	
      stdout.putstring["Node on machine named "]
      stdout.putstring[anode$theNode$name]
      stdout.putstring["\n      up since "]
      stdout.putstring[anode$incarnationTime.asDate]
      stdout.putstring["\n      lnn "]
      stdout.putint[anode$lnn / 65536, 0]
      stdout.putchar[' ']
      stdout.putint[anode$lnn # 65535, 0]
      stdout.putchar['\n']
    end for
  end process
end shownodes
