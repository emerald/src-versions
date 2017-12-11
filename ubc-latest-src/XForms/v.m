const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    var browse : Browser
    var width : Integer <- 320
    var height : Integer <- 460
    const myinputform <- Form.create[myxf, fl_up_box, 150, 90]
    myinputform.close
    const myform <- Form.create[myxf, fl_up_box, width, height]

    browse <- Browser.create[myxf, fl_normal_browser, 10, 320, 300, 120, ""]
    browse.setFontSize[FL_MEDIUM_FONT]

    const handleinputbutton <- monitor object handleinputbutton
      export operation CallBack [f : XFormObject]
	myinputform.show[fl_place_free, fl_transient, "Input"]
      end CallBack
    end handleinputbutton

    const handleresize <- object handleresize
      export operation CallBack [f : XFormObject]
	width <- width + 10
	height <- height + 10
	myform.setsize[width, height]
      end CallBack
    end handleresize

    const handlequit <- monitor object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    const handlemenu <- monitor object handlemenu
      export operation CallBack[f : XFormObject]
	const mymenu <- view f as Menu
	browse.addline["menu called " || mymenu.gettext]
      end CallBack
    end handlemenu
    const handlechoice <- monitor object handlechoice
      export operation CallBack[f : XFormObject]
	const mychoice <- view f as Choice
	browse.addline["choice called " || mychoice.gettext]
      end CallBack
    end handlechoice
    const handlecounter <- monitor object handlecounter
      export operation CallBack[f : XFormObject]
	const mycounter <- view f as Counter
	browse.addline["counter changed to: " || mycounter.get.asString]
      end CallBack
    end handlecounter
    const handleslider <- monitor object handleslider
      export operation CallBack[f : XFormObject]
	const myslider <- view f as Slider
	browse.addline["slider changed to: " || myslider.get.asString]
      end CallBack
    end handleslider
    const handlevalslider <- monitor object handlevalslider
      export operation CallBack[f : XFormObject]
	const myvalslider <- view f as Valslider
	browse.addline["valslider changed to: " || myvalslider.get.asString]
      end CallBack
    end handlevalslider
    const handledial <- monitor object handledial
      export operation CallBack[f : XFormObject]
	const mydial <- view f as Dial
	browse.addline["dial changed to: " || mydial.get.asString]
      end CallBack
    end handledial
    const quitbutton <- lightbutton.create[myxf, fl_normal_button, 10, 70, 60, 30, "Quit", handlequit]
    const resizebutton <- lightbutton.create[myxf, fl_normal_button, 90, 70, 60, 30, "Resize", handleresize]
    const labelbox <- box.create[myxf, fl_down_box, 60, 20, 200, 40, "Input example"]
    const inputbutton <- lightbutton.create[myxf, fl_normal_button,250, 70, 60, 30, "Input", handleinputbutton]
    const emptybox <- box.create[myxf, fl_up_box, 170, 70, 60, 30, ""]
    const mymenu <- menu.create[myxf, fl_push_menu, 175, 75, 50, 20, "menu", handlemenu]
    mymenu.set["First|Second|Third"]

    const mychoice <- choice.create[myxf, fl_normal_choice, 40, 120, 60, 30, "", handlechoice]
    mychoice.setbox[fl_down_box]
    mychoice.add["First|Second|Third"]

    const mycounter <- counter.create[myxf, fl_normal_counter, 120, 120, 120, 30, "", handlecounter]
    mycounter.setbox[fl_up_box]
    mycounter.setbounds[0.0, 25.0]
    mycounter.setstep[0.2, 2.0]
    mycounter.setprecision[1]

    const myslider <- slider.create[myxf, fl_hor_nice_slider, 20, 160, 120, 30, "slider", handleslider]
    myslider.setbounds[0.0, 25.0]
    myslider.setstep[0.2]
    myslider.setprecision[1]

    const myvalslider <- valslider.create[myxf, fl_hor_nice_slider, 160, 160, 120, 30, "valslider", handlevalslider]
    myvalslider.setbounds[0.0, 25.0]
    myvalslider.setstep[0.2]
    myvalslider.setprecision[1]

    const mydial <- dial.create[myxf, fl_line_dial, 20, 220, 90, 90, "dial", handledial]
    mydial.setbox[fl_up_box]
    mydial.setbounds[0.0, 25.0]
    mydial.setcross[true]
    mydial.setstep[0.2]

    const myclock <- clock.create[myxf, fl_digital_clock, 130, 220, 100, 30, "clock"]
    myform.close

    const handleinput <- object handleinput
      field inputfirst : Input
      field inputsecond : Input
      var first, second : String

      export operation CallBack [f :XFormObject]
	const inp <- view f as Input
	if inp == inputfirst then
	  first <- inputfirst.getInput
	elseif inp == inputsecond then
	  second <- inputsecond.getInput
	  inputfirst.clear
	  inputsecond.clear
	  browse.addline[first || " || " || second]
	  myinputform.hide
	  first, second <- "", ""
	end if
      end CallBack
    end handleinput

    myinputform.open
    const myinput1 <- Input.create[myxf, fl_normal_input, 50, 10, 90, 30, "First: ", handleInput]
    const myinput2 <- Input.create[myxf, fl_normal_input, 50, 50, 90, 30, "Second: ", handleInput]
    myinput1.setScroll[false]
    myinput2.setScroll[false]
    myinputform.close
    handleinput$inputfirst <- myinput1
    handleinput$inputsecond<- myinput2
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
