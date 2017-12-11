const id <- object id
  export function entity [a : T] -> [r : T]
    forall T
    var intermediate : T
    intermediate <- a
    r <- intermediate
  end entity
end id

const id2 <- object id2
  export function entity [a : T] -> [r : T]
    suchthat T *> typeobject constraint operation || [String] -> [String] end constraint
    forall T
    r <- a
  end entity
end id2

const test <- object test
  initially
    var y : String <- "abc"
    var x : Any
    var z : Character
    z <- id.entity[z]
    x <- id.entity[y]
    y <- id.entity[y]
    x <- id.entity[x]
    y <- id2.entity[y]    
  end initially
end test
