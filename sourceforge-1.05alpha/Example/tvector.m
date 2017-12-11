const voxxx <- Vector.of[Integer]
const voi <- Vector.of[Integer]

const t <- object t
  initially
    const limit <- 10
    const x <- voi.create[limit]
    var j : Integer
    var s : String
    var i : Integer
    i <- 0
    loop
      exit when i >= limit
      x[i] <- i * i
      stdout.putint[x[i], 11]
      stdout.putchar['\n']
      i <- i + 1
    end loop
  end initially
end t
