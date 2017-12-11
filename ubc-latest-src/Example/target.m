% target.m - provide a target for remote invocations

const target <- object target

  export operation noop10 [ s : String ]
    
  end noop10

  export operation noop01 -> [ s : String ]
    s <- "abc" || "."
  end noop01

  export operation noop11 [ s : String ] -> [t : String]
    t <- s || "."
  end noop11

  export operation noop
  end noop

  initially
    const here <- locate self
    
    var rootdir : Directory
    rootdir <- here.getrootdirectory
    if rootdir.lookup["target"] == nil then
      rootdir.insert["target", target]
      stdout.putstring["Inserted my target as /target\n"]
    end if
  end initially
end target
