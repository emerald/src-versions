const tload <- object tload
  initially
    var s : String
    loop
      if stdin.isatty then stdout.putstring["filename: "] stdout.flush end if
      exit when stdin.eos
      s <- stdin.getString
      if s.length > 1 then
	s <- s.getSlice[0, s.length - 1]
	exit when s = "q" or s = "quit"
	for i : Integer <- 0 while i < 100 by i <- i + 1
	  primitive "DLOAD" [] <- [s]
	  primitive "GCOLLECT" [] <- []
	end for
      end if
    end loop
  end initially
end tload
