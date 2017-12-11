const netstat <- object netstat
  process
    var myxf : XForms <- XForms.create
    const mysample <- BarChart.create[myxf, "Net Bandwidth", 100, 90]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[Time.create[1, 0]]
    const foo : InStream <- InStream.fromUnix["|netstat 1", "r"]
    mysample.setColor[0, FL_BLUE]
    mysample.setColor[1, FL_GREEN]
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
	mysample.Sample[{Integer.Literal[inputbytes], Integer.Literal[outputbytes] : Integer}]
      end if
    end loop
    foo.close
  end process
end netstat
