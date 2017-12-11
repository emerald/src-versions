const tload <- object tload
  initially
    var s : String <- "first.x"
    primitive "DLOAD" [] <- [s]
  end initially
end tload
