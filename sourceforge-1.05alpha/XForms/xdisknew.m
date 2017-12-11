const xdisk <- object xdisk
  process
    var myxf : XForms <- XForms.create
    const mysample <- BarChart.create[myxf, "Disk bandwidth", 100, 90]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[Time.create[1, 0]]
    const foo : InStream <- InStream.fromUnix["|iostat 1", "r"]
    mysample.setColor[0, FL_BLUE]
    loop
      exit when foo.eos
      var s, t, tin, sps : String
      s <- foo.getString
      tin, t <- s.token[" \t\n"]
      if tin != "tty" and tin != "tin" then
	s <- s[9, s.length - 9]
	sps, s <- s.token[" \t\n"]
%	stdout.putstring["Sps: "||sps||"\n"]
	mysample.Sample[{Integer.Literal[sps] / 2 : Integer}]
      end if
    end loop
    foo.close
  end process
end xdisk
