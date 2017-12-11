const count <- object count
  initially
    var i : Integer <- 1
    var limit : Integer <- 1000000
    const starttime <- (locate self)$timeOfDay
    loop
      exit when i > limit
      i <- i + 1
    end loop
    const endtime <- (locate self)$timeOfDay
    stdout.putstring["Counting to "||limit.asString||" took "||(endtime-starttime).asString||" seconds\n"]
  end initially
end count
