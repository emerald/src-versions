const tand <- object tand
  initially
    var a, b : Integer
    
    if a and true then stdout.putstring["It broke.\n"] end if
    if false and true then stdout.putstring["It broke.\n"] end if
    if true and a then stdout.putstring["It broke.\n"] end if
    if true and false then stdout.putstring["It broke.\n"] end if

    if a or true then stdout.putstring["It broke.\n"] end if
    if false or true then stdout.putstring["It broke.\n"] end if
    if true or a then stdout.putstring["It broke.\n"] end if
    if true or false then stdout.putstring["It broke.\n"] end if

    if true *> a then stdout.putstring["It broke.\n"] end if
  end initially
end tand
