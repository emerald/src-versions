const tfailloop <- object tfailloop
  process
    var i : Integer <- 0
    loop
      begin
	exit when i == 10
	failure
	  exit
	end failure
      end
      i <- i + 1
    end loop
  end process
end tfailloop
