const create <- object create
  initially
    var t : Any
    var i : Integer <- 0
    loop
      exit when i >= 100000
      t <- make.create
      i <- i + 1
    end loop
  end initially
end create
