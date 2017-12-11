const tveclit <- object tveclit
  initially
    const t <- { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
    var i : Integer
    for i : Integer <- 0 while i <= t.upperbound by i <- i + 1
      stdout.putint[t[i], 0]
      stdout.putchar[' ']
    end for
    stdout.putchar['\n']
  end initially
end tveclit
