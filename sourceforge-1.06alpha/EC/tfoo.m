const Env <- object Env
  export operation foo [x : Any] -> [r : Integer]
    primitive [r] <- [x]
  end foo
end Env

const test <- object test
  initially
    const me <- Env.foo[test]
  end initially
end test
