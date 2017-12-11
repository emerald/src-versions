const samplewidth <- 3
const border <- 6

const SampleChart <- class SampleChart[myxf: XForms, nsamples : Integer, ih : Integer]
  field color : Integer <- FL_RED
  var mymax : XFormObject
  const iw <- nsamples * samplewidth
  const width <- iw + 2 * border
  const height <- ih + 2 * border
  const samples <- Array.of[Integer].create[nsamples]
  var max : Integer <- 8096

  function roundup [value : Integer, granularity : Integer] -> [r : Integer]
    r <- (((value - 1) / granularity) + 1) * granularity
  end roundup

  export operation Sample[s : Integer]
    const junk <- samples.removelower
    samples.addupper[s]
    if junk = max or s > max or true then
      max <- samples[samples.lowerbound]
      for i : Integer <- samples.lowerbound while i <= samples.upperbound by i <- i + 1
	if samples[i] > max then max <- samples[i] end if
      end for
      if max < 8 * 1024 then
	max <- 8 * 1024
      elseif max < 128 * 1024 then
	max <- self.roundup[max, 4096]
      else
	max <- self.roundup[max, 32 * 1024]
      end if
      mymax.setLabel[(max / 1024).asString || "K"]
    end if
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
      const barheight <- ((samples[i].asReal / max.asReal) * ih.asReal).asInteger
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
    mymax <- Box.create[myxf, fl_flat_box, width - border, border, 40, 10, "8K"]
    const mymin <- Box.create[myxf, fl_flat_box, width - border, border + ih - 10, 40, 10, "0"]
    myform.close
    myform.show[fl_place_free, fl_fullborder, "Network Activity"]
    self.Update
  end process
end SampleChart

const netstat <- object netstat
  process
    var myxf : XForms <- XForms.create
    const mysample <- SampleChart.create[myxf, 100, 90]
    const goer <- object foo
      process
	myxf.go
      end process
    end foo
    (locate self).delay[Time.create[1, 0]]
    const foo : InStream <- InStream.fromUnix["|netstat 1", "r"]
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
	mysample.Sample[(Integer.Literal[inputbytes] + Integer.Literal[outputbytes])]
      end if
    end loop
    foo.close
  end process
end netstat
