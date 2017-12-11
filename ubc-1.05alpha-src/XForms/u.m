const testx <- object testx
  process
    var myxf : XForms <- XForms.create
    const myform <- Form.create[myxf, fl_up_box, 400, 200]
    var mybrowser : Browser
    var myinput : Input

    const handlequit <- object handlequit
      export operation CallBack [f : XFormObject]
	myform.hide
	myxf.die
      end CallBack
    end handlequit

    mybrowser <- Browser.create[myxf, fl_normal_browser, 10, 10, 380, 140, ""]
    mybrowser.setFontSize[FL_MEDIUM_FONT]
    myform.add[mybrowser]

    const handleinput <- monitor object handleinput
      var nlines : Integer <- 1
      var myline : Integer <- 0
      var hisline : Integer <- 0
      var newline : Boolean <- true
      const prefix <- "@C" || fl_red.asstring
      const remoteprefix <- "@C" || fl_blue.asstring

      function width [s : String] -> [w : Integer]
	w <- myxf.width [FL_NORMAL_STYLE, FL_MEDIUM_FONT, s]
      end width

      export operation CallBack [f : XFormObject]
	var str : String
	const inp <- view f as Input
	str <- inp.getInput
	if newline then
	  mybrowser.addLine[prefix || str]
	  newline <- false
	  myline <- nlines
	elseif self.width[str] > 300 and str[str.upperbound, 1].span[" \t"] = 1 then
	  if hisline > myline then hisline <- hisline + 1 end if
	  mybrowser.insertLine[myline, prefix || str]
	  myline <- myline + 1
	  mybrowser.replaceLine[myline, prefix]
	  nlines <- nlines + 1
	  inp.setInput[""]
	  str <- ""
	else
	  mybrowser.replaceLine[myline, prefix || str]
	end if
	if str.upperbound > 0 and str[str.upperbound] = '\n' then
	  inp.setInput[""]
	  nlines <- nlines + 1
	  newline <- true
	end if
      end CallBack

      export operation RemoteInput [str : String]
	mybrowser.addLine[remoteprefix || str]
	myxf.flush
	nlines <- nlines + 1
      end RemoteInput
    end handleinput

    myinput <- Input.create[myxf, fl_multiline_input, 10, 160, 380, 40, "", handleInput]
    myinput.setScroll[false]
    myinput.setFontSize[FL_MEDIUM_FONT]
    myinput.callbackChanged
    myform.add[myinput]
    myform.show[fl_place_free, fl_fullborder, "Things"]
    myxf.go
    var counter : Integer <- 0
    loop
      (locate self).delay[Time.create[10, 0]]
      counter <- counter + 1
      handleinput.remoteinput["This is a remote line "||counter.asString||"\n"]
      stdout.putstring["Tick\n"]
    end loop
  end process
end testx
