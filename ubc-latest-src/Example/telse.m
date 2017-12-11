const telse <- object telse
  initially
    if false then
      stdout.putstring["true\n"]
    else
      stdout.putstring["false\n"]
    end if
  end initially
end telse
