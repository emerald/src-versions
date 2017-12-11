const tpopen <- object tpopen
  process
    const foo : InStream <- InStream.fromUnix["|netstat -Iep0 10", "r"]
    loop
      exit when foo.eos
      var s, inputpackets, inputerrors, inputbytes : String
      var outputcollisions, outputpackets, outputerrors, outputbytes : String
      s <- foo.getString
      inputpackets, s <- s.token[" \t\n"]
      if inputpackets != "packets" and inputpackets != "input" then 
	inputerrors, s <- s.token[" \t\n"]
	inputbytes, s <- s.token[" \t\n"]
	outputpackets, s <- s.token[" \t\n"]
	outputerrors, s <- s.token[" \t\n"]
	outputbytes, s <- s.token[" \t\n"]
	outputcollisions, s <- s.token[" \t\n"]
	stdout.putstring[inputbytes || " bytes\n"]
      end if
    end loop
    foo.close
  end process
end tpopen
