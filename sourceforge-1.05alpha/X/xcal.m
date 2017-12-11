const MElement <- class MElement [plabel : Integer]
  const field label : Integer <- plabel

  export operation display [w : Window, tlx : Integer, tly : Integer, cellw : Integer]
    if label !== nil then
      texthelper.right[w, label.asString, tlx, tly + 15, cellw - 5]
    end if
  end display
end MElement


const xcal <- object xcal
  const here : Node<- locate self
  const table : Assoctype <- assoctype.create
  var nrows : Integer <- 6
  var xpos : Integer <- 2
  var width, height : Integer
  var cellw, cellh : Integer
  var firstday : Integer <- 4
  var spacingw, spacingh : Integer
  var topmargin : Integer <- 60
  var currentTime : Time <- here.getTimeOfDay
  var currentDate : Date <- Date.create[currentTime]
  const elements  <- Vector.of[MElement].create[42]
  const sdays <- { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

  operation repaint [w : Window]
    w.batch[true]
    w.setfont["-*-times-medium-r-*-*-24-*-*-*-*-*-*-*"]
    texthelper.center[w, currentDate.monthname || " " || currentDate.year.asString, 0, topmargin - 35, width]
    w.setfont["-*-times-medium-r-*-*-18-*-*-*-*-*-*-*"]
    for col : Integer <- 0 while col < 7 by col <- col + 1
      texthelper.center[w, sdays[col], spacingw + col * cellw, topmargin - 5, cellw]
    end for
    for row : Integer <- 0 while row <= nrows by row <- row + 1
      w.line[spacingw, topmargin + spacingh + row * cellh, spacingw + 7 * cellw, topmargin + spacingh + row * cellh]
    end for

    for col : Integer <- 0 while col <= 7 by col <- col + 1
      w.line[spacingw + col * cellw, topmargin + spacingh, spacingw + col * cellw, topmargin + spacingh + nrows * cellh]
    end for

    w.setfont["-*-times-medium-r-*-*-12-*-*-*-*-*-*-*"]
    for row : Integer <- 0 while row < nrows by row <- row + 1
      for col : Integer <- 0 while col < 7 by col <- col + 1
	elements[row * 7 + col].display[w, spacingw + col * cellw, topmargin + spacingh + row * cellh, cellw]
      end for
    end for
    w.batch[false]
    X.Flush
  end repaint

  export operation doMonth
    const lengths <- { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    
    loop
      exit when currentDate.day = 1
      currentTime <- currentTime - Time.create[60 * 60 * 24, 0]
      currentDate <- Date.create[currentTime]
    end loop
    var l : Integer <- 1
    var skip : Integer <- currentDate.weekday
    const month <- currentDate.month
    const year <- currentDate.year
    var limit : Integer <- lengths[month]
    if month = 1 and year # 4 = 0 and (year # 100 != 0 or year # 400 = 0) then
      limit <- limit + 1
    end if
    if skip + limit > 7 * 5 then
      nrows <- 6
    else
      nrows <- 5
    end if
    for row : Integer <- 0 while row < nrows by row <- row + 1
      for col : Integer <- 0 while col < 7 by col <- col + 1
	if skip > 0 then
	  elements[row * 7 + col] <- MElement.create[nil]
	  skip <- skip - 1
	elseif l > limit then
	  elements[row * 7 + col] <- MElement.create[nil]
	else
	  elements[row * 7 + col] <- MElement.create[l]
	  l <- l + 1
	end if
      end for
    end for
  end doMonth

  export operation nextMonth
    const oldmonth <- currentDate.month
    loop
      exit when currentDate.month != oldmonth
      currentTime <- currentTime + Time.create[60 * 60 * 24, 0]
      currentDate <- Date.create[currentTime]
    end loop
  end nextMonth

  export operation prevMonth
    const oldmonth <- currentDate.month
    loop
      exit when currentDate.month != oldmonth
      currentTime <- currentTime - Time.create[60 * 60 * 24, 0]
      currentDate <- Date.create[currentTime]
    end loop
  end prevMonth

  export operation mouse [w : Window, event : Integer, 
  			  x : Integer, y : Integer,
			  l : Boolean, m : Boolean, r : Boolean]
    if l then
      var row, col : Integer
      row <- (y - topmargin - spacingh) / cellh
      col <- (x - spacingw) / cellw
      const theelement <- elements[row * 7 + col]
      const thetime : Time <- currentTime + Time.create[(theelement.getLabel - 1) * 24 * 60 * 60, 0]
      const thedate : Date <- Date.create[thetime]
      const thekey : Key <- Key.create[thedate.year, thedate.month, thedate.day]
      const foo : ADay <- ADay.create[thetime, table.lookup[thekey]]
    end if
%   stdout.putstring["Got a mouse at "]
%   stdout.putint[x, 0]
%   stdout.putstring[", "]
%   stdout.putint[y, 0]
%   if l then
%     stdout.putstring[" left"]
%   elseif m then
%     stdout.putstring[" middle"]
%   elseif r then
%     stdout.putstring[" right"]
%   end if
%   stdout.putstring["\n"]
  end mouse
  
  export operation TextRead [w : Window, event : Integer, 
  			     x : Integer, y : Integer, c : String]
    if c.length > 0 then
      if c.length = 1 and c[0] = 'Q' then
	const exitStatus <- 0
	primitive "CCALL" "EXIT" [] <- [exitStatus]
      elseif c.length = 1 and c[0] = 'n' then
	self.nextMonth
	self.doMonth
	self.configure[w, 22, width, height]
	w.clear
	self.repaint[w]
      elseif c.length = 1 and c[0] = 'p' then
	self.prevMonth
	self.doMonth
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

  export operation Map [w : Window, event : Integer]

  end Map

  export operation Configure [w : Window, event : Integer, nwidth : Integer,
    nheight : Integer]
    width <- nwidth
    height <- nheight
    cellw <- (width - 1) / 7
    cellh <- (height - topmargin - 1) / nrows
    spacingw <- (width - 7 * cellw - 1) / 2
    spacingh <- (height- topmargin - nrows * cellh - 1) / 2
  end Configure

  operation readDiary 
    const inf <- InStream.fromUnix["/faculty/norm/tdiary", "r"]
    var s : String
    var t : Time
    var d : Date
    
    loop
      exit when inf.eos
      s <- inf.getString
      s <- s[0, s.length - 1]
      t, s <- Parser.fromString[s]
      if t !== nil then
	d <- Date.create[t]
	const thekey : key <- key.create[d.year, d.month, d.day]
	var theday : Day <- table.lookup[thekey]
	if theday == nil then
	  theday <- Day.create
	  table.insert[thekey, theday]
	end if
	theday$events.addupper[delement.create[d.hour, d.minute, s]]
      end if
      
    end loop
    inf.close
  end readDiary

  process
    const exitStatus <- 0
    var w : Window
    self.readDiary
    w <- X.CreateWindow[50, 50, 7 * 60 + 1, 5 * 60 + 1, "xcal"]
    w.setHandler[self]
    w.selectInput[KeyReleaseMask + ButtonPressMask + ExposureMask + StructureNotifyMask]
    self.domonth
%    self.configure[w, 22, 421, 301]
%    self.expose[w, 12]
    X.Flush
  end process
end xcal
