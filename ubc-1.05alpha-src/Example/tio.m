const tio <- object tio
  initially
    stdout.writeInt[0x80000000, 4]
    stdout.putchar['\n']
    stdout.flush
  end initially
end tio
