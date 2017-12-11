const tccp <- class tccp
  class const x <- 1
  class export operation hairy end hairy
end tccp

const tccc <- class tccc (tccp)
  class const y <- 2
  class const x <- 3
  class export operation sally end sally
end tccc

const junk <- object junk
  process
    const t <- tccc.create
    tccc.hairy
    tccc.sally
  end process
end junk
