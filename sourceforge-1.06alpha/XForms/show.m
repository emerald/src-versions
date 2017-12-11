const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 150, 60]
%    myform.moveto[1000, 0]
    const here <- locate self
    const port <- here$lnn / 0x10000
    myform.add[box.create[myxf, fl_up_box, 10, 10, 130, 20, here$name]]
    myform.add[box.create[myxf, fl_up_box, 10, 30, 130, 20, port.asString]]
    myform.show[fl_place_position, fl_transient, "Emerald info"]
    myxf.go
  end process
end testx
