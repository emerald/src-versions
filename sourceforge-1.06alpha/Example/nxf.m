const testx <- object testx
  process
    var quitbutt, addbutt, which : XFButton
    var browser, i, input : Integer
    var str : String
    const myform <- Form.create[fl_up_box, 320, 460]
    myform.addbox[fl_no_box, 160, 40, 0, 0, "Discussion"]
    quitbutt <- myform.addlightbutton[fl_normal_button, 40, 70, 80, 30, "Quit"]
     addbutt <- myform.addlightbutton[fl_normal_button,200, 70, 80, 30, "Add a line"]
    primitive "NCCALL" "XFORMS" "FL_ADD_BROWSER" [browser] <- [fl_normal_browser, 10, 120, 300, 280, ""]
    primitive "NCCALL" "XFORMS" "FL_ADD_INPUT" [input] <- [fl_normal_input, 10, 400, 300, 30, ""]
    primitive "NCCALL" "XFORMS" "FL_SET_INPUT_SCROLL" [] <- [input, 0]
    
    myform.show[fl_place_mouse, fl_noborder, "Things"]
    i <- 1
    loop
      which <- XForms.do
      if which == quitbutt then
	exit 
      elseif which == addbutt then
	str <- "This is line "|| i.asString
	primitive "NCCALL" "XFORMS" "FL_ADDTO_BROWSER" [] <- [browser, str]
	i <- i + 1
      elseif which == input then
	primitive "NCCALL" "XFORMS" "FL_GET_INPUT" [str] <- [input]
	primitive "NCCALL" "XFORMS" "FL_SET_INPUT" [] <- [input, ""]
	primitive "NCCALL" "XFORMS" "FL_ADDTO_BROWSER" [] <- [browser, str]
      end if
    end loop
    myform.hide
  end process
end testx
