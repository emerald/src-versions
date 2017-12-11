const first <- object first
  initially
    var i : Integer <- 1
    const limit : Integer <- 1000000
    var junk : Any
    loop
      exit when i > limit
      junk <- object junk
	var a,b,c,d,e,f,g,h,i,j: Any
      end junk
      i <- i + 1
    end loop
  end initially
end first
