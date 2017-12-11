const xapp <- object xapp

  const pause : Time <- Time.create[30, 0]
  const here : Node<- locate self

  var xpos : Integer <- 2
  var realw : Window

  export operation mouse [w : Window, event : Integer, 
  			  x : Integer, y : Integer,
			  l : Boolean, m : Boolean, r : Boolean]
    stdout.putstring["Got a mouse at "]
    stdout.putint[x, 0]
    stdout.putstring[", "]
    stdout.putint[y, 0]
    if l then
      stdout.putstring[" left"]
    elseif m then
      stdout.putstring[" middle"]
    elseif r then
      stdout.putstring[" right"]
    end if
    stdout.putstring["\n"]
  end mouse
  
  export operation TextRead [w : Window, event : Integer, 
  			     x : Integer, y : Integer, c : String]
    if c.length > 0 then
      realw.text[c, xpos, 30]
      realw.flush
      xpos <- xpos + 7 * c.length
      if xpos > 200 then xpos <- 2 end if
    end if
  end TextRead
    
  operation pause 
    stdout.putstring["Pausing\n"]
    here.delay[pause]
  end pause

  process
    const exitStatus <- 0
    var w : Window

    for i : Integer <- 0 while i < 2 by i <- i + 1
      w <- X.CreateWindow[50+25*i, 50+25*i, 200, 50,"test"]
      realw <- w
      w.setfont["6x10"]
      w.text["Hi there", 80, 10]
      w.setHandler[self]
      w.selectInput[KeyReleaseMask + ButtonPressMask + ExposureMask]
      X.Flush
      self.pause
      w.unmap
      w.Close
      X.Flush
      primitive "CCALL" "EXIT" [] <- [exitStatus]
    end for
  end process
end xapp


