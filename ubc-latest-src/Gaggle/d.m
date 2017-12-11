const mag <- object mag
	
process
	var c: Directory<-Directory.create
	var s: Any

	c.insert["mag", "she"];
	s <- c.lookup["ma"] 
	if s == nil then
	 (locate self)$stdout.Putstring["hip\n"]
	else
	 (locate self)$stdout.Putstring["hurray\n"]
	end if
	
end process
end mag	