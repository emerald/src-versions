
const xcpu <- object xcpu
  process
    var myxf : XForms <- XForms.create
    const mysample <- BarChart.create[myxf, "CPU Utilization", 100, 90]
    mysample.setMax[100]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[Time.create[1, 0]]
    const foo : InStream <- InStream.fromUnix["|vmstat 1", "r"]
    mysample.setColor[0, FL_BLUE]
    mysample.setColor[1, FL_RED]
    loop
      exit when foo.eos
      var s, t, tin, us, sys, id : String
      s <- foo.getString
      tin, t <- s.token[" \t\n"]
      if tin != "procs" and tin != "r" then
	s <- s[59, s.length - 63]
	us, s <- s.token[" \t\n"]
	sys, s <- s.token[" \t\n"]
	id, s <- s.token[" \t\n"]
%	stdout.putstring["User: "||us||" Sys: "||sys||" Idle: "||id||"\n"]
	mysample.Sample[{Integer.Literal[us], Integer.Literal[sys] : Integer}]
      end if
    end loop
    foo.close
  end process
end xcpu
