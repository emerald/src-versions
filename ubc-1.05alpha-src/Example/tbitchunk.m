const foo <- object foo
  initially
    const b <- bitchunk.create[4]
    b[0, 32] <- 0x12345678
    b.ntoh[0, 32]
    stdout.putint[b[0, 8], 0]
    stdout.putchar[' ']
    stdout.putint[b[8, 8], 0]
    stdout.putchar[' ']
    stdout.putint[b[16, 8], 0]
    stdout.putchar[' ']
    stdout.putint[b[24, 8], 0]
    stdout.putchar['\n']
  end initially
end foo
