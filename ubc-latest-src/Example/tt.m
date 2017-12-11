const tt <- object tt
  initially
    const t <- "This is a string\n"
    self.foo[3]
    self.outString[t]
  end initially
  operation outString [s : String]
    stdout.putstring[s]
  end outString
  operation foo [x : Integer]
    self.outString[x.asString]
    self.outString["\n"]
  end foo
end tt
