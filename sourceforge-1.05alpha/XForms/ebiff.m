const callback <- typeobject callback
  operation haveMail
  operation noMail
end callback

const watcher <- class watcher[tfn : String, cb : callback, t : Time]
  function existsAndIsNotEmpty [fn : String] -> [b : Boolean]
    const f <- InStream.fromUnix[fn, "r"]
    const c <- f.getchar
    f.close
    b <- true
    failure
      b <- false
      if f !== nil then f.close end if
    end failure
  end existsAndIsNotEmpty
  export operation go
    const here <- locate self
    var hadMail : Boolean <- false
    loop
      if self.existsAndIsNotEmpty[tfn] then
	if !hadMail then
	  cb.haveMail
	  hadMail <- true
	end if
      else
	if hadMail then
	  cb.noMail
	  hadMail <- false
	end if
      end if
      here.delay[t]
    end loop
    failure end failure
  end go
end watcher

const ebiff <- object ebiff
  const myxf : XForms <- XForms.create
  const myform <- Form.create[myxf, fl_up_box, 64, 64]

  const fullpixmap <- pixmap.create[myxf, fl_normal_pixmap, 0, 0, 64, 64, ""]
  const emptypixmap <- pixmap.create[myxf, fl_normal_pixmap, 0, 0, 64, 64, ""]

  field hasMail : Boolean <- false
  
  export operation haveMail
    hasMail <- true
    const junk <- object flash
      process
	const here <- locate self
	const short <- Time.create[0, 250000]
	const long <- Time.create[1, 000000]

	loop
	  exit when !ebiff$hasMail
	  emptypixmap.hide
	  fullpixmap.show
	  myxf.flush
	  here.delay[long]
	  fullpixmap.hide
	  emptypixmap.show
	  myxf.flush
	  here.delay[short]
	end loop
      end process
    end flash
    const junk2 <- object beep
      process
	const here <- locate self
	const minute <- Time.create[60, 0]

	loop
	  exit when !ebiff$hasMail
	  myxf.bell
	  myxf.flush
	  here.delay[minute]
	end loop
      end process
    end beep
  end haveMail

  export operation noMail
    hasMail <- false
  end noMail

  initially
    myform.moveto[1216, 960]
    myform.add[fullpixmap]
    myform.add[emptypixmap]
    fullpixmap.setfile["xmail.xpm"]
    emptypixmap.setfile["xnomail.xpm"]
    fullpixmap.hide
  end initially

  process
    const here <- locate self
    myform.show[fl_place_position, fl_noborder, "EBiff"]
    myxf.go
    const w <- watcher.create["/usr/spool/mail/norm", self, Time.create[5, 0]]
    const allmachines <- here.getActiveNodes
    move w to allmachines[1]$theNode
    w.go
    failure
      self.noMail
      myform.hide
    end failure
  end process
end ebiff
