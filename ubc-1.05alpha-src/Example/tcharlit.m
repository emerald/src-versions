const droid <- class droid [index : Integer]
  process
    var label : character
    if index < 10 then
      label <- character.literal['0'.ord + index]
    elseif index < 36 then
      label <- character.literal['a'.ord + index - 10]
    elseif index < 62 then
      label <- character.literal['A'.ord + index - 36]
    else
      label <- '.'
    end if
    stdout.putchar[label]
    stdout.flush
  end process
end droid

const driver <- object driver
  process
    for i : Integer <- 0 while i < 63 by i <- i + 1
      const junk <- droid.create[i]
    end for
  end process
end driver
