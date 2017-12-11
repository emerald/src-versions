const testx <- object testx
  var myxf : XForms <- XForms.create
  var mytoppixmap : Pixmap
  var x, y : Integer
  var myform: Form

  export operation Mouse[mx : Integer, my : Integer, key : Integer]
    stdout.putstring["Mouse @ ("|| mx.asString||","||my.asString||") "||key.asString||"\n"]
    x, y <- mx, my
    const junk <- object junk
      process
	myform.open
	const p <- pixmap.create[myxf, fl_normal_pixmap, 0, 0, 32, 32, ""]
	myform.close
	p.setfile["bomb.xpm"]
	p.moveto[x, y]
      end process
    end junk
  end Mouse

  export operation Draw[mx : Integer, my : Integer, w : Integer, h : Integer]
  end Draw
  export operation Enter
  end Enter
  export operation Leave
  end Leave
  export operation Motion[mx : Integer, my : Integer]
  end Motion
  export operation Push[mx : Integer, my : Integer, key : Integer]
  end Push

  export operation Release[key : Integer]
  end Release
  export operation DoubleClick
  end DoubleClick
  export operation TripleClick
  end TripleClick
  export operation Focus
  end Focus
  export operation Unfocus
  end Unfocus
  export operation Keyboard[mx : Integer, my : Integer, key : Integer]
  end Keyboard
  export operation Step
  end Step
  export operation Other[key : Integer]
  end Other

  process
    myform <- Form.create[myxf, fl_up_box, 700, 700]
    const myfree <- free.create[myxf, fl_input_free, 0, 0, 700, 700, "", self]
    mytoppixmap <- pixmap.create[myxf, fl_normal_pixmap, 0, 0, 32, 32, ""]
    myform.close
    x <- 0
    y <- 0
    mytoppixmap.setfile["bomb.xpm"]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
    loop
      mytoppixmap.moveto[x, y]
      myxf.flush
      x <- x + 20
      y <- y + 15
      (locate self).Delay[Time.create[1, 0]]
    end loop
  end process
end testx
