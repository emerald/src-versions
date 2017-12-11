
export InvocCache

const InvocCache <- immutable object InvocCache
  const table <- SIIIATable.create[64]

  export operation load [fn : String]
    const nfn <- fn || ".idb"
    var f : InStream
    var input, first, second, third, fourth, fifth : String
    var id, codeid, instcodeid : Integer
    table.reset
    begin
      f <- InStream.fromUnix[nfn, "r"]
      failure
       f <- nil
      end failure
    end
    if f !== nil then
      loop
	begin
	  input <- f.getString
	  failure
	    input <- nil
	  end failure
	end
	exit when input == nil
	const separators <- " \n\r\t"
	first, input <- input.token[separators]
	if input !== nil then second, input <- input.token[separators] end if
	if first == nil or second == nil then
	  Environment$env.printf["Syntax error in invoccache file\n", nil]
	  exit
	end if
	id <- Integer.Literal[second]
	if input == nil then
	  codeid <- nil
	else
	  third, input <- input.token[separators]
	  if third !== nil then codeid <- Integer.Literal[third] end if
	end if
	if input == nil then
	  instcodeid <- nil
	else   
	  fourth, input <- input.token[separators]
	  if fourth !== nil then instcodeid <- Integer.Literal[fourth] end if
	end if
	if input !== nil then fifth, input <- input.token[separators] end if
	table.Insert[first, id, codeid, instcodeid, fifth, nil]
      end loop
      f.close
    end if
  end load
  export operation Lookup [s : String] -> [a:Integer,b:Integer,c:Integer,x : String, d:Any]
    a, b, c, x, d <- table.Lookup[s]
  end Lookup
  export operation Insert [s : String, a:Integer, b:Integer, c:Integer, x : String, d:Any]
    const env : EnvironmentType <- Environment$env
    const fn : String <- env$namespacefile
    var ta, tb, tc : Integer
    var tx : String
    var td : Any
    ta, tb, tc, tx, td <- table.Lookup[s]
    if fn !== nil and ta == nil and tb == nil and tc == nil and tx == nil then
      const nfn <- fn || ".idb"
      const f <- OutStream.toUnix[nfn, "a"]
      % chmod 0666 nfn
      if f == nil then
	env.SemanticError[1, "Can't open cache file \"%s\"", {nfn}]
      else
	f.putString[s]
	f.putChar[' ']
	f.putInt[a, 0]
	if b !== nil then
	  f.putChar[' ']
	  f.putInt[b, 0]
	  if c !== nil then
	    f.putChar[' ']
	    f.putInt[c, 0]
	  end if
	end if
	f.putChar[' ']
	f.putString[x]
	f.putChar['\n']
	f.close
      end if
    end if
    table.Insert[s, a, b, c, x, d]
  end Insert
  export operation resetForSourceFile[fn : String]
    table.resetForSourceFile[fn]
  end resetForSourceFile

end InvocCache
