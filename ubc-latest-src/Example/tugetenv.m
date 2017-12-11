const tgetenv <- object tgetenv
  process
    var s : String
    primitive "NCCALL" "MISK" "UGETENV" [s] <- ["HOME"]
    stdout.putstring["Getenv $HOME -> "||s||"\n"]
    primitive "NCCALL" "MISK" "UGETENV" [s] <- ["BLOTTO"]
    if s == nil then
      stdout.putstring["Getenv $BLOTTO -> nil\n"]
    else
      stdout.putstring["Getenv $BLOTTO -> "||s||"\n"]
    end if
  end process
end tgetenv
