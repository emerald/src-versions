const filled <- true
const samplewidth <- 3
const border <- 6
const npieces <- 3
const risi <- typeobject risi
  function lowerbound -> [Integer]
  function upperbound -> [Integer]
  function getElement [Integer] -> [Integer]
end risi

const BarChart <- class BarChart[myxf: XForms, label : String, nsamples : Integer, ih : Integer]
  var mymax : XFormObject
  var myform : Form
  const iw <- nsamples * samplewidth
  const width <- iw + 2 * border
  const height <- ih + 2 * border
  const aoi <- Array.of[Integer]
  const voa <- Vector.of[aoi]
  const samples <- voa.create[npieces]
  const totals <- aoi.create[nsamples]
  const granularities <- Vector.of[Integer].create[2]
  const colors <- Vector.of[Integer].create[npieces]
  var max : Integer <- 100
  var adjustMax : Boolean <- true

  export operation setMax [m : Integer]
    max <- m
    adjustMax <- false
  end setMax

  export operation setcolor [i : Integer, c : Integer]
    assert i >= 0 and i < npieces
    colors[i] <- c
  end setcolor

  export operation setgranularity [i : Integer, c : Integer]
    assert i >= 0 and i < 2
    granularities[i] <- c
  end setgranularity

  function roundup [value : Integer, granularity : Integer] -> [r : Integer]
    r <- (((value - 1) / granularity) + 1) * granularity
  end roundup

  function rounddown [value : Integer, granularity : Integer] -> [r : Integer]
    r <- (value / granularity) * granularity
  end rounddown

  export operation Sample[ss : risi]
    assert ss.lowerbound = 0
    var total : Integer <- 0
    for i : Integer <- 0 while i < npieces by i <- i + 1
      const junk <- samples[i].removelower
      if i <= ss.upperbound then
	samples[i].addupper[ss[i]]
	total <- total + ss[i]
      else
	samples[i].addupper[0]
      end if
    end for
    const junk <- totals.removelower
    totals.addupper[total]

    if adjustMax then
      max <- totals[totals.lowerbound]
      for i : Integer <- totals.lowerbound while i <= totals.upperbound by i <- i + 1
	if totals[i] > max then max <- totals[i] end if
      end for
      if max < granularities[0] then
	max <- granularities[0]
      elseif max < granularities[1] then
	max <- self.roundup[max, granularities[0]]
      else
	max <- self.roundup[max, granularities[1]]
      end if
      mymax.setLabel[max.asString]
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
    for i : Integer <- totals.lowerbound while i <= totals.upperbound by i <- i + 1
      var barsofar : Integer <- 0
      for which : Integer <- 0 while which < npieces by which <- which + 1
	const sample <- samples[which][i]
	if sample != 0 then
	  var barheight : Integer
	  barheight <- ((sample.asReal / max.asReal) * ih.asReal).asInteger
	  if barheight >= ih - barsofar then barheight <- ih - barsofar end if
	  const top <- border + ih - barheight - barsofar
	  const bottom <- ih + border - barsofar
	  const color <- colors[which]
	  primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [filled, xpos, top, 3, barheight, color]
%	  (locate self)$stdout.putstring["sample["||i.asString||"]["||which.asString||"] = "||sample.asString||" height = "||barheight.asString||" top = "||top.asString||"\n"]
	  barsofar <- barsofar + barheight
	end if
      end for
      xpos <- xpos + samplewidth
    end for
%    (locate self)$stdout.putstring["\n"]
  end Draw

  initially
    for i : Integer <- 0 while i < npieces by i <- i + 1
      samples[i] <- aoi.create[nsamples]
    end for
    colors[0] <- FL_GREEN
    colors[1] <- FL_YELLOW
    colors[2] <- FL_BLUE
    for i : Integer <- 0 while i <= totals.upperbound by i <- i + 1
      totals[i] <- 0
      for j : Integer <- 0 while j < npieces by j <- j + 1
	samples[j][i] <- 0
      end for
    end for
    granularities[0] <- 10
    granularities[1] <- 100
  end initially

  process
    const outw <- width + 40
    const outh <- height
    myform <- Form.create[myxf, fl_up_box, outw, outh]
    mymax <- Box.create[myxf, fl_flat_box, width - border, border, 40, 10, max.asString]
    const mymin <- Box.create[myxf, fl_flat_box, width - border, border + ih - 10, 40, 10, "0"]
    myform.add[mymax]
    myform.add[mymin]
    myform.show[fl_place_free, fl_fullborder, label]
    self.Update
  end process
end BarChart

export BarChart
