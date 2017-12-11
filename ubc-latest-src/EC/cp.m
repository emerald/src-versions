
const CP <- class CP  [inputfilename : String, perfile : Boolean]
    const q <- Array.of[CPAble].create[~20]
    var start : Integer
    var indexfilename : String
    var cpfilename : String
    var inf : InStream
    var cpf : OutStream

    export operation CP [x : CPAble]
      var foo : Any
      assert q.upperbound < q.lowerbound
      q.slideTo[start]

      x.getIndex[start, q]
      start <- q.upperbound + 1
      loop
	exit when q.upperbound < q.lowerbound
	q.removeLower.cpoint[cpf]
      end loop
    end CP

    export operation finish 
      if !perfile then
	var outf : OutStream
	begin
	  outf <- OutStream.toUnix[indexfilename, "w"]
	  failure
	    outf <- nil
	  end failure
	end
	if outf == nil then
	  const env : EnvironmentType <- Environment$env
	  env.SemanticError[1, "Can't open output file \"%s\"",{indexfilename}]
	else
	  outf.putint[start, 0]
	  outf.putchar['\n']
	  outf.close
	end if
      end if
      cpf.close
    end finish

    initially
      var mode : String
      if perfile then
	start <- 0
	cpfilename <- self.build[inputfilename, '.', "x"]
	mode <- "w"
      else
	indexfilename <- self.build[inputfilename, '/', "CPIndex"]
	cpfilename <- self.build[inputfilename, '/', "CP"]
	begin
	  inf <- InStream.fromUnix[indexfilename, "r"]
	  failure
	    inf <- nil
	  end failure
	end
	if inf == nil then
	  start <- 0
	else 
	  const s <- inf.getString
	  start <- Integer.literal[s]
	  inf.close
	end if
	mode <- "a"
      end if
      begin
	cpf <- OutStream.toUnix[cpfilename, mode]
	failure
	  cpf <- nil
	end failure
      end
      % chmod 0777 cpfilename
      if cpf == nil then
	const env : EnvironmentType <- Environment$env
	env.SemanticError[1, "Can't open output file \"%s\"",{cpfilename}]
	cpf <- OutStream.toUnix["/dev/null", "w"]
	assert cpf !== nil
      end if
      if perfile then
	const header <- "#!  emx"
	var length : Integer <- header.length # 4
	cpf.putString[header]
	loop
	  exit when length == 3
	  cpf.putchar[' ']
	  length <- length + 1
	end loop
	cpf.putchar['\n']
      end if
    end initially

  operation build [base : String, delim : Character, rest : String]
	       -> [ans : String]
    var i : Integer <- base.length - 1
    loop
      exit when base[i] = delim
      i <- i - 1
      exit when i < 0
    end loop
    if i < 0 then
      ans <- rest
    else
      ans <- base[0, i+1] || rest
    end if
  end build

end CP

export CP
