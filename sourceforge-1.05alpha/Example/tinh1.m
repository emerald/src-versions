const base <- class base
  const pi1 <- "pi1"
  const pmi1 <- "pmi1"
  export operation pmo1 -> [r : String]
    r <- "pmo1"
  end pmo1
  export operation pmo2 -> [r : String]
    r <- "pmo2"
  end pmo2

  export operation po1 -> [r : String]
    r <- "po1"
  end po1
  export operation po2 -> [r : String]
    r <- "po2"
  end po2
end base

export base to "Whocares"
