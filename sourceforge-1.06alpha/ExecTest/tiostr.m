const tinoutstream <- object tinoutstream
  const myTest <- runtest.create[stdin, stdout, "tinoutstream"]
  initially
    % each test looks like myTest.check[<boolean expression>, "<same exp>"]
    const outf <- OutStream.toUnix["tmp", "w"]
    outf.PutChar['T']
    outf.PutChar['\^J']
    outf.PutInt[36, 5]
    outf.PutChar['\^J']
    outf.PutString["This is a string.\^J"]
    outf.Close
    begin
      const inf <- InStream.fromUnix["tmp", "r"]
      mytest.Check[inf !== nil, "inf !== nil"]
      if inf !== nil then
	var s : String
	s <- inf.getString
	mytest.Check[s = "T\n", "s = \"T\\n\""]
	s <- inf.getString
	mytest.Check[s = "   36\n", "s = \"   36\\n\""]
	s <- inf.getString
	mytest.Check[s = "This is a string.\n", "s = \"This is a string\\n\""]
	mytest.Check[inf.eos, "inf.eos"]
      end if
    end
    myTest.done
  end initially
end tinoutstream
