const testx <- object testx
  var myxf : XForms <- XForms.create
  const sizex <- 120
  const sizey <- 120
  const incx <- 100
  const incy <- 100
  var posx : Integer <- 0
  var myform : Form
  var mailp, nomailp : PixMap

  var mpath : String <- "xmail.xpm"
  var npath : String <- "xnomail.xpm"
	
  export op setup
    mailp <- pixmap.create[myxf, fl_normal_pixmap, posx, 0, incx, incy, ""]
    nomailp <- pixmap.create[myxf, fl_normal_pixmap, posx, 0, incx, incy, ""]
    myform.add[mailp]
    myform.add[nomailp]
    nomailp.hide
    mailp.setfile[mpath]
    nomailp.setfile[npath]
  end setup

  process
    myform <- Form.create[myxf, fl_up_box, sizex, sizey]
    self.setup
    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit
  
    const handleswap <- object handleswap
      export operation CallBack [f : XFormObject]
	mailp, nomailp <- nomailp, mailp
	nomailp.hide
	mailp.show
      end CallBack
    end handleswap
  
    myform.add[button.create[myxf, fl_normal_button, 80, 20, 30, 20, "Swap", handleswap]]
    myform.add[button.create[myxf, fl_normal_button, 80, 80, 30, 20, "Quit", handlequit]]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
    loop
      (locate self).delay[Time.create[0, 250000]]
      handleswap.CallBack[nil]
    end loop
  end process
end testx
