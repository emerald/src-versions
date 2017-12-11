const tsto <- object tsto
  var x : Any
  initially
    var i : Integer <- 1
    var limit : Integer <- 10
    loop
      exit when i > limit
      i <- i + 1
      x <- object foo end foo
    end loop
  end initially
end tsto
