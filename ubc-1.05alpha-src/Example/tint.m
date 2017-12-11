const tint <- object tint
  initially
    var x : Integer
    x <- Integer.Literal["34"]
    stdout.putint[x, 0]
    stdout.putchar['\n']
  end initially
end tint
