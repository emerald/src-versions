const tg <- object tg
  process
    const here <- locate self
    const rd <- here$rootDirectory
    var g : DirectoryGaggle <- view rd.lookup["dg"] as DirectoryGaggle
    if g == nil then
      g <- DirectoryGaggle.create
      rd.insert["dg", g]
    end if
    const myd <- LDirectory.create[g]
%   here.delay[Time.create[1, 0]]
    var i : Integer <- 0
    loop
      const foo <- myd.lookup[i.asString]
      if foo == nil then
      	stdout.putstring["Inserted me as "||i.asString||"\n"]
	myd.insert[i.asString, here$name]
	exit
      else
      	stdout.putstring["Found "||i.asString||" busy\n"]
      end if
      i <- i + 1
    end loop
    i <- 0
    loop
      const foo <- myd.lookup[i.asString]
      if foo == nil then
      	stdout.putstring["That is all!\n"]
	exit
      else
	stdout.putstring[i.asString || " -> " || (view foo as String) || "\n"]
      end if
      i <- i + 1
    end loop
  end process
end tg
