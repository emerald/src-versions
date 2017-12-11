const testx <- object testx
  var myxf : XForms <- XForms.create

const junk1 <- object junk1
  initially
    var browse : Browser
    var myinput : Input
    const myform <- Form.create[myxf, fl_up_box, 320, 460]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myform.destroy
      end CallBack
    end handlequit

    browse <- Browser.create[myxf, fl_normal_browser, 10, 120, 300, 280, ""]
    browse.setFontSize[FL_MEDIUM_FONT]

    const handleadd <- object handleadd
      var number : Integer <- 1
      export operation CallBack [f : XFormObject]
	browse.addLine["This is an automatically generated line: " || number.asString]
	number <- number + 1
	browse.setFontSize[number]
      end CallBack
    end handleadd

    const quitbutton <- lightbutton.create[myxf, fl_normal_button, 40, 70, 80, 30, "Quit", handlequit]
    const label <- box.create[myxf, fl_down_box, 60, 20, 200, 40, "Discussion"]
    const addbutton <- lightbutton.create[myxf, fl_normal_button,200, 70, 80, 30, "Add a line", handleadd]

    const handleinput <- object handleinput
      export operation CallBack [f : XFormObject]
	const inp <- view f as Input
	const s <- inp.getInput
	inp.clear
	browse.addline[s]
      end CallBack
    end handleinput

    myinput <- Input.create[myxf, fl_normal_input, 10, 400, 300, 30, "", handleInput]
    myinput.setScroll[false]
    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
  end initially
  process
    myxf.go
  end process
end junk1
const junk2 <- object junk2
  process
    var browse : Browser
    var myinput : Input
    const myform <- Form.create[myxf, fl_up_box, 320, 460]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myform.destroy
      end CallBack
    end handlequit

    browse <- Browser.create[myxf, fl_normal_browser, 10, 120, 300, 280, ""]
    browse.setFontSize[FL_MEDIUM_FONT]

    const handleadd <- object handleadd
      var number : Integer <- 1
      export operation CallBack [f : XFormObject]
	browse.addLine["This is an automatically generated line: " || number.asString]
	number <- number + 1
	browse.setFontSize[number]
      end CallBack
    end handleadd

    const quitbutton <- lightbutton.create[myxf, fl_normal_button, 40, 70, 80, 30, "Quit", handlequit]
    const label <- box.create[myxf, fl_down_box, 60, 20, 200, 40, "Discussion"]
    const addbutton <- lightbutton.create[myxf, fl_normal_button,200, 70, 80, 30, "Add a line", handleadd]

    const handleinput <- object handleinput
      export operation CallBack [f : XFormObject]
	const inp <- view f as Input
	const s <- inp.getInput
	inp.clear
	browse.addline[s]
      end CallBack
    end handleinput

    myinput <- Input.create[myxf, fl_normal_input, 10, 400, 300, 30, "", handleInput]
    myinput.setScroll[false]
    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
  end process
end junk2
end testx
