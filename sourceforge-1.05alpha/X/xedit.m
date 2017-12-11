const hasDone <- typeobject t
  operation done[String]
end t
const XEdit <- class XEdit[w : Window, tlx : Integer, tly : Integer, width : Integer, height : Integer, initial : String, reportto : hasDone]

  var s : Vector.of[Character] <- Vector.of[Character].create[128]
  var pos : Vector.of[Integer] <- Vector.of[Integer].create[128]
  var xpos : Integer <- tlx
  var oldHandler : Any
  var oldInput : Integer

  var length : Integer <- 0

  operation cursoron 
    w.setwidth[11]
    w.line[xpos, tly + height - 6, xpos + 5, tly + height - 6]
    w.setwidth[0]
  end cursoron

  operation cursoroff
    w.clear[xpos, tly, 8, height]
  end cursoroff

  operation done 
    self.cursoroff
    w.setHandler[oldHandler]
    w.selectInput[oldInput]
    reportto.done[String.FLiteral[pos, 0, length]]
  end done

  operation repaint
    w.batch[true]
    w.setfont["-*-times-medium-r-*-*-12-*-*-*-*-*-*-*"]
    w.clear[tlx, tly, width, height]
    w.text[String.Literal[s, 0, length], tlx, tly + height]
    w.batch[false]
    self.cursoron
    X.Flush
  end repaint

  export operation mouse [w : Window, event : Integer, 
  			  x : Integer, y : Integer,
			  l : Boolean, m : Boolean, r : Boolean]
    if x < tlx or y < tly or x >= tlx + width or y >= tly + height then
      self.done
      if typeof oldHandler *> PointerType then
	(view oldHandler as PointerType).mouse[w, event, x, y, l, m, r]
      end if
    end if
  end mouse
  
  export operation TextRead [w : Window, event : Integer, 
  			     x : Integer, y : Integer, str : String]
    if str.length = 1 then
      self.cursoroff
      const c <- str[0]
      if c = '\010' or c = '\177' then
	% back up
	if length > 0 then
	  length <- length - 1
	  w.clear[pos[length], tly, xpos - pos[length], height]
	  xpos <- pos[length]
	end if
      elseif c = '\n' or c = '\r' then
	self.done
	w.flush
	return
      else
	s[length] <- c
	length <- length + 1
	w.text[str, xpos, tly + height]
	xpos <- xpos + w.TextWidth[str]
	pos[length] <- xpos
      end if
      self.cursoron
      w.flush
    end if
  end TextRead
    
  export operation Expose [w : Window, event : Integer]
    self.repaint
    if typeof oldHandler *> ExposeType then
      (view oldHandler as ExposeType).expose[w, event]
    end if
  end Expose
  
  export operation Configure [w : Window, event : Integer, nwidth : Integer, nheight : Integer]
    if typeof oldHandler *> ConfigureType then
      (view oldhandler as ConfigureType).configure[w, event, nwidth, nheight]
    end if
  end Configure

  initially
    if initial == nil then
      pos[0] <- xpos
    else
      for i : Integer <- 0 while i <= initial.upperbound by i <- i + 1
	pos[i] <- xpos
	s[i] <- initial[i]
	xpos <- xpos + w.textWidth[initial[i].asString]
      end for
      length <- initial.length
      w.text[initial, tlx, tly + height]
    end if
    self.cursoron
    oldHandler <- w.getHandler
    oldInput <- w.getSelectedInput
    w.setHandler[self]
    w.selectInput[KeyReleaseMask + ButtonPressMask + ExposureMask + StructureNotifyMask]
    X.Flush
  end initially
end XEdit

export XEdit
