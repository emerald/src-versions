const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 100, 60]

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    const quitbutton <- lightbutton.create[myxf, fl_normal_button, 20, 20, 60, 20, "Quit", handlequit]
    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
