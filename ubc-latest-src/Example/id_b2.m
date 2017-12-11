const id <- object id
  export function entity [T : Type, a : T] -> [r : T]
    r <- a
  end entity
end id

const test <- object test
  initially
    var x : Any
    var y : String <- "abc"
    var z : type
    x <- id.entity[z, y]
    z <- id.entity[String, y]
  end initially
end test
