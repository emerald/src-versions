const main <- object main
  process
    for i : Integer <- 0 while i < 10 by i <- i + 1
      const junk <- object boring
	const me <- i
	export function whoami -> [r : Integer]
	  r <- me
	end whoami
	process
	  loop
	    stdout.putint[me, 0]
	    stdout.putchar['\n']
	  end loop
	end process
      end boring
    end for
  end process
end main
