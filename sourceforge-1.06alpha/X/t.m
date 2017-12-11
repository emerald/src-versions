const t <- object t
  operation readDiary 
    const inf <- InStream.fromUnix["/faculty/norm/tdiary", "r"]
    var s, t : String
    var d : Date
    loop
      exit when inf.eos
      s <- inf.getString
      s <- s[0, s.length - 1]
      d, t <- Parser.fromString[s]
    end loop
    inf.close
  end readDiary
  initially
    self.readDiary
  end initially
end t
