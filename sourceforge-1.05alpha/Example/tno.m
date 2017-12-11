const foo <- object foo
  initially
    var x : Integer
    x <- 23
  end initially
end foo

const tno <- object tno
  initially
    const t <- Time.create[34,45]

    stdout.putstring[nameof 3.15]
    stdout.putchar['\n']
  end initially
end tno
