const foo <- object foo
  var a : Any <- self
  const fn <- "EMCP"
  initially
    var x : OutStream
    primitive "SYS" "GETSTDOUT" 0 [x] <- []

    x.putstring["I have initialized.\n"]
    primitive var "CHECKPOINT" [] <- [a, fn]
  end initially
  recovery
    var x : OutStream
    primitive "SYS" "GETSTDOUT" 0 [x] <- []

    x.putstring["I have recovered.\n"]
  end recovery
end foo
