const samplewidth <- 3
const border <- 6

const SampleChart <- class SampleChart[myxf: XForms, nsamples : Integer, ih : Integer]
  field color : Integer <- FL_RED
  var mymax : XFormObject
  const iw <- nsamples * samplewidth
  const width <- iw + 2 * border
  const height <- ih + 2 * border
  const samples <- Array.of[Integer].create[nsamples]
  var max : Integer <- 100

  function roundup [value : Integer, granularity : Integer] -> [r : Integer]
    r <- (((value - 1) / granularity) + 1) * granularity
  end roundup

  export operation Sample[s : Integer]
    const junk <- samples.removelower
    samples.addupper[s]
    self.Update
  end Sample

  export operation Update 
    self.Draw[0, 0, 0, 0]
    myxf.Flush
  end Update

  export operation Draw[x : Integer, y : Integer, w : Integer, h : Integer]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, border, border, iw, ih, FL_WHITE]
    var xpos : Integer <- border
    for i : Integer <- samples.lowerbound while i <= samples.upperbound by i <- i + 1
      var barheight : Integer
      barheight <- ((samples[i].asReal / max.asReal) * ih.asReal).asInteger
      if barheight >= ih then barheight <- ih end if
      const top <- border + ih - barheight
      const bottom <- ih + border
      const filled <- true

      primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [filled, xpos, top, 3, barheight, color]
      xpos <- xpos + 3
    end for
  end Draw

  initially
    for i : Integer <- 0 while i <= samples.upperbound by i <- i + 1
      samples[i] <- 0
    end for
  end initially

  process
    const outw <- width + 40
    const outh <- height
    const myform <- Form.create[myxf, fl_up_box, outw, outh]
    mymax <- Box.create[myxf, fl_flat_box, width - border, border, 40, 10, max.asString]
    const mymin <- Box.create[myxf, fl_flat_box, width - border, border + ih - 10, 40, 10, "0"]
    myform.add[mymax]
    myform.add[mymin]
    myform.show[fl_place_free, fl_fullborder, "CPU Utilization"]
    self.Update
  end process
end SampleChart

const xcpu <- object xcpu
  process
    var myxf : XForms <- XForms.create
    const mysample <- SampleChart.create[myxf, 100, 90]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[Time.create[1, 0]]
    const foo : InStream <- InStream.fromUnix["|vmstat 1", "r"]
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
	mysample.Sample[(Integer.Literal[us] + Integer.Literal[sys])]
      end if
    end loop
    foo.close
  end process
end xcpu
