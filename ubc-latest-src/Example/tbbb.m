const bbb <- object bbb
  initially
    const t <- vc.foobar
    if t == 1002 then
      stdout.putstring["This is a pain\n"]
    end if
  end initially
end bbb
