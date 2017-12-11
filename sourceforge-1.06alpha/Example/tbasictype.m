const create <- object create
  initially
    var a : Any
    var c : Character
    var i : Integer
    self.foo[c]
    self.foo[i, c]
    self.foo[i]
    i <- 3
    a <- 3
    c <- Character.Literal[3]
  end initially
  operation foo [x : Integer]
    
  end foo
end create
