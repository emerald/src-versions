const tgc <- object tgc
  initially
    var i : Integer <- 1
    var limit : Integer <- 1000000
    var a : Any
    loop
      exit when i > limit
      i <- i + 1
      a <- object foo end foo
    end loop
  end initially
end tgc
