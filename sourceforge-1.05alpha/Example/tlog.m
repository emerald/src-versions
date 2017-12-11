const tlog <- object tlog
  initially
    self.foo[]
    self.bar[]
  end initially
  operation foo 
    var c : Character <- 'a'
    var b : Boolean <- c != ' ' & c != '\^I' & c != '\n'
  end foo
  operation bar
    var c : Character <- 'a'
    var b : Boolean <- c != ' ' and c != '\^I' and c != '\n'
  end bar
end tlog
