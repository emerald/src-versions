const txlib <- object txlib
  process
    const empty <- ""
    var display, fd, ac, shell, dialog : Integer
    const hello <- "hello world"
    const helloc <- "Hello, world!"
    const zero <- 0
    const applicationShellWidgetClass <- 1

    primitive "NCCALL" "XT" "XTTOOLKITINITIALIZE" [] <- []
    primitive "NCCALL" "XT" "XTCREATEAPPLICATIONCONTEXT" [ac] <- []
    primitive "NCCALL" "XT" "XTOPENDISPLAY" [display] <- [ac, hello, helloc]
    primitive "NCCALL" "XLIB" "XCONNECTIONNUMBER" [fd] <- [display]
    primitive "NCCALL" "XLIB" "MTREGISTERFD" [] <- [fd]
    primitive "NCCALL" "XT" "XTAPPCREATESHELL" [shell] <- [hello, helloc, applicationShellWidgetClass, display, zero, zero]
    primitive "NCCALL" "XT" "XMCREATELABEL" [dialog] <- [shell, helloc, zero, zero]
    primitive "NCCALL" "XT" "XTMANAGECHILD" [] <- [dialog]
    primitive "NCCALL" "XT" "XTREALIZEWIDGET" [] <- [shell]
    primitive "NCCALL" "XT" "XTAPPMAINLOOP" [] <- [ac]
  end process
end txlib
