const Ident <- record Ident
  var name : String
  var id : Integer
end Ident

const foo <- object foo
  initially
    const a1 <- Array.of[Ident].create[~4]
    a1.addUpper[Ident.create["abc", 4]]
    stdout.putstring[a1[0]$name]
    stdout.putchar[' ']
    stdout.putint[a1[0]$id, 0]
    stdout.putchar['\n']
  end initially
end foo
