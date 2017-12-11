const first <- object first
  initially
    const inside : Integer <- 10000
    const outside : Integer <- 100
    attached var junk : Any
    for i : Integer <- 0 while i < outside by i <- i + 1
      junk <- nil
      for j : Integer <- 0 while j < inside by j <- j + 1
	junk <- object fred
	  attached var a : Any <- junk
	  attached var b,c,d,e,f,g,h,i,j: Any
	end fred
      end for
    end for
  end initially
end first
