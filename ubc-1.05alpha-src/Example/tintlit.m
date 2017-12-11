const tnil <- object tnil
  initially
    var x : Integer <- 0x80000000
    stdout.putint[x, 0]
    stdout.putchar['\n']
    x <- 0x40000000 + 0x40000000
    stdout.putint[x, 0]
    stdout.putchar['\n']
  end initially
end tnil
