const xfree <- object xfree
  var ox, oy, px, py : Integer
  field color : Integer <- FL_RED
  const closedrbrect <- true

  operation minmax[a : Integer, b : Integer] -> [r : Integer, s : Integer]
    if a < b then
      r, s <- a, b
    else
      r, s <- b, a
    end if
  end minmax

  operation RBLine[mx : Integer, my : Integer]
    primitive "NCCALL" "XFORMS" "FL_LINE" [] <- [ox, oy, px, py, color]
    primitive "NCCALL" "XFORMS" "FL_LINE" [] <- [ox, oy, mx, my, color]
    px <- mx py <- my
  end RBLine

  operation RBLineDone
    primitive "NCCALL" "XFORMS" "FL_LINE" [] <- [ox, oy, px, py, color]
    primitive "NCCALL" "XFORMS" "FL_DRAWMODE" [] <- [3]
    primitive "NCCALL" "XFORMS" "FL_LINE" [] <- [ox, oy, px, py, color]
  end RBLineDone

  operation RBRectangle[mx : Integer, my : Integer]
    const ow <- px - ox
    const oh <- py - oy
    const mw <- mx - ox
    const mh <- my - oy
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [closedrbrect, ox, oy, ow, oh, color]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [closedrbrect, ox, oy, mw, mh, color]
    px <- mx py <- my
  end RBRectangle

  operation RBRectangleDone
    const ow <- px - ox
    const oh <- py - oy
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [closedrbrect, ox, oy, ow, oh, color]
    primitive "NCCALL" "XFORMS" "FL_DRAWMODE" [] <- [3]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, ox, oy, ow, oh, color]
  end RBRectangleDone

  operation RBCircle[mx : Integer, my : Integer]
    var lpx, lox, lpy, loy, lmx, lmy : Integer
    lox, lpx <- self.minmax[ox, px]
    loy, lpy <- self.minmax[oy, py]
    const ow <- lpx - lox
    const oh <- lpy - loy
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [closedrbrect, lox, loy, ow, oh, color]
    lox, lmx <- self.minmax[ox, mx]
    loy, lmy <- self.minmax[oy, my]
    const mw <- lmx - lox
    const mh <- lmy - loy
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [closedrbrect, lox, loy, mw, mh, color]
    px <- mx py <- my
  end RBCircle

  operation RBCircleDone
    var lpx, lox, lpy, loy : Integer
    lox, lpx <- self.minmax[ox, px]
    loy, lpy <- self.minmax[oy, py]
    const ow <- lpx - lox
    const oh <- lpy - loy
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [closedrbrect, lox, loy, ow, oh, color]
    primitive "NCCALL" "XFORMS" "FL_DRAWMODE" [] <- [3]
    primitive "NCCALL" "XFORMS" "FL_OVAL" [] <- [1, lox, loy, ow, oh, color]
  end RBCircleDone

  export operation Draw[x : Integer, y : Integer, w : Integer, h : Integer]
    % stdout.putstring["Draw\n"]
    primitive "NCCALL" "XFORMS" "FL_RECTANGLE" [] <- [1, 10, 10, 190, 190, FL_BLACK]
  end Draw
  export operation Enter
    % stdout.putstring["Enter\n"]
  end Enter
  export operation Leave
    % stdout.putstring["Leave\n"]
  end Leave
  export operation Motion[mx : Integer, my : Integer]
    % stdout.putstring["Motion @ ("|| mx.asString||","||my.asString||")\n"]
  end Motion
  export operation Push[mx : Integer, my : Integer, key : Integer]
    const keys <- { "", "left", "middle", "right" }
    % stdout.putstring["Push "|| keys[key]|| " @ (" || mx.asString || ","||my.asString||") \n"]
    primitive "NCCALL" "XFORMS" "FL_DRAWMODE" [] <- [6]

    primitive "NCCALL" "XFORMS" "FL_SET_CLIPPING" [] <- [10, 10, 180, 180]
    ox <- mx px <- mx
    oy <- my py <- my
  end Push

  export operation Release[key : Integer]
    % stdout.putstring["Release"||key.asString||"\n"]
    if key = 1 then
      self.RBLineDone
    elseif key = 2 then
      self.RBRectangleDone
    elseif key = 3 then
      self.RBCircleDone
    else
      % stdout.putstring["  Junk release key = "||key.asString||"\n"]
    end if
    primitive "NCCALL" "XFORMS" "FL_UNSET_CLIPPING" [] <- []
  end Release
  export operation DoubleClick
    % stdout.putstring["DoubleClick\n"]
  end DoubleClick
  export operation TripleClick
    % stdout.putstring["TripleClick\n"]
  end TripleClick
  export operation Mouse[mx : Integer, my : Integer, key : Integer]
    % stdout.putstring["Mouse @ ("|| mx.asString||","||my.asString||") "||key.asString||"\n"]
    if key = 1 then
      self.RBLine[mx, my]
    elseif key = 2 then
      self.RBRectangle[mx, my]
    elseif key = 3 then
      self.RBCircle[mx, my]
    else
      % stdout.putstring["  Junk mouse key = "||key.asString||"\n"]
    end if
  end Mouse
  export operation Focus
    % stdout.putstring["Focus\n"]
  end Focus
  export operation Unfocus
    % stdout.putstring["Unfocus\n"]
  end Unfocus
  export operation Keyboard[mx : Integer, my : Integer, key : Integer]
    % stdout.putstring["Keyboard "||key.asString||" '"||Character.literal[key].asString||"' @ ("|| mx.asString||","||my.asString||")\n"]
  end Keyboard
  export operation Step
    % stdout.putstring["Step\n"]
  end Step
  export operation Other[key : Integer]
    stdout.putstring["Other\n"]
  end Other

  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 250, 200]
    var redbutton, greenbutton, bluebutton : Button
    const myfree <- free.create[myxf, fl_input_free, 10, 10, 180, 180, "", self]
    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
	primitive "NCCALL" "MISK" "UEXIT" [] <- [0]
      end CallBack
    end handlequit

    const rcb <- object rcb
      export operation CallBack[f : XFormObject]
	xfree$color <- FL_RED
      end CallBack
    end rcb

    const bcb <- object bcb
      export operation CallBack[f : XFormObject]
	xfree$color <- FL_BLUE
      end CallBack
    end bcb

    const gcb <- object gcb
      export operation CallBack[f : XFormObject]
	xfree$color <- FL_GREEN
      end CallBack
    end gcb

    redbutton <- Button.create[myxf, fl_radio_button, 210, 10, 30, 30, "", rcb]
    redbutton.setcolor[FL_RED, FL_RED]
    redbutton.set[true]
    bluebutton <- Button.create[myxf, fl_radio_button, 210, 50, 30, 30, "", bcb]
    bluebutton.setcolor[FL_BLUE, FL_BLUE]
    greenbutton <- Button.create[myxf, fl_radio_button, 210, 90, 30, 30, "", gcb]
    greenbutton.setcolor[FL_GREEN, FL_GREEN]
    const quitbutton <- button.create[myxf, fl_normal_button, 210, 130, 30, 30, "Quit", handlequit]

    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end xfree
