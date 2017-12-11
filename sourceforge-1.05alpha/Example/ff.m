const first <- object first
  initially
    var x : Integer <- 5
  end initially
  operation foo [x : Integer]
    var y : Integer
    y <- x
    if y = x then
      y <- x
    end if
    begin
      var z : Integer
      z <- x
    end
    y <- x
    y <- x
  end foo
end first
