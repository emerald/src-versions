const ima <- immutableVector.of[Any]
const tprintf <- object tprintf
  export operation foo [s : String, r : ima]
    stdout.putstring[s]
    stdout.putchar['\n']
    stdout.putint[view r[0] as Integer, 0]
    stdout.putchar['\n']
    stdout.putstring[view r[1] as String]
    stdout.putchar['\n']
  end foo
end tprintf

const foo <- object foo
  initially
    var i : Integer <- 56
    const qqname  <- true.asString

    tprintf.foo["Generating object #%d %s...\n", {i, qqname }]
  end initially
end foo
