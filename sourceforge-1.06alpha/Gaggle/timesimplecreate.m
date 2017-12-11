const timesimplecreate <- object timesimplecreate
  process
    const here <- locate self
    const all <- here$activeNodes
    const rd <- here$rootDirectory
    var startTime, endTime : Time

    here.delay[Time.create[1, 0]]

    var g : RepIntGaggle <- view rd.lookup["rig"] as RepIntGaggle
    if g == nil then
      g <- RepIntGaggle.create
      rd.insert["rig", g]
    end if


    stdout.putstring["There are "||(all.upperbound+1).asString||" nodes up\n"]

    here.delay[Time.create[1, 0]]

    const ncreates <- 1000
    startTime <- here$timeOfDay
    var i : Integer <- 0
    loop
      const foo <- RepInt.create[g]
      i <- i + 1
      exit when i = ncreates
    end loop
    endTime <- here$timeOfDay

    stdout.putstring[ncreates.asString||" creates took "||(endTime - startTime).asString||" seconds\n"]
    stdout.putstring["There are "||(g.upperbound+1).asString||" gaggle members\n"]

  end process
end timesimplecreate
