const Remote <- object Remote
  export operation NoParams
  end NoParams
  export operation StringParam[s:String]
  end StringParam
end Remote

const Local <- object Local
  process
    const home <- locate self
    var all : NodeList
    var there : Node

    all <- home.getActiveNodes

%    fix Local at home

    for i : Integer <- 1 while i <= all.upperbound by i <- i + 1
      there <- all[i]$theNode

      home$stdout.PutString["Moving to " || there.getName || ".\n"]
      fix Local at there
      home$stdout.PutString["Moving Remote back to home.\n"]
      fix Remote at home
      home$stdout.PutString["Done move.\n"]
    end for
  end process
end Local
