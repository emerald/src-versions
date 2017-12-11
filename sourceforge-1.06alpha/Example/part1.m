const foo <- class foo[x : String, o : OutStream]
  initially
    o.putString[x]
  end initially
  operation xxy [s : String]
    o.putstring[s]
  end xxy
end foo

export foo 
