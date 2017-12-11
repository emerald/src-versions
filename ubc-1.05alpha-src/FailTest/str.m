const str <- object str
  initially
    const x <- "abc"
    x
    "abc"
    6
    x.getElement[3]
    x[4]
    if 5 then
      x[4]
    else
      x[4]
    end if
    loop
      x[5]
      exit when "abc"
    end loop
    assert x[0] != 'a'
    assert x[0, 1] != "abcdef"
    
  end initially
end str
