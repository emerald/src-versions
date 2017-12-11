const thairy <- object thairy
  const myTest <- runtest.create[stdin, stdout, "thairy"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    var i : Integer <- 4
    i <- ((i + i) * (i + i) * (i + i) + (i + i) * (i + i) * (i + i))
    myTest.done
  end initially
end thairy
