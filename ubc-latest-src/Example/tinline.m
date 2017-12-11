const invoker <- object invoker
  process
    var y : Integer <- 101
    const target <- object target
      field x : Integer <- y
    end target
    var x : Integer <- target$x
    stdout.putstring["target.x = "]
    stdout.putint[x, 0]
    stdout.putchar['\n']
  end process
end invoker
