const tstr <- object tstr
  initially
    var x, y, z : String
    var t : Integer
    x <- "abc"
    y <- "def"
    z <- "ghi"
    const a <- x[2]
    if x = y then
      z <- x || y || z
    end if
    if t = 45 then
      t <- 46
    end if
  end initially
end tstr
