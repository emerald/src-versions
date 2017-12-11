const test <- object test
  process
    const a <- Array.of[String].Literal[{"Hello", "goodbye", "something else"}]
    for i : Integer <- a.lowerbound while i <= a.upperbound by i <- i + 1
      stdout.putstring[a[i]]
      stdout.putchar['\n']
    end for
  end process
end test
