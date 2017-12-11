const other <- object other
    const field which : Integer <- 99
    field why : Integer <- 101
end other

const tself <- object tself
  const field which : Integer <- 45
  field why : Integer <- 33

  operation blotto [tself : String]
    stdout.putint[Integer.literal[self], 0]
    stdout.putchar['\n']
  end blotto

  initially
    var x : Integer <- self$which
    var y : Integer <- self$why
    var z : Integer <- other$which
    var a : Integer <- other$why
    
  end initially
end tself
