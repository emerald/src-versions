const dirread <- class dirread[dir : String]
  var dp : Integer
  export op next -> [name : String]
    primitive "NCCALL" "MISK" "UREADDIR" [name] <- [dp]
  end next
  export op close
    primitive "NCCALL" "MISK" "UCLOSEDIR" [] <- [dp]
  end close
  initially
    primitive "NCCALL" "MISK" "UOPENDIR" [dp] <- [dir]
    if dp == 0 then
      returnandfail
    end if
  end initially
end dirread

const testx <- object testx
  var myxf : XForms <- XForms.create
  const sizex <- 1000
  const sizey <- 120
  const incx <- 100
  const incy <- 100
  var myform : Form

  var path : String <- "./icons/"
  var dr : DirRead <- dirread.create[path]
  const mymaps <- Vector.of[PixMap].create[sizex / incx]
  const handlequit <- object handlequit
    export operation CallBack [f : XFormObject]
      testx.dosome
    end CallBack
  end handlequit

  export op setup
    var posx : Integer <- 0
    var posy : Integer <- 0
    for i : Integer <- 0 while i < 10 by i <- i + 1
      mymaps[i] <- pixmap.create[myxf, fl_normal_pixmap, posx, posy, incx, incy, ""]
      posx <- posx + incx
    end for
  end setup

  export op dosome
    var name : String
    var i : Integer <- 0
    myform.freeze
    for j : Integer <- 0 while j < 10 by j <- j + 1
      mymaps[j].hide
    end for
    loop
      exit when i >= 10
      name <- dr.next
      exit when name == nil
      if name != "." and name != ".." then
	mymaps[i].setfile[path || name]
	mymaps[i].setlabel[name]
	mymaps[i].show
	i <- i + 1
      end if
    end loop
    myform.unfreeze
  end dosome

  process
    myform <- Form.create[myxf, fl_up_box, sizex, sizey]
    self.setup
    const quitbutton <- button.create[myxf, fl_hidden_button, 0, 0, sizex, sizey, "", handlequit]
    myform.close
    myform.show[fl_place_free, fl_fullborder, "Things"]
    self.dosome
    myxf.go
  end process
end testx
