const hash <- object hash
  initially
    var name, line : String
    var f : InStream
    
    stdout.putString["File: "]
    stdout.flush
    name <- stdin.getString
    name <- name.getSlice[0, name.length - 1]
    
    f <- InStream.fromUnix[name, "r"]
    loop
      exit when f.eos
      line <- f.getString
      line <- line.getSlice[0, line.length - 1]
      stdout.putint[line.hash, 10]
      stdout.putstring[" -> "]
      stdout.putstring[line]
      stdout.putchar['\n']
    end loop
    f.close
  end initially
end hash
