const vec <- object vec
  const ivoi <- ImmutableVector.of[Integer]
  initially
    var a : ivoi
    var b : ImmutableVectorOfAny
     
    a <- b
    b <- a
    
    a <- { 1, 2, 3 }
    b <- { 1, 2, 3 }
  end initially
end vec
