const create <- object create
  initially
    var t : Any
    for i : Integer <- 0 while i < 10 by i <- i + 1
      const xx <- (i * i).asString
      t <- object t
	initially
	  const s <- i.asString
	  const t <- " "
	  stdout.putstring[s]
	  stdout.putstring[t]
	  stdout.putstring[xx]
	  stdout.putstring[t]
	end initially
      end t
    end for
  end initially
end create
