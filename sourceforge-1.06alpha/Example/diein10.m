const die <- object die
  process
    (locate self).delay[Time.create[10,0]]
    primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
  end process
end die
