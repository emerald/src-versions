const foo <- object foo
  initially
    var x : Integer <- 6
    if x == 1 then
      stdout.putstring["one\n"]
    elseif x == 2 then
      stdout.putstring["two\n"]
    elseif x == 3 then
      stdout.putstring["three\n"]
    elseif x == 4 then
      stdout.putstring["four\n"]
    elseif x == 5 then
      stdout.putstring["five\n"]
    elseif x == 6 then
      stdout.putstring["six\n"]
    else
      stdout.putstring["nope\n"]
    end if
  end initially
end foo
