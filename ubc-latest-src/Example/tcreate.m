const foo <- object foo
  initially
    var x : Integer <- 1
    var bar : Any
    loop
      exit when x > 5
      bar <- object bar
	const y : Integer <- x
      end bar
      x <- x + 1
    end loop
  end initially
end foo
