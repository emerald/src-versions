const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    var browse : Browser
    var myinput : Input
    const myform <- Form.create[myxf, fl_up_box, 320, 460]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    browse <- Browser.create[myxf, fl_normal_browser, 10, 120, 300, 280, ""]
    browse.setFontSize[FL_MEDIUM_FONT]
    myform.add[browse]

    const handleadd <- object handleadd
      var number : Integer <- 1
      export operation CallBack [f : XFormObject]
	browse.addLine["This is an automatically generated line: " || number.asString]
	number <- number + 1
	browse.setFontSize[number]
      end CallBack
    end handleadd

    myform.add[lightbutton.create[myxf, fl_normal_button, 40, 70, 80, 30, "Quit", handlequit]]
    myform.add[box.create[myxf, fl_down_box, 60, 20, 200, 40, "Discussion"]]
    myform.add[lightbutton.create[myxf, fl_normal_button,200, 70, 80, 30, "Add a line", handleadd]]

    const handleinput <- object handleinput
      export operation text [s : String]
	browse.addLine[s]
      end text
    end handleinput

    myinput <- Input.create[myxf, fl_normal_input, 10, 400, 300, 30, "", handleInput]
    myinput.setScroll[false]
    myform.add[myinput]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
