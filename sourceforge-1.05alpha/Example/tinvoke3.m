const target <- object target
  export operation op1 [x : integer] -> [y : integer]
    y <- x + x
  end op1
  export operation op2 [x : integer] -> [y : integer]
    y <- x + x
  end op2
end target

const invoker <- object invoker
  initially
    const t <- 3 * target.op1[5]
    const u <- target.op1[5] * 4
  end initially
end invoker
