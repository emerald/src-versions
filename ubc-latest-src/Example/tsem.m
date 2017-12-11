const driver <- object driver
  const s <- Semaphore.create[1]

  const p <- object p
    process
      driver.doit["p"]
    end process
  end p  
  const q <- object q
    process
      driver.doit["q"]
    end process
  end q  
  export operation doit [m : String]
    loop
      s.P
      stdout.putstring[m]
      stdout.putchar['\n']
      stdout.flush
      s.V
      var i : Integer <- 0
      var limit : Integer
      primitive "NCCALL" "RAND" "RANDOM" [limit] <- []
      limit <- limit # 100
      loop
	exit when i > limit
	i <- i + 1
      end loop
    end loop
  end doit
  initially
    var t : Time <- (locate self).getTimeOfDay
    var seed : Integer <- t$microSeconds
    primitive "NCCALL" "RAND" "SRANDOM" [] <- [seed]
  end initially
end driver
