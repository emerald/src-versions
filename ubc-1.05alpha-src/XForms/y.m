const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 200, 200]

    const mybitmap <- bitmap.create[myxf, fl_normal_bitmap, 50, 50, 100, 100, ""]
    myform.add[mybitmap]
    mybitmap.setfile["/usr/X11R6/include/X11/bitmaps/tie_fighter"]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
  end process
end testx
