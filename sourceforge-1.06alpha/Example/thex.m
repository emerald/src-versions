const thex <- object thex
  initially
    const x <- 0xaBcDeF
    var y, z : Integer <- 37
    stdout.putint[x, 0]
    stdout.putchar['\n']
    stdout.putint[y, 0]
    stdout.putchar['\n']
    stdout.putint[z, 0]
    stdout.putchar['\n']
    loop
      const x <- object x
	initially
	  exit
	end initially
      end x
    end loop
  end initially
end thex
