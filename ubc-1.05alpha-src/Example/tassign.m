const x <- object x
  field blotto : Integer
  initially
    var i, j : Integer
    3, 6 <- 5
    3, 6 <- 5, 7
    i, j <- 5, 7
    self.foo[] <- 5
    self$blotto, i <- 3, 4
    i, j <- "abc", "def"
  end initially
  operation foo 
    
  end foo

end x
