const testx <- object testx
  process
    const myapp <- "MyApp"
    var display, form, yesbutt, nobutt, which : Integer
    const fl_place_mouse <- 1
    const fl_transient <- -1
    const fl_no_box <- 0
    const fl_up_box <- 1
    const fl_normal_button <- 0

    primitive "NCCALL" "XFORMS" "FL_INITIALIZE" [] <- ["MyApp"]
    primitive "NCCALL" "XFORMS" "FL_GET_DISPLAY" [display] <- []    
    if display = 0 then 
      stdout.putstring["fl_get_display returns 0 (which is bad)\n"]
      return 
    end if
    primitive "NCCALL" "XFORMS" "FL_BGN_FORM" [form] <- [fl_up_box, 320, 120]
    primitive "NCCALL" "XFORMS" "FL_CREATE_BOX" [] <- [fl_no_box, 160, 40, 0, 0, "Do you want to quit?"]    
    primitive "NCCALL" "XFORMS" "FL_CREATE_BUTTON" [yesbutt] <- [fl_normal_button, 40, 70, 80, 30, "Yes"]
    primitive "NCCALL" "XFORMS" "FL_CREATE_BUTTON" [nobutt] <- [fl_normal_button, 200, 70, 80, 30, "No"]
    primitive "NCCALL" "XFORMS" "FL_END_FORM" [] <- []
    primitive "NCCALL" "XFORMS" "FL_SHOW_FORM" [] <- [form, fl_place_mouse, fl_transient, "Question"]
    loop
      primitive "NCCALL" "XFORMS" "FL_DO_FORMS" [which] <- []
      exit when which = yesbutt
    end loop
    primitive "NCCALL" "XFORMS" "FL_HIDE_FORM" [] <- [form]
  end process
end testx
