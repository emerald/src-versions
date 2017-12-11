const id <- object id
  export function entity [T : Type, a : T] -> [r : T]
    r <- a
  end entity
end id

const test <- object test
  initially
    var y : String <- "abc"
    var x : Any
    var z : type
    z <- id.entity[Type, z]
    y <- id.entity[String, y]
  end initially
end test
