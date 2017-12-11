const tinstream <- object tinstream
  const myTest <- runtest.create[stdin, stdout, "tinstream"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    var c : Character
    var s : String
    c <- stdin.getChar
    myTest.check[c = 'T', "c = 'T'"]
    stdin.unGetChar[c]
    s <- stdin.getString
    myTest.check[s = "This is a line of stuff.\^J", "s = \"This is a line of stuff.\\^J\""]
    myTest.done
  end initially
end tinstream
