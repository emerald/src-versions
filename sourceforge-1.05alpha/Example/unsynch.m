const unsynch <- object unsynch
  initially
    const limit <- 5
    const hi <- object hi
      process
	for i : Integer <- 0 while i < limit by i <- i + 1
	  stdout.putstring["Hi\n"]
	end for
	stdout.putString["Hi'er done\n"]
      end process
    end hi
    const ho <- object ho
      process
	for i : Integer <- 0 while i < limit by i <- i + 1
	  stdout.putstring["Ho\n"]
	end for
	stdout.putString["Ho'er done\n"]
      end process
    end ho
  end initially
end unsynch
