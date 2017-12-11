const x <- class x[v : Integer]
  var i : Integer <- v
  export operation inc
    i <- i + 1
  end inc
  export function value -> [r : Integer]
    r <- i
  end value
end x

const y <- object y
  initially
    var xx : x
    var yy : Any
    xx <- x.create[99]
    yy <- codeof xx
    xx <- new yy[43]
    stdout.putint[xx.value, 0]
    stdout.putchar['\n']
    xx.inc
    xx.inc
    stdout.putint[xx.value, 0]
    stdout.putchar['\n']
  end initially
end y
