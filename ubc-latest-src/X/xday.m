const key <- immutable class key[pyear : Integer, pmonth : Integer, pday : Integer]
  field year : Integer <- pyear
  field month : Integer <- pmonth
  field day : Integer <- pday
  export function hash -> [r : Integer]
    r <- year * 7 + month * 13 + day
  end hash
  export function = [other : key] -> [r : Boolean]
    r <- other$year = year and other$month = month and other$day = day
  end =
end key

const delement <- class delement[hp : Integer, mp : Integer, descp : String]
  field h : integer <- hp
  field m : integer <- mp
  field desc : String <- descp
end delement

const day <- class day
  field events : Array.of[delement] <- Array.of[delement].empty
end day

const assoctype <- Assoc.of[key, day]
export key, delement, day, assoctype

const separatorColumn <- 50
const HElement <- class HElement [time : Integer]
  var timeString : String
  field label : String
  export operation display [w : Window, tlx : Integer, tly : Integer, cellh : Integer, width : Integer]
    if time !== nil then
      texthelper.right[w, timeString, tlx, tly + cellh - 3, separatorColumn - 10]
      if label !== nil then
	texthelper.left[w, label, tlx + separatorColumn, tly + cellh -3, width - separatorColumn]
      end if
    end if
  end display

  export operation done [newlabel : String]
    label <- newlabel
    % write this out to the end of the file
  end done

  initially
    timeString <- (time / 100).asString
    const minutes <- time # 100
    if minutes <= 9 then
      timeString <- timeString || ":0"
    else
      timeString <- timeString || ":"
    end if
    timeString <- timeString || minutes.asString
  end initially
end HElement

const aDay <- class aDay[whichday : Time, theDay : Day]
  var currentTime : Time <- whichday
  var currentDate : Date <- Date.create[currentTime]
  const here : Node<- locate self
  const nrows <- 24
  var xpos : Integer <- 2
  var width, height : Integer
  var cellh : Integer
  var topmargin : Integer <- 40
  const elements  <- Vector.of[HElement].create[nrows]
  const stdout <- here.getStdout

  operation repaint [w : Window]
    w.batch[true]
    w.setfont["-*-times-medium-r-*-*-24-*-*-*-*-*-*-*"]
    texthelper.center[w, currentDate.dayname || " " || currentDate.monthname || " " || currentDate.day.asString || ", " || currentDate.year.asString, 0, topmargin - 5, width]
    w.setfont["-*-times-medium-r-*-*-18-*-*-*-*-*-*-*"]
    for row : Integer <- 0 while row <= nrows by row <- row + 1
      w.line[0, topmargin + row * cellh, width, topmargin + row * cellh]
    end for

    w.line[separatorColumn, topmargin, separatorColumn, topmargin + nrows * cellh]

    w.setfont["-*-times-medium-r-*-*-12-*-*-*-*-*-*-*"]
    for row : Integer <- 0 while row < nrows by row <- row + 1
      elements[row].display[w, 5, topmargin + row * cellh, cellh, width]
    end for
    w.batch[false]
    X.Flush
  end repaint

  export operation Setup
    for row : Integer <- 0 while row < nrows by row <- row + 1
      elements[row]$label <- nil
    end for
  end Setup

  export operation nextDay
    currentTime <- currentTime + Time.create[24 * 60 * 60, 0]
    currentDate <- Date.create[currentTime]
  end nextDay

  export operation prevDay
    currentTime <- currentTime - Time.create[24 * 60 * 60, 0]
    currentDate <- Date.create[currentTime]
  end prevDay

  export operation mouse [w : Window, event : Integer, 
  			  x : Integer, y : Integer,
			  l : Boolean, m : Boolean, r : Boolean]

    if l and x > separatorColumn and y >= topMargin then
      var row : Integer
      row <- (y - topmargin) / cellh
      if row < nrows then
	const theelement <- elements[row]
	const foo : XEdit <- XEdit.create[w, separatorColumn + 5, topmargin + row * cellh + 1, width - separatorColumn - 5, cellh - 4, theelement$label, theelement]
      end if
    end if
  end mouse
  
  export operation TextRead [w : Window, event : Integer, 
  			     x : Integer, y : Integer, c : String]
    if c.length > 0 then
      if c.length = 1 and c[0] = 'Q' then
	const exitStatus <- 0
	w.close
	w.flush
      elseif c.length = 1 and c[0] = 'n' then
	self.nextDay
	self.Setup
	self.configure[w, 22, width, height]
	w.clear
	self.repaint[w]
      elseif c.length = 1 and c[0] = 'p' then
	self.prevDay
	self.Setup
	self.configure[w, 22, width, height]
	w.clear
	self.repaint[w]
      end if
%      w.text[c, xpos, 30]
      w.flush
%      xpos <- xpos + 7 * c.length
%      if xpos > 200 then xpos <- 2 end if
    end if
  end TextRead
    
  export operation Expose [w : Window, event : Integer]
    self.repaint[w]
  end Expose

  export operation Configure [w : Window, event : Integer, nwidth : Integer,
    nheight : Integer]
    width <- nwidth
    height <- nheight
    cellh <- (height - topmargin - 1) / nrows
  end Configure

  initially
    var w : Window

    for row : Integer <- 0 while row < nrows by row <- row + 1
      elements[row] <- HElement.create[700 + row / 2 * 100 + row # 2 * 30]
    end for
    self.setup
    if theday !== nil then
      const ev <- theday$events
      for i : Integer <- 0 while i <= ev.upperbound by i <- i + 1
	const thedesc <- ev[i]
	if thedesc$h >= 7 and thedesc$h < 19 then
	  var theslot : Integer <- (thedesc$h - 7) * 2
	  if thedesc$m >= 30 then theslot <- theslot + 1 end if
	  elements[theslot]$label <- thedesc$desc
	else
	  (locate self)$stdout.putstring["Can't deal with event at "||thedesc$h.asString||":"||thedesc$m.asString||" "||thedesc$desc||"\n"]
	end if
      end for
    end if
    w <- X.CreateWindow[50, 50, 350, 24 * 25 + 1, "xcal"]
    w.setHandler[self]
    w.selectInput[KeyReleaseMask + ButtonPressMask + ExposureMask + StructureNotifyMask]
    X.Flush
  end initially

end aDay

export aDay
