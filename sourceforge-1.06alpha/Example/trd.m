const trd <- object trd
  initially
    var d : Directory <- object aUnixDirectory
	var name : String
	var value : Any
	
	export operation insert [n : String, v : Any]
	  name <- n
	  value <- v
	end insert

	export operation delete [n : String]
	  if name = n then
	    name <- nil
	    value <- nil
	  end if
	end delete

	export function lookup [n : String] -> [v : Any]
	  if n = name then 
	    v <- value
	  end if
	end lookup
    end aUnixDirectory

    var a : Any
    var s : String
    const n <- locate 1
    d.insert["abc", "def"]
    a <- d.lookup["abc"]
    s <- view a as String
    stdout.putstring[s]
    stdout.putchar['\n']
    n.setrootdirectory[d]
    assert n.getrootdirectory == d
  end initially
end trd
