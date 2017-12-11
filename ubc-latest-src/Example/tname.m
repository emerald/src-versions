const tname <- immutable object tname
  initially
    const y <- "a tname created\n"
    var x : Any
    stdout.putstring[y]
  end initially
  export operation create -> [r : Any]
    r <- object anTname
      initially
	const x <- "a tname instance created\n"
	stdout.putstring[x]
      end initially
    end anTname
  end create
end tname

export tname
