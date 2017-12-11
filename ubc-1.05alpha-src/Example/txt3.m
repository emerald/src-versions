const txlib <- object txlib
  const cbhelper <- object cbhelper
    process
      var widget, clientdata, calldata, zero : Integer
      loop
	primitive "NCCALL" "XT" "XTRETRIEVECALLBACK" [widget] <- []
	primitive "NCCALL" "XT" "XTRETRIEVECALLBACK" [clientdata] <- []
	primitive "NCCALL" "XT" "XTRETRIEVECALLBACK" [calldata] <- []
	stdout.putstring["Got a callback for widget "]
	stdout.putint[widget, 0]
	stdout.putstring[" with client data "]
	stdout.putint[clientdata, 0]
	stdout.putchar['\n']
	primitive "NCCALL" "XT" "XTRETRIEVECALLBACK" [zero] <- []
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
    var xmPushButtonWidgetClass : Integer
    const x99 <- 99
    const pushme <- "pushme"

    primitive "NCCALL" "XT" "XTSETLANGUAGEPROC" [] <- [zero, zero, zero]
    primitive "NCCALL" "XT" "XTVAAPPINITIALIZE" [shell] <- [hello]
    primitive "NCCALL" "XT" "XTVAAPPINITIALIZE" [ac] <- [hello]
    primitive "NCCALL" "XT" "XMSTRINGCREATELOCALIZED" [label] <- [hellos]
    primitive "NCCALL" "XT" "MXMPUSHBUTTONWIDGETCLASS" [xmPushButtonWidgetClass] <- []
    primitive "NCCALL" "XT" "XTVACREATEMANAGEDWIDGET" [button] <- [pushme, xmPushButtonWidgetClass, shell, labelString, label, zero]
    primitive "NCCALL" "XT" "XMSTRINGFREE" [] <- [label]
    primitive "NCCALL" "XT" "XTADDCALLBACK" [] <- [button, activateCallback, x99]
    primitive "NCCALL" "XT" "XTREALIZEWIDGET" [] <- [shell]
    primitive "NCCALL" "XT" "XTAPPMAINLOOP" [] <- [ac]
  end process
end txlib

const foo <- object foo
  process
    const empty <- ""
    var display, fd, ac, shell, button, label : Integer
    const hello <- "Hello"
    const hellos <- "Push here to say hello"
    const zero <- 0
    const applicationShellWidgetClass <- 1
    const labelString <- "labelString"
    const activateCallback <- "activateCallback"
    var xmPushButtonWidgetClass : Integer
    const x99 <- 99
    const pushme <- "pushme"

    primitive "NCCALL" "XT" "XTSETLANGUAGEPROC" [] <- [zero, zero, zero]
    primitive "NCCALL" "XT" "XTVAAPPINITIALIZE" [shell] <- [hello]
    primitive "NCCALL" "XT" "XTVAAPPINITIALIZE" [ac] <- [hello]
    primitive "NCCALL" "XT" "XMSTRINGCREATELOCALIZED" [label] <- [hellos]
    primitive "NCCALL" "XT" "MXMPUSHBUTTONWIDGETCLASS" [xmPushButtonWidgetClass] <- []
    primitive "NCCALL" "XT" "XTVACREATEMANAGEDWIDGET" [button] <- [pushme, xmPushButtonWidgetClass, shell, labelString, label, zero]
    primitive "NCCALL" "XT" "XMSTRINGFREE" [] <- [label]
    primitive "NCCALL" "XT" "XTADDCALLBACK" [] <- [button, activateCallback, x99]
    primitive "NCCALL" "XT" "XTREALIZEWIDGET" [] <- [shell]
    primitive "NCCALL" "XT" "XTAPPMAINLOOP" [] <- [ac]
  end process
end foo

