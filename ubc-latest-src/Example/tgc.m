const tgc <- object tgc
  initially
    var i : Integer <- 1
    var limit : Integer <- 100000000

    loop
      exit when i > limit
      i <- i + 1
      const a <- object foo
	export operation bar [s : String]
	  var t : String <- s || s
	end bar
      end foo
      a.bar["blah"]
    end loop
  end initially
end tgc
