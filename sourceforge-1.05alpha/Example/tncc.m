const tncc <- object tncc
  export operation reallyexit [n : Integer]
    primitive "NCCALL" "MISK" "UEXIT" [] <- [n]
  end reallyexit
  export operation random -> [n : Integer]
    primitive "NCCALL" "RAND" "RANDOM" [n] <- []
  end random
  initially
    self.reallyexit[self.random.abs # 128]
  end initially
end tncc
