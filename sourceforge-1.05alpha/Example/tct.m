const foo <- object foo
  initially
    var x : Integer <- 34
    stdout.putint[x, 0]
    stdout.putchar['\n']
  end initially
end foo

const tct <- object tct
  initially
    var a : ConcreteType
    const n <- { stdout }
    var y : Any
    const t <- Time.create[34,45]

    a <- codeof foo
    primitive "XCREATE" [y] <- [a, n]
    stdout.putstring[a$name]
    stdout.putchar['\n']
    stdout.putstring[a$filename]
    stdout.putchar['\n']
  end initially
end tct
