const tstr <- object tstr
  initially
    var x : String
    var i : Integer
    var limit : Integer <- 1000000
    i <- 1
    loop
      exit when i > limit
      x <- "abc"
      i <- i + 1
    end loop
  end initially
end tstr
