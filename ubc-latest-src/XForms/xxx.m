const width <- 400
const height <- 300

const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, width, height]
    var myvalslider : ValSlider

    const handlequit <- monitor object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    const handleslider <- monitor object handleslider
      export operation CallBack[f : XFormObject]
	const myslider <- view f as Slider
      end CallBack
    end handleslider
    const handlevalslider <- monitor object handlevalslider
      export operation CallBack[f : XFormObject]
	const myvalslider <- view f as Valslider
      end CallBack
    end handlevalslider

    const quitbutton <- lightbutton.create[myxf, fl_normal_button, 10, 70, 60, 30, "Quit", handlequit]

    const label <- box.create[myxf, fl_down_box, 60, 20, 200, 40, "Slider example"]

    const myslider <- slider.create[myxf, fl_hor_nice_slider, 20, 160, 120, 30, "slider", handleslider]
    myslider.setbounds[0.0, 25.0]
    myslider.setstep[0.2]
    myslider.setprecision[1]

    myvalslider <- valslider.create[myxf, fl_hor_nice_slider, 160, 160, 120, 30, "valslider", handlevalslider]
    myvalslider.setbounds[0.0, 25.0]
    myvalslider.setstep[0.2]
    myvalslider.setprecision[1]
    myform.close

    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
    loop
      myvalslider.set[myvalslider.get + 1.0]
      (locate self).delay[time.create[1, 0]]
    end loop
  end process
end testx
