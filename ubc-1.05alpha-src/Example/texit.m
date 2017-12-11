const texit <- object texit
  initially
    var v : Integer <- 23
    primitive "NCCALL" "MISK" "UEXIT" [] <- [v]
    stdout.putstring["This is a string\n"]
  end initially
end texit
