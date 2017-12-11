const target <- object target
  export operation lots -> [x : Integer, y : String, z : Character]
    
  end lots
end target

const victim <- object victim
  initially
    var a : Integer
    var b : String
    var c : Character
    
    a, b, c <- target.lots
    a, b, c <- target.lots[2]
    a, b, c <- target.lots[3, 4]
    c, a, b <- target.lots
    b, c, a <- target.lots
    a, b <- target.lots
    a, b, a, b <- target.lots
  end initially
end victim
