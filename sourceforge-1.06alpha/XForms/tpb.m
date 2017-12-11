const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 320, 460]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    const handleadd <- object handleadd
      var number : Integer <- 1
      export operation CallBack [f : XFormObject]
	stdout.putstring["This is an automatically generated line: " || number.asString||"\n"]
	number <- number + 1
      end CallBack
    end handleadd

    myform.add[lightbutton.create[myxf, fl_normal_button, 40, 70, 80, 30, "Quit", handlequit]]
    myform.add[box.create[myxf, fl_down_box, 60, 20, 200, 40, "Pixmapbutton"]]
    const mypmb <- pixmapbutton.create[myxf, fl_normal_button,200, 70, 80, 30, "", handleadd]
    myform.add[mypmb]
    mypmb.setfile["bomb.xpm"]

    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
