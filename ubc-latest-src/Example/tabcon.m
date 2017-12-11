const tabcon <- object tabcon
  export operation foo 
    
  end foo
  initially
    var ab : Type
    var con : ConcreteType
    
    var abcon : Any
    ab <- typeof self
    con <- codeof self
    primitive "BUILDABCON" [abcon] <- [ab, con]
  end initially
end tabcon
