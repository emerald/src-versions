const bar <- object bar
  export operation doit [outf : OutStream]
    outf.putstring["Doin' it.\n"]
  end doit
end bar

const foo <- object foo

	const fn <- "EMCP"
    var a : Any <- self
    initially
      bar.doit[stdout]
      primitive var "CHECKPOINT" [] <- [a, fn]
    end initially
    
    recovery
      self.doit[]
    end recovery

  function getstdout -> [r : OutStream]
    primitive "SYS" "GETSTDOUT" 0 [r] <- []
  end getstdout

  operation doit
    var x : OutStream <- self.getstdout[]
    x.putstring["This is a string.\n"]
    bar.doit[x]
  end doit

end foo
