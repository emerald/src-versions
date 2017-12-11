const id <- immutable object id
  export function en [a : T] -> [r : U]
    forall T
    where
      U <- typeobject U
	op tity -> [o : T]
      end U
    r <- object a
      export op tity -> [o : T]
	o <- a
      end tity
    end a
  end en
end id

const test <- object test
  initially
    var y : String <- "abc"
    var x : Any
    x <- id.en[y].tity
    y <- id.en[y].tity
  end initially
end test
