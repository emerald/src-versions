const tmult <- object tmult
  initially
    var i, j : Integer
    i, j <- self.mult['x']
  end initially
  operation mult [x : Character] -> [a : Integer, b : Integer]
    a <- x.ord
    b <- x.ord + 1
  end mult
end tmult
