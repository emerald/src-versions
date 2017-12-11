const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 700, 700]

    const mybottompixmap <- pixmap.create[myxf, fl_normal_pixmap, 35, 50, 627, 600, ""]
    const mytoppixmap <- pixmap.create[myxf, fl_normal_pixmap, 300, 350, 32, 32, ""]
    myform.close
    var x, y : Integer
    x <- 0
    y <- 0
    mybottompixmap.setfile["zebra.xpm"]
    mytoppixmap.setfile["bomb.xpm"]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
    loop
      exit when x > 700 or y > 600
      mytoppixmap.moveto[x, y]
      myxf.flush
      x <- x + 20
      y <- y + 15
      (locate self).Delay[Time.create[1, 0]]
    end loop
    myform.hide
  end process
end testx
