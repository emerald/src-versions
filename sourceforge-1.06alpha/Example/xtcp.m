const foo <- object foo
  const output <- stdout
  initially
    var a : Any <- self
    const fn <- "EMCP"
    output.putstring["I have initialized.\n"]
    primitive var "CHECKPOINT" [] <- [a, fn]
  end initially
  
  recovery
    output.putstring["I have recovered.\n"]
  end recovery
end foo
