const id <- object id
  export function entity [a : T] -> [r : T]
    suchthat T *> typeobject constraint operation || [String] -> [String] end constraint
    forall T
    r <- a
  end entity
end id

const test <- object test
  initially
    var y : String <- "abc"
    var x : Any
    var z : Character
    z <- id.entity[z]
    z <- id.entity[y]
    x <- id.entity[x]
  end initially
end test
