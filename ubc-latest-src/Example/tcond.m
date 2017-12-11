const o1 <- monitor object o1
  const mycondition <- Condition.create
  export operation getC -> [r : Condition]
    r <- mycondition
  end getC
end o1

const o2 <- monitor object o2
  operation w [x : Condition]
    const y <- awaiting x
    signal x
    wait x
  end w
  initially
    self.w[o1.getC]
  end initially
end o2
