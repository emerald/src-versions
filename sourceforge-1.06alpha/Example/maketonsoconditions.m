const first <- monitor object first
  initially
    var i : Integer <- 1
    const limit : Integer <- 1000000
    var junk : Any
    loop
      exit when i > limit
      junk <- Condition.create
      i <- i + 1
    end loop
  end initially
end first
