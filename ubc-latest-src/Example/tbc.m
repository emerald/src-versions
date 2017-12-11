const tbc <- object tbc
  initially
    const x <- Bitchunk.create[4]
    x.setsigned[0, 32, 24]
    stdout.putint[x.getunsigned[0, 8], 10]
    stdout.putint[x.getunsigned[8, 8], 10]
    stdout.putint[x.getunsigned[16, 8], 10]
    stdout.putint[x.getunsigned[24, 8], 10]
    stdout.putchar['\n']
  end initially
end tbc
