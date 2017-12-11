const voi <- Vector.of[Integer]

const ttt <- object ttt
  initially
    const w <- Vector.of[Integer]
    const x <- w.create[5]
    const y <- x[2]
    const z <- y + y

    const a <- Vector.of[Integer]
    const b <- a.create[5]
    const c <- b[2]
    const d <- c + c
  end initially
end ttt
