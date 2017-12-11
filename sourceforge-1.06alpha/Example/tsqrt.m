const tsqrt <- object tsqrt
  process
    const t <- 0.0001
    stdout.putstring["sqrt(" || t.asString || ") = " || (t^0.5).asString || "\n"]
  end process
end tsqrt
