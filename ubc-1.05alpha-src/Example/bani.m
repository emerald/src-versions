const client <- class client
  process
    primitive "NCCALL" "BANI" "STARTCLIENT" [] <- []
  end process
end client

const server <- object server
  export operation doit [i : Integer, j : Integer] -> [k : Integer]
    primitive "NCCALL" "BANI" "CALLSERVER" [k] <- [i, j]
  end doit

  initially
    primitive "NCCALL" "BANI" "STARTSERVER" [] <- []
  end initially
end server

const stub <- object stub
  export operation invokeServer[a : Integer, b : Integer, c : Integer, d : Integer] -> [e : Integer]
    (locate self).Delay[Time.create[b, 0]]
    e <- server.doit[c, d]
  end invokeServer
  initially
    primitive self "NCCALL" "BANI" "REGISTERCLIENT" [] <- []
  end initially
end stub

const starter <- object starter
  initially
    const c1 <- client.create
    const c2 <- client.create
  end initially
end starter
