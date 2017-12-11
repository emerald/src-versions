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
    const x <- target.op2[5]
    const t <- target.op1[x]
  end initially
end invoker
