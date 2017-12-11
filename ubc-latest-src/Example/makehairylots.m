const first <- object first
  initially
    var i : Integer <- 1
    const limit : Integer <- 1000000
    var stuff : Any
    loop
      exit when i > limit
      stuff <- object junk
	var a,b,c,d,e,f,g,h,j,k: Any
	initially
	  if i # 10000 != 0 then
	    a <- stuff
	  end if
	end initially
      end junk
      i <- i + 1
    end loop
  end initially
end first
