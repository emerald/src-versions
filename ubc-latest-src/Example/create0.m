const make <- immutable object make
  export operation create -> [r : Any]
    r <- object t
      initially
	const x <- 3
      end initially
    end t
  end create
end make

export make
