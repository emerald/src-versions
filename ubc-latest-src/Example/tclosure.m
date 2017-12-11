const x <- closure x [out : OutStream]
  const z <- 6
  operation foo
    out.putstring["def\n"]
  end foo
  initially
    out.putstring["abc\n"]
    self.foo
  end initially
  process
    out.putstring["ghi\n"]
  end process
end x

const foo <- object foo
  initially
    const y <- view x as ConcreteType
    stdout.putstring[nameof x]
    stdout.putchar['\n']
    stdout.putstring[y$name]
    stdout.putchar['\n']
    stdout.putstring[y$filename]
    stdout.putchar['\n']
    stdout.putstring[y$template]
    stdout.putchar['\n']
    stdout.putint[y$instancesize, 0]
    stdout.putchar['\n']
  end initially
end foo
const z <- new x[stdout]
