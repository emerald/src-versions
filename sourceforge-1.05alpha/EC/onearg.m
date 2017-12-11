export OneArg

const onearg <- immutable object OneArg
  const x <- 1
  export operation create[a : Tree] -> [r : Tree]
    r <- seq.create[a$ln]
    r.rcons[a]
  end create
end OneArg
