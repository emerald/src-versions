const taaaa <- object taaaa
  const myTest <- runtest.create[stdin, stdout, "It is supposed to fail"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    myTest.finish[false]
  end initially
end taaaa
