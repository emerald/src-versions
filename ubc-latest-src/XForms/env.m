const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    var browse : Browser
    var myinput : Input
    const myform <- Form.create[myxf, fl_up_box, 320, 100]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    browse <- Browser.create[myxf, fl_normal_browser, 10, 10, 300, 50, ""]
    browse.setFontSize[FL_MEDIUM_FONT]

    const qlb <- lightbutton.create[myxf, fl_normal_button, 40, 70, 80, 20, "Quit", handlequit]
    const b <- box.create[myxf, fl_down_box, 60, 20, 200, 40, "Discussion"]

    browse.addline["This is line 1"]
    browse.addline["This is line 2"]

    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
