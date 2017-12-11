const tsto <- object tsto
  const t <- "hi there"
  initially
    const t1 <- syntactictypeof t
    const t2 <- typeof t
    var x : (syntactictypeof t) <- t
    assert t1 *> t2
  end initially
end tsto
