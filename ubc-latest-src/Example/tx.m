const foo <- object foo
  initially
    const t <- Time.create[3,0]
    const u <- Time.create[4,0]
    const xx <- t <= u
    stdout.putstring[xx.asString]
    stdout.putchar['\n']
  end initially
end foo
