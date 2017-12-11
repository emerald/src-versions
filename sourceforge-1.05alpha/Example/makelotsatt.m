const first <- object first
  initially
    attached var i : Integer <- 1
    attached const limit : Integer <- 1000000
    attached var junk : Any
    loop
      exit when i > limit
      junk <- object junk
	attached var a,b,c,d,e,f,g,h,i,j: Any
      end junk
      i <- i + 1
    end loop
  end initially
end first
