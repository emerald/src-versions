const tg <- object tg
  process
    const here <- locate self
    const all <- here$activeNodes
    const rd <- here$rootDirectory
    var startTime, endTime : Time

    here.delay[Time.create[1, 0]]

    var g : DirectoryGaggle <- view rd.lookup["dg"] as DirectoryGaggle
    if g == nil then
      g <- DirectoryGaggle.create
      rd.insert["dg", g]
    end if
    const myd <- L_Directory.create
    g.instantiate[myd]

    stdout.putstring["There are "||(all.upperbound+1).asString||" nodes up\n"]
    stdout.putstring["There are "||(g.upperbound+1).asString||" gaggle members\n"]

    here.delay[Time.create[1, 0]]
    const nlookups <- 1000
    startTime <- here$timeOfDay
    var i : Integer <- 0
    loop
      const foo <- myd.lookup["0"]
      i <- i + 1
      exit when i = nlookups
    end loop
    endTime <- here$timeOfDay

    stdout.putstring[nlookups.asString||" local lookups took "||(endTime - startTime).asString||" seconds\n"]

    here.delay[Time.create[1, 0]]
    startTime <- here$timeOfDay
    i <- 0
    loop
      const foo <- g.lookup["0"]
      i <- i + 1
      exit when i = nlookups
    end loop
    endTime <- here$timeOfDay

    stdout.putstring[nlookups.asString||" gaggle lookups took "||(endTime - startTime).asString||" seconds\n"]

    here.delay[Time.create[1, 0]]
    const ninserts <- 1000
    startTime <- here$timeOfDay
    i <- 0
    loop
      g.insert["0", "junk"]
      i <- i + 1
      exit when i = ninserts
    end loop
    endTime <- here$timeOfDay

    stdout.putstring[ninserts.asString||" inserts took "||(endTime - startTime).asString||" seconds\n"]
  end process
end tg
