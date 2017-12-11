const toutstream <- object toutstream
  const myTest <- runtest.create[stdin, stdout, nil]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    stdout.PutChar['T']
    stdout.PutChar['\^J']
    stdout.PutInt[36, 0]
    stdout.PutChar['\^J']
    stdout.PutString["This is a string.\^J"]
    myTest.done
  end initially
end toutstream
