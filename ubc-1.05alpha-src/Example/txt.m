const txlib <- object txlib
  const cbhelper <- object cbhelper
    process
      var widget, clientdata, calldata, zero : Integer
      loop
	primitive "NCCALL" "XTA" "XTRETRIEVECALLBACK" [widget] <- []
	primitive "NCCALL" "XTA" "XTRETRIEVECALLBACK" [clientdata] <- []
	primitive "NCCALL" "XTA" "XTRETRIEVECALLBACK" [calldata] <- []
	stdout.putstring["Got a callback for widget "]
	stdout.putint[widget, 0]
	stdout.putstring[" with client data "]
	stdout.putint[clientdata, 0]
	stdout.putchar['\n']
	primitive "NCCALL" "XTA" "XTRETRIEVECALLBACK" [zero] <- []
	assert zero = 0
      end loop
    end process
  end cbhelper
  process
    const empty <- ""
    var display, fd, ac, shell, button, label : Integer
    const hello <- "Hello"
    const hellos <- "Push here to say hello"
    const zero <- 0
    const applicationShellWidgetClass <- 1
    const labelString <- "labelString"
    const activateCallback <- "activateCallback"
    const xmPushButtonWidgetClass <- 0
    const xmMainWindowWidgetClass <- 1
    var xmPBWC : Integer
    const x99 <- 99
    const pushme <- "pushme"
    var ttt : Integer

    primitive "NCCALL" "XTA" "XTSETLANGUAGEPROC" [] <- [zero, zero, zero]
    primitive "NCCALL" "XTA" "XTVAAPPINITIALIZE" [shell] <- [hello]
    primitive "NCCALL" "XTA" "XTVAAPPINITIALIZE" [ac] <- [hello]
    primitive "NCCALL" "XMA" "XMSTRINGCREATELOCALIZED" [label] <- [hellos]
%    primitive "NCCALL" "XMA" "MXMMAPWIDGETCLASS" [xmPBWC] <- [xmPushButtonWidgetClass]
    ttt <- 0
    primitive "NCCALL" "XTA" "MXTSETARGSTRING" [] <- [ttt,labelString]
    ttt <- 1
    primitive "NCCALL" "XTA" "MXTSETARGINT" [] <- [ttt,label]
    ttt <- 2 
    primitive "NCCALL" "XTA" "MXTVACREATEMANAGEDWIDGET" [button] <- [pushme, xmPushButtonWidgetClass, shell, ttt]
    primitive "NCCALL" "XTA" "MXTCLEARARG" [] <- [ttt]
    primitive "NCCALL" "XMA" "XMSTRINGFREE" [] <- [label]
    primitive "NCCALL" "XTA" "XTADDCALLBACK" [] <- [button, activateCallback, x99]
    primitive "NCCALL" "XTA" "XTREALIZEWIDGET" [] <- [shell]
    primitive "NCCALL" "XTA" "XTAPPMAINLOOP" [] <- [ac]
  end process
end txlib
